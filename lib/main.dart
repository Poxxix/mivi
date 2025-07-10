
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mivi/app.dart';
import 'package:mivi/presentation/providers/theme_provider.dart';
import 'package:mivi/data/services/notification_service.dart';
import 'package:mivi/data/services/guest_service.dart';
import 'package:mivi/core/services/ai_chat_history_service.dart';
import 'package:mivi/core/services/view_analytics_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// void main() {
//   runApp(const MiviApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://wwmxswvrdjrblafzddti.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3bXhzd3ZyZGpyYmxhZnpkZHRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MjI3ODEsImV4cCI6MjA2NzA5ODc4MX0.sirXBrB4ZNeMCKp3Jo4d75nS2tEYMx50AdQS6Xepfm0',
  );
  
  // Initialize guest service
  await GuestService().initialize();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Initialize AI chat history service
  await AIChatHistoryService.instance.initialize();
  
  // Initialize view analytics service
  await ViewAnalyticsService.instance.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MiviApp(),
    ),
  );
}
