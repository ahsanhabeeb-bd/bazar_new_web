import 'dart:async';

import 'package:bazar_new_web/firebase_options.dart';
import 'package:bazar_new_web/provider/category_provider.dart';
import 'package:bazar_new_web/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensure bindings are initialized

  await runZonedGuarded(
    () async {
      // ✅ Run in the correct zone
      await Firebase.initializeApp(
        options:
            DefaultFirebaseOptions
                .currentPlatform, // ✅ Use correct Firebase options
      );

      runApp(const MyApp());
    },
    (error, stack) {
      print("Error in Firebase Initialization: $error"); // Debugging errors
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CategoryProvider()..fetchCategories(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'oboefbazar',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
