import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mivi/presentation/core/app_themes.dart';
import 'package:mivi/presentation/navigation/app_router.dart';
import 'package:mivi/presentation/providers/enhanced_theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MiviApp extends StatelessWidget {
  const MiviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EnhancedThemeProvider(),
      child: Consumer<EnhancedThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Mivi',
            theme: themeProvider.themeData,
            themeMode: ThemeMode.light, // Always use light mode since we handle themes internally
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
