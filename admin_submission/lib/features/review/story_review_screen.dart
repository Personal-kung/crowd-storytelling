import 'package:flutter/material.dart';

import '../capture/models/submission_session.dart';
import 'models/story_draft.dart';
import 'services/story_publish_service.dart';

class StoryReviewScreen extends StatefulWidget {
  const StoryReviewScreen({
    super.key,
    required this.ocrResult,
    required this.session,
  });

  final Map<String, dynamic> ocrResult;
  final SubmissionSession session;

  @override
  State<StoryReviewScreen> createState() => _StoryReviewScreenState();
}

class _StoryReviewScreenState extends State<StoryReviewScreen> {
  late final StoryDraft draft;

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _notesController;

  final StoryPublishService _publishService = StoryPublishService();
  bool _publishing = false;

  @override
  void initState() {
    super.initState();

    draft = StoryDraft(body: widget.ocrResult['correctedText'] ?? '');

    _titleController = TextEditingController(text: draft.title);

    _bodyController = TextEditingController(text: draft.body);

    _notesController = TextEditingController(text: draft.curatorNotes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Story')),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [
            Text(
              widget.session.contributorName,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            Text(widget.session.countryName),

            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Story',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Curator Notes',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Improve Text'),
                ),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Generate Title'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                  onPressed: () {},
                  child: const Text('Reject'),
                ),

                ElevatedButton(onPressed: () {}, child: const Text('Resubmit')),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),

                  onPressed: _publishing
                      ? null
                      : () async {
                          setState(() {
                            _publishing = true;
                          });

                          try {
                            await _publishService.publishStory(
                              session: widget.session,
                              title: _titleController.text,
                              body: _bodyController.text,
                              curatorNotes: _notesController.text,
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Story published')),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Publish failed: $e')),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _publishing = false;
                              });
                            }
                          }
                        },

                  child: _publishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
