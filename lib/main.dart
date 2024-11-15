import 'package:flutter/material.dart';
import 'screens/baca_quran.dart';
import 'screens/terakhir_baca.dart';
import 'screens/pencarian.dart';
import 'screens/jadwal_sholat.dart';
import 'screens/pengaturan.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QuranHomePage(),
    );
  }
}

class QuranHomePage extends StatefulWidget {
  const QuranHomePage({super.key});

  @override
  State<QuranHomePage> createState() => _QuranHomePageState();
}

class _QuranHomePageState extends State<QuranHomePage> {
  List<dynamic> daftarSurat = [];

  @override
  void initState() {
    super.initState();
    _loadSuratData();
  }

  Future<void> _loadSuratData() async {
  final String response = await rootBundle.loadString('assets/Quran.json');
  final data = json.decode(response);
  setState(() {
    daftarSurat = data;
  });
}


  @override
  Widget build(BuildContext context) {
    double buttonWidth = 250;
    double buttonHeight = 50;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg', // Background image path
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Quran Icon with Text
                Image.asset(
                  'assets/quran.png', // Qur'an image path
                  height: 200,
                ),
                const SizedBox(height: 20),
                // Buttons with the same size
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BacaQuranPage()),
                      );
                    },
                    child: const Text('BACA QUR\'AN'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TerakhirBacaPage()),
                      );
                    },
                    child: const Text('TERAKHIR BACA'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PencarianPage(daftarSurat: daftarSurat),
                        ),
                      );
                    },
                    child: const Text('PENCARIAN'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const JadwalSholatPage()),
                      );
                    },
                    child: const Text('JADWAL SHOLAT'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PengaturanPage()),
                      );
                    },
                    child: const Text('PENGATURAN'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
