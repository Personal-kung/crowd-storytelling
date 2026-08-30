import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class NotebookSubmit extends StatelessWidget {
  final bool isReady;
  final VoidCallback onSubmit;

  const NotebookSubmit({
    super.key,
    required this.isReady,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService().t("submit.ready_prompt") ?? "When you're ready,",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: isReady ? onSubmit : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocalizationService().t("actions.submit") ?? "Leave your page",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w600,
                      color: isReady ? Colors.black87 : Colors.black26,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isReady ? Colors.black87 : Colors.black26,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80), // Bottom padding
        ],
      ),
    );
  }
}
