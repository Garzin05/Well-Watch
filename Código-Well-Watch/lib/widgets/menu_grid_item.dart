import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:projetowell/utils/constants.dart';

class MenuGridItem extends StatelessWidget {
  final String lottieAsset;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final double? lottieSize;

  const MenuGridItem({
    super.key,
    required this.lottieAsset,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.lottieSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: lottieSize ?? 80,
              width: lottieSize ?? 80,
              child: Lottie.asset(
                lottieAsset,
                repeat: true,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.error_outline,
                    color: iconColor ?? AppColors.darkBlueBackground,
                    size: 48,
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrayText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
