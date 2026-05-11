import 'package:flutter/material.dart';
import 'package:su/core/constants/app_colors.dart';
import 'package:su/core/constants/app_text_styles.dart';

class FolderTile extends StatelessWidget {
  final String       name;
  final VoidCallback onTap;

  const FolderTile({super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) => _BaseTile(
        icon:      Icons.folder_rounded,
        iconColor: AppColors.subtle,
        label:     name,
        onTap:     onTap,
      );
}

class FileTile extends StatelessWidget {
  final String       name;
  final VoidCallback onTap;

  const FileTile({super.key, required this.name, required this.onTap});

  static IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.pdf'))                                       return Icons.picture_as_pdf_rounded;
    if (n.endsWith('.cpp') || n.endsWith('.c') ||
        n.endsWith('.java') || n.endsWith('.py') ||
        n.endsWith('.js')) {
      return Icons.code_rounded;
    }
    if (n.endsWith('.txt') || n.endsWith('.md'))                  return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
  }

  static Color _colorFor(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.pdf'))                                       return Colors.red;
    if (n.endsWith('.cpp') || n.endsWith('.c') ||
        n.endsWith('.java') || n.endsWith('.py') ||
        n.endsWith('.js')) {
      return Colors.blue;
    }
    if (n.endsWith('.txt') || n.endsWith('.md'))                  return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) => _BaseTile(
        icon:      _iconFor(name),
        iconColor: _colorFor(name),
        label:     name,
        onTap:     onTap,
      );
}

class _BaseTile extends StatelessWidget {
  final IconData     icon;
  final Color        iconColor;
  final String       label;
  final VoidCallback onTap;

  const _BaseTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin:  const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        height:  65,
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style:    AppTextStyles.listItem,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}