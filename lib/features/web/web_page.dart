import 'package:flutter/material.dart';

class WebPage extends StatelessWidget {
  const WebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈페이지')),
      body: const Center(child: Text('홈페이지 연결(더미)')),
    );
  }
}
