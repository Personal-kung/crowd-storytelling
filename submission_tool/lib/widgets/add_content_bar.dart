import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class AddContentBar extends StatelessWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddPhoto;
  final VoidCallback onAddDraw;

  const AddContentBar({
    super.key,
    required this.onAddText,
    required this.onAddPhoto,
    required this.onAddDraw,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionItem(
            icon: Icons.edit_note,
            label: LocalizationService().t("blocks.type"),
            onTap: onAddText,
          ),
          const SizedBox(width: 24),
          _buildActionItem(
            icon: Icons.camera_alt_outlined,
            label: LocalizationService().t("blocks.photo"),
            onTap: onAddPhoto,
          ),
          const SizedBox(width: 24),
          _buildActionItem(
            icon: Icons.gesture,
            label: LocalizationService().t("blocks.handwrite"),
            onTap: onAddDraw,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
