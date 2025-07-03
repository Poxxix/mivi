import 'package:flutter/material.dart';
import 'package:mivi/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// void main() {
//   runApp(const MiviApp());
// }

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://wwmxswvrdjrblafzddti.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3bXhzd3ZyZGpyYmxhZnpkZHRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MjI3ODEsImV4cCI6MjA2NzA5ODc4MX0.sirXBrB4ZNeMCKp3Jo4d75nS2tEYMx50AdQS6Xepfm0',
  );
  runApp(const MiviApp());
}
