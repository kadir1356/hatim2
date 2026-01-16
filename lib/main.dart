import 'package:flutter/material.dart';
import 'screens/web_shell_screen.dart';

/// POCKET HATIM - WEBVIEW SHELL VERSION
/// This is a minimal Android APK that loads the web version in a WebView
/// All features are handled by the web app - no Firebase, no complex Android build
/// Updates to the web app are instant - no need to rebuild APK

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Hatim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const WebShellScreen(),
    );
  }
}
