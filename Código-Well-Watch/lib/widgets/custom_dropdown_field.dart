import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String labelText;
  final T value;
  final List<T> items;
  final void Function(T?) onChanged;
  final Icon? prefixIcon;

  const CustomDropdownField({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(item.toString()),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
