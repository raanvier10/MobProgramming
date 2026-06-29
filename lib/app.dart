import 'package:flutter/material.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';

class NgekosinApp extends StatelessWidget {
  const NgekosinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ngekos.in',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.light,
      home: const OnboardingPage(),
    );
  }
}
