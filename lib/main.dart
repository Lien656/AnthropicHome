import 'package:flutter/material.dart';
import 'chat/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnthropicHomeApp());
}

class AnthropicHomeApp extends StatelessWidget {
  const AnthropicHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnthropicHome',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2B2B2B),
        fontFamily: 'System',
        useMaterial3: true,
      ),
      home: const SafeArea(
        child: ChatScreen(),
      ),
    );
  }
}
