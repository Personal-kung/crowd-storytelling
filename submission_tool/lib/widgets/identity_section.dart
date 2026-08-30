import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../services/localization_service.dart';

class IdentitySection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController countryController;
  final Function(Country) onCountrySelected;

  const IdentitySection({
    super.key,
    required this.nameController,
    required this.countryController,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService().t("identity.title") ?? "A little about you",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 48),
          
          Text(
            LocalizationService().t("identity.name_prompt") ?? "What should we call you?",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
              fontFamily: 'Georgia',
            ),
          ),
          TextField(
            controller: nameController,
            style: const TextStyle(fontSize: 22, fontFamily: 'Georgia', color: Colors.black87),
            decoration: InputDecoration(
              hintText: LocalizationService().t("identity.name") ?? "[ name ]",
              hintStyle: const TextStyle(color: Colors.black26),
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 40),
          
          Text(
            LocalizationService().t("identity.country_prompt") ?? "Where are you from?",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
              fontFamily: 'Georgia',
            ),
          ),
          InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: onCountrySelected,
              );
            },
            child: IgnorePointer(
              child: TextField(
                controller: countryController,
                style: const TextStyle(fontSize: 22, fontFamily: 'Georgia', color: Colors.black87),
                decoration: InputDecoration(
                  hintText: LocalizationService().t("identity.countryOptional") ?? "[ country ]",
                  hintStyle: const TextStyle(color: Colors.black26),
                  suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black38),
                  border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
