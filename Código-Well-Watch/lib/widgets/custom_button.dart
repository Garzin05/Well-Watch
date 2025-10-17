import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function()? onPressed;
  final bool isLoading;
  final bool isPrimary;

  const CustomButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(text),
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
