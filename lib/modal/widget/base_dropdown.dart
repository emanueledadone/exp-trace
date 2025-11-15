import 'package:flutter/material.dart';

class BaseDropdownField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const BaseDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
