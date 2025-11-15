import 'package:flutter/material.dart';

class BaseTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool readOnly;
  final IconData? suffixIcon;
  final VoidCallback? onTap;

  const BaseTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false, // Default: campo modificabile
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon:
            suffixIcon != null
                ? Icon(suffixIcon)
                : null, // Aggiunto suffisso icona opzionale
      ),
      keyboardType: keyboardType,
      validator: validator,
      readOnly:
          readOnly, // Ora può essere impostato a true per campi non modificabili
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      }, // Ora supporta eventi di tap, ideale per la selezione di date
    );
  }
}
