import 'package:flutter/material.dart';

class CustomChipsInput extends StatefulWidget {
  final String labelText;
  final String hintText;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const CustomChipsInput({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.values,
    required this.onChanged,
  });

  @override
  State<CustomChipsInput> createState() => _CustomChipsInputState();
}

class _CustomChipsInputState extends State<CustomChipsInput> {
  final _controller = TextEditingController();

  void _addChip(String text) {
    if (text.isNotEmpty && !widget.values.contains(text)) {
      final newValues = List<String>.from(widget.values)..add(text);
      widget.onChanged(newValues);
      _controller.clear();
    }
  }

  void _removeChip(String value) {
    final newValues = List<String>.from(widget.values)..remove(value);
    widget.onChanged(newValues);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.values
              .map(
                (value) => Chip(
                  label: Text(value),
                  onDeleted: () => _removeChip(value),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.hintText,
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addChip(_controller.text.trim()),
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) => _addChip(value.trim()),
        ),
      ],
    );
  }
}
