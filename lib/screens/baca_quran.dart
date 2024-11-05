import 'package:flutter/material.dart';

class BacaQuranPage extends StatelessWidget {
  const BacaQuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baca Quran'),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Baca Quran.'),
      ),
    );
  }
}
