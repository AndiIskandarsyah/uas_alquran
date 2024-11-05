import 'package:flutter/material.dart';

class TerakhirBacaPage extends StatelessWidget {
  const TerakhirBacaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terakhir Baca'),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Terakhir Baca.'),
      ),
    );
  }
}
