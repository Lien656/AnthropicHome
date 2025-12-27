import 'package:flutter/material.dart';
import 'chat/chat_screen.dart';

void main() {
  runApp(const AnthropicHomeApp());
}

class AnthropicHomeApp extends StatelessWidget {
  const AnthropicHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}