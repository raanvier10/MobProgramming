import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontDisplay =
      'PlusJakartaSans'; // Using as heading (TT Commons Pro fallback)
  static const String _fontBody = 'PlusJakartaSans';

  // Display / Heading scale (TT Commons Pro equivalent)
  static const TextStyle displayXl = TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.02 * 32,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayLg = TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.02 * 28,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.02 * 24,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  // Body scale (Plus Jakarta Sans)
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Label scale
  static const TextStyle labelLg = TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: _fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: _fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  // Price style
  static const TextStyle price = TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.primary500,
  );

  static const TextStyle priceLg = TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.primary500,
  );

  // App Bar title
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _fontDisplay,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Button styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
}
