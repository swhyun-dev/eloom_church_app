import 'package:flutter/material.dart';

class SermonPage extends StatelessWidget {
  const SermonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설교')),
      body: const Center(child: Text('설교 페이지(더미)')),
    );
  }
}