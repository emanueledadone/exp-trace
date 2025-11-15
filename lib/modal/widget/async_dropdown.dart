import 'package:exp_trace/modal/widget/base_dropdown.dart';
import 'package:flutter/material.dart';

class AsyncDropdownField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final Future<List<Map<String, dynamic>>> futureItems;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const AsyncDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.futureItems,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureItems,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return BaseDropdownField<T>(
          value: value,
          label: label,
          items:
              snapshot.data!.map((item) {
                return DropdownMenuItem<T>(
                  value: item['id'] as T,
                  child: Text(item['name']),
                );
              }).toList(),
          onChanged: onChanged,
          validator: validator,
        );
      },
    );
  }
}
