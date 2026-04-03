import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For secure login
import 'dart:convert'; // CRITICAL for base64Decode
import 'package:url_launcher/url_launcher.dart';

class EditorDashboard extends StatefulWidget {
  const EditorDashboard({super.key});

  @override
  State<EditorDashboard> createState() => _EditorDashboardState();
}

class _EditorDashboardState extends State<EditorDashboard> {
  int _selectedIndex = 0;

  // This would typically come from your Firestore stream
  final List<Map<String, dynamic>> _pendingStories = [
    {
      "name": "Alex",
      "country": "Japan",
      "type": "photo",
      "content": "A story about the cherry blossoms...",
      "status": "pending",
      "imageUrl": "https://via.placeholder.com/300",
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Story Curation Hub"),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_stories),
            tooltip: "View Virtual Notebook",
            onPressed: () async {
              final Uri url = Uri.parse('http://localhost:8000');
              if (!await launchUrl(url)) {
                debugPrint("Could not launch Virtual Notebook.");
              }
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.rate_review),
                  label: Text("Revision"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.print_rounded),
                  label: Text("Scribe"),
                ),
              ],
            ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildRevisionTab()
                : _buildScribeTab(),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.rate_review),
                  label: "Revision",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.print_rounded),
                  label: "Scribe",
                ),
              ],
            )
          : null,
    );
  }

  // TAB 1: SUBMISSION REVISION (Side-by-Side)
  Widget _buildRevisionTab() {
    return StreamBuilder<QuerySnapshot>(
      // This stream stays "open" and listens for changes in Firestore
      stream: FirebaseFirestore.instance
          .collection('stories')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text("Error loading stories"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No stories submitted yet."));
        }

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final story = doc.data() as Map<String, dynamic>;
            final String docId = doc.id;
            final List<dynamic> pages = story['pages'] ?? [];

            // Local controller for the transcript
            final TextEditingController transcriptController =
                TextEditingController(text: story['text_content'] ?? "");

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ExpansionTile(
                title: Text(
                  "${story['name'] ?? 'Anonymous'} - ${story['status']}",
                ),
                subtitle: Text("Pages: ${pages.length}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    // RESPONSIVE SPLIT: Check width to decide layout
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 600;

                        Widget imageStack = Column(
                          children: pages.map((base64Str) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Image.memory(
                                base64Decode(base64Str),
                                fit: BoxFit.contain,
                              ),
                            );
                          }).toList(),
                        );

                        Widget editorFields = Column(
                          children: [
                            TextField(
                              controller: transcriptController,
                              maxLines: 10,
                              decoration: const InputDecoration(
                                labelText: "Transcription",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // REJECT BUTTON
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _updateStatus(docId, 'rejected'),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  label: const Text("Reject"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                // APPROVE BUTTON
                                ElevatedButton.icon(
                                  onPressed: () => _updateStatus(
                                    docId,
                                    'approved',
                                    transcript: transcriptController.text,
                                  ),
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                  label: const Text("Approve"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );

                        // If desktop (wide), show side-by-side. If mobile, show top-bottom.
                        return isMobile
                            ? Column(
                                children: [
                                  imageStack,
                                  const Divider(),
                                  editorFields,
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: SingleChildScrollView(
                                      child: imageStack,
                                    ),
                                  ),
                                  const VerticalDivider(),
                                  Expanded(flex: 1, child: editorFields),
                                ],
                              );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // TAB 2: SCRIBE & OUTREACH
  Widget _buildScribeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_edu, size: 80, color: Colors.blueGrey),
          const SizedBox(height: 20),
          const Text("Ready for the Notebook", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_to_mobile),
            label: const Text("Send to Hardware Plotter"),
            onPressed: () {
              /* Logic to trigger AxiDraw */
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Generate & Send AI Thank You"),
            onPressed: () {
              /* Integration with OpenAI API */
            },
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Story Approved! Moving to Scribe queue.")),
    );
  }

  Future<void> _updateStatus(
    String docId,
    String status, {
    String? transcript,
  }) async {
    try {
      Map<String, dynamic> data = {'status': status};

      // If we are approving, save the corrected text
      if (transcript != null) {
        data['text_content'] = transcript;
      }

      // Optional: Clean up memory by deleting the images once approved/rejected
      // data['pages'] = FieldValue.delete();

      await FirebaseFirestore.instance
          .collection('stories')
          .doc(docId)
          .update(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Story $status successfully")));
    } catch (e) {
      print("Update failed: $e");
    }
  }
}
