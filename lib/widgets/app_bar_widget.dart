import 'package:flutter/material.dart';
import 'package:su/core/constants/app_colors.dart';
import 'package:su/core/constants/app_text_styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarWidget(this.title, {super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      automaticallyImplyLeading: false,
      title: Text(title, style: AppTextStyles.appBarTitle),
    );
  }
}