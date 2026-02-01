import 'package:flutter/material.dart';
import 'package:jobpilot/screens/auth_screen.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: const JobPilotApp(),
    ),
  );
}

class JobPilotApp extends StatelessWidget {
  const JobPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Pilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}










/*import 'package:flutter/material.dart';
import 'package:jobpilot/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
    );
  }
}*/

