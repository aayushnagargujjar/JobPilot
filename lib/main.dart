import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import Core
import 'package:firebase_auth/firebase_auth.dart'; // 2. Import Auth for the wrapper
import 'package:provider/provider.dart';

import 'firebase_options.dart'; // 3. Import generated options (created by flutterfire configure)
import 'theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        routes: {
          '/auth': (context) => const AuthScreen(),
        },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const MainScreen();
        },
      ),
    );
  }
}