import 'package:flutter/material.dart';
import 'package:mivi/presentation/core/app_theme.dart';
import 'package:mivi/presentation/navigation/app_router.dart';

class MiviApp extends StatelessWidget {
  const MiviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mivi',
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
} 