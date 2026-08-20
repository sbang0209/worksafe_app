import 'package:flutter/material.dart';

import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WorkSafe')),
      body: Center(
        child: FilledButton.icon(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CameraScreen()));
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('촬영하기'),
        ),
      ),
    );
  }
}
