import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For secure login
import 'dart:convert'; // CRITICAL for base64Decode
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditorDashboard extends StatefulWidget {
  const EditorDashboard({super.key});

  @override
  State<EditorDashboard> createState() => _EditorDashboardState();
}

class _EditorDashboardState extends State<EditorDashboard> {
  int _selectedIndex = 0;

  // Tracking rotation: Map<docId, Map<pageIndex, rotationIndex>>
  final Map<String, Map<int, int>> _rotations = {};
  bool _isTranscribing = false;

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
                  "${story['title'] ?? story['name'] ?? 'Untitled'} - ${story['status']}",
                ),
                subtitle: Text(
                  "Author: ${story['name'] ?? 'Unknown'} | Pages: ${pages.length}",
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _confirmDelete(docId),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    // RESPONSIVE SPLIT: Check width to decide layout
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 600;

                        Widget imageStack = Column(
                          children: pages.asMap().entries.map((entry) {
                            int pageIdx = entry.key;
                            String base64Str = entry.value;

                            // Get or initialize rotation
                            if (!_rotations.containsKey(docId))
                              _rotations[docId] = {};
                            int rotation = _rotations[docId]![pageIdx] ?? 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  RotatedBox(
                                    quarterTurns: rotation,
                                    child: Image.memory(
                                      base64Decode(base64Str),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.rotate_right,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _rotations[docId]![pageIdx] =
                                                (rotation + 1) % 4;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );

                        Widget editorFields = Column(
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                TextField(
                                  controller: transcriptController,
                                  maxLines: 8,
                                  decoration: const InputDecoration(
                                    labelText: "Transcription",
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                ),
                                if (_isTranscribing)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.auto_awesome),
                                    tooltip:
                                        "Auto-Transcribe with Cloud Vision",
                                    onPressed: () async {
                                      final text = await _transcribeImages(
                                        pages,
                                      );
                                      if (text.isNotEmpty) {
                                        transcriptController.text = text;
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // METADATA FIELDS
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        TextEditingController(
                                          text: story['title'] ?? "",
                                        )..addListener(() {
                                          // This is a shortcut for demo; better to use a dedicated controller map
                                        }),
                                    onChanged: (val) => story['title'] = val,
                                    decoration: const InputDecoration(
                                      labelText: "Story Title (Optional)",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: story['country'] ?? "",
                                    ),
                                    onChanged: (val) => story['country'] = val,
                                    decoration: const InputDecoration(
                                      labelText: "Country (Optional)",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: TextEditingController(
                                text: story['name'] ?? "",
                              ),
                              onChanged: (val) => story['name'] = val,
                              decoration: const InputDecoration(
                                labelText: "Author (MANDATORY)",
                                border: OutlineInputBorder(),
                                errorText: null, // We will validate on submit
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
                                  onPressed: () {
                                    if (story['name'] == null ||
                                        story['name']!.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Author is mandatory!"),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    _updateStatus(
                                      docId,
                                      'approved',
                                      transcript: transcriptController.text,
                                      author: story['name'],
                                      title: story['title'],
                                      country: story['country'],
                                    );
                                  },
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
    String? author,
    String? title,
    String? country,
  }) async {
    try {
      Map<String, dynamic> data = {'status': status};

      if (transcript != null) data['text_content'] = transcript;
      if (author != null) data['name'] = author;
      if (title != null) data['title'] = title;
      if (country != null) data['country'] = country;

      await FirebaseFirestore.instance
          .collection('stories')
          .doc(docId)
          .update(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Story $status successfully")));
    } catch (e) {
      debugPrint("Update failed: $e");
    }
  }

  Future<void> _confirmDelete(String docId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Story?"),
        content: const Text(
          "This will permanently remove the story and its images from the database.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteStory(docId);
    }
  }

  Future<void> _deleteStory(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Story deleted")));
    } catch (e) {
      debugPrint("Delete failed: $e");
    }
  }

  Future<String> _transcribeImages(List<dynamic> pages) async {
    final String apiKey = dotenv.get('GOOGLE_VISION_API_KEY', fallback: '');

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please set your GOOGLE_VISION_API_KEY in the .env file.",
          ),
        ),
      );
      return "";
    }

    setState(() => _isTranscribing = true);
    String fullText = "";

    try {
      for (var base64Image in pages) {
        final response = await http.post(
          Uri.parse(
            'https://vision.googleapis.com/v1/images:annotate?key=$apiKey',
          ),
          body: jsonEncode({
            "requests": [
              {
                "image": {"content": base64Image},
                "features": [
                  {"type": "TEXT_DETECTION"},
                ],
              },
            ],
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text =
              data['responses'][0]['fullTextAnnotation']?['text'] ?? "";
          fullText += "$text\n";
        } else {
          debugPrint("Vision API Error: ${response.body}");
        }
      }
    } catch (e) {
      debugPrint("Transcription failed: $e");
    } finally {
      setState(() => _isTranscribing = false);
    }

    return fullText.trim();
  }
}
