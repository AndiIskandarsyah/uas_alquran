import 'package:flutter/material.dart';
import 'screens/baca_quran.dart';
import 'screens/terakhir_baca.dart';
import 'screens/pencarian.dart';
import 'screens/jadwal_sholat.dart';
import 'screens/pengaturan.dart';

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

class QuranHomePage extends StatelessWidget {
  const QuranHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the common button size
    double buttonWidth = 250;
    double buttonHeight = 50;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg', // Place your background image here
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
                  'assets/quran.png', // Place your Qur'an image here
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
                        MaterialPageRoute(builder: (context) => const BacaQuranPage()),
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
                        MaterialPageRoute(builder: (context) => const TerakhirBacaPage()),
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
                        MaterialPageRoute(builder: (context) => const PencarianPage()),
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
                        MaterialPageRoute(builder: (context) => const JadwalSholatPage()),
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
                        MaterialPageRoute(builder: (context) => const PengaturanPage()),
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
