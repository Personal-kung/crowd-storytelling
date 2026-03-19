import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For secure login

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
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () {})],
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

            // Local controller for the transcript editing
            final TextEditingController
            transcriptController = TextEditingController(
              text: story['text_content'] ?? story['curation_transcript'] ?? "",
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  "${story['name'] ?? 'Anonymous'} (${story['country'] ?? 'Global'})",
                ),
                subtitle: Text("Status: ${story['status']}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (story['image_url'] != null)
                          Image.network(
                            story['image_url'],
                            height: 300,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                          ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: transcriptController,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            labelText: "Review & Correct Transcript",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Approve Story"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[100],
                              ),
                              onPressed: () => _approveStory(
                                docId,
                                transcriptController.text,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Future<void> _approveStory(String docId, String finalTranscript) async {
    try {
      await FirebaseFirestore.instance.collection('stories').doc(docId).update({
        'text_content': finalTranscript, // Save your corrections
        'status': 'approved', // This triggers the hardware
        'approved_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Story Approved! Sending to hardware queue."),
        ),
      );
    } catch (e) {
      print("Approval failed: $e");
    }
  }
}
