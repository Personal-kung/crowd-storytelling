import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../main.dart'; // To access StoryBlock and BlockType

class StoryBlockWidget extends StatefulWidget {
  final StoryBlock block;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const StoryBlockWidget({
    super.key,
    required this.block,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<StoryBlockWidget> createState() => _StoryBlockWidgetState();
}

class _StoryBlockWidgetState extends State<StoryBlockWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.block.type == BlockType.text)
              _buildTextBlock()
            else if (widget.block.bytes != null)
              _buildImageBlock(),
            
            // Delete Control
            Positioned(
              top: -12,
              right: -12,
              child: AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.0, // Mobile users can just tap where it is or we can show it slightly
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black45, size: 20),
                  onPressed: widget.onRemove,
                  tooltip: LocalizationService().t("actions.remove_block") ?? "Remove",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBlock() {
    return TextField(
      controller: widget.block.textController,
      maxLines: null,
      onChanged: (_) => widget.onChanged(),
      style: const TextStyle(
        fontSize: 20,
        height: 1.8,
        fontFamily: 'Georgia',
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: LocalizationService().t("blocks.placeholder"),
        hintStyle: const TextStyle(
          color: Colors.black26,
          fontStyle: FontStyle.italic,
        ),
        border: InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
    );
  }

  Widget _buildImageBlock() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Image.memory(
          widget.block.bytes!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
