import 'package:flutter/material.dart';

class JadwalSholatPage extends StatelessWidget {
  const JadwalSholatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Jadwal Sholat.'),
      ),
    );
  }
}