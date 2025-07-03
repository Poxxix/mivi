import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mivi/presentation/core/app_theme.dart';
import 'package:mivi/presentation/navigation/app_router.dart';
import 'package:mivi/presentation/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MiviApp extends StatelessWidget {
  const MiviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Mivi',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
