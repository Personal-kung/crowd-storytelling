import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../main.dart'; // To access StoryBlock
import 'story_block_widget.dart';
import 'add_content_bar.dart';

class StorySection extends StatelessWidget {
  final String chapterNumber;
  final String title;
  final List<StoryBlock> blocks;
  final VoidCallback onAddText;
  final VoidCallback onAddPhoto;
  final VoidCallback onAddDraw;
  final Function(StoryBlock) onRemoveBlock;
  final VoidCallback onChanged;

  const StorySection({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.blocks,
    required this.onAddText,
    required this.onAddPhoto,
    required this.onAddDraw,
    required this.onRemoveBlock,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapterNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Georgia',
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ...blocks.map((b) => StoryBlockWidget(
                key: ValueKey(b.id),
                block: b,
                onRemove: () => onRemoveBlock(b),
                onChanged: onChanged,
              )),
          if (blocks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                LocalizationService().t("blocks.empty"),
                style: const TextStyle(
                  color: Colors.black38,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          const SizedBox(height: 16),
          AddContentBar(
            onAddText: onAddText,
            onAddPhoto: onAddPhoto,
            onAddDraw: onAddDraw,
          ),
          const SizedBox(height: 48),
          const Center(
            child: SizedBox(
              width: 120,
              child: Divider(color: Colors.black12, thickness: 1),
            ),
          ),
        ],
      ),
    );
  }
}
