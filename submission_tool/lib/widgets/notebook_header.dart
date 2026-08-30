import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../services/story_service.dart';
import '../models/story_cover_image.dart';

class NotebookHeader extends StatelessWidget {
  const NotebookHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = LocalizationService().t;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "GLOBAL NOTEBOOK",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              height: 1.1,
              fontFamily: 'Georgia',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 48),
          FutureBuilder<List<StoryCoverImage>>(
            future: StoryService().fetchApprovedStoryCoverImages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.black26,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              List<Widget> children = [];
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                // Fallback collage
                children = [
                  _buildCoverItem(null, Icons.auto_stories, angle: -0.05),
                  _buildCoverItem(null, Icons.landscape, angle: 0.05),
                ];
              } else {
                var covers = snapshot.data!;
                for (int i = 0; i < covers.length && i < 4; i++) {
                  double angle = i % 2 == 0 ? -0.04 : 0.06;
                  children.add(_buildCoverItem(covers[i], null, angle: angle));
                }
              }

              return SizedBox(
                height: 240,
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: -20, // Negative spacing for overlap
                    runSpacing: 10,
                    children: children,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Text(
            t("hero.description"),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black54,
              height: 1.8,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverItem(StoryCoverImage? cover, IconData? fallbackIcon, {required double angle}) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(2, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: cover?.resolvedUrl != null
            ? Image.network(
                cover!.resolvedUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.black26)),
              )
            : Container(
                color: Colors.grey.shade100,
                child: Icon(fallbackIcon ?? Icons.image, color: Colors.black26, size: 40),
              ),
      ),
    );
  }
}
