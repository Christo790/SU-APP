import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final heading = GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static final appBarTitle = GoogleFonts.fredoka(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 1,
  );

  static final boxLabel = GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static final sectionLabel = GoogleFonts.fredoka(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.subtle,
  );

  static final listItem = GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static final body = GoogleFonts.publicSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.muted,
  );

  static final tileLabel = GoogleFonts.publicSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );
}