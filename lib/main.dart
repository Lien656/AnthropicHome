import 'package:flutter/material.dart';
import 'chat/chat_screen.dart';
import 'storage/local_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.init();
  runApp(const AnthropicHome());
}

class AnthropicHome extends StatelessWidget {
  const AnthropicHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anthropic Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2D2D2D),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}