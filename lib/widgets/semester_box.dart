import 'package:flutter/material.dart';
import 'package:su/core/constants/app_text_styles.dart';

class SemesterBox extends StatelessWidget {
  final Color        color;
  final String       label;
  final String       imagePath;
  final VoidCallback onTap;

  const SemesterBox({
    super.key,
    required this.color,
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 70),
            const SizedBox(height: 10),
            Text(label, style: AppTextStyles.boxLabel),
          ],
        ),
      ),
    );
  }
}