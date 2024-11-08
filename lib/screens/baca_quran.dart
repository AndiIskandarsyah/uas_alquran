import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BacaQuranPage extends StatefulWidget {
  const BacaQuranPage({super.key});

  @override
  State<BacaQuranPage> createState() => _BacaQuranPageState();
}

class _BacaQuranPageState extends State<BacaQuranPage> {
  List<dynamic> daftarSurat = [];

  @override
  void initState() {
    super.initState();
    _loadSuratData();
  }

  Future<void> _loadSuratData() async {
    final String response =
        await rootBundle.loadString('assets/Quran.json'); // Bagian Json
    final data = await json.decode(response);
    setState(() {
      daftarSurat = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Qur\'an Indonesia'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SURAH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'JUZ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'BOOKMARK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: daftarSurat.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: daftarSurat.length,
              itemBuilder: (context, index) {
                final surat = daftarSurat[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 1, color: Colors.black),
                      ),
                    ),
                    child: CircleAvatar(
                      child: Text('${surat['number_of_surah']}'),
                    ),
                  ),
                  title: Text(surat['name']),
                  subtitle: Text(
                      '${surat['place']} | ${surat['number_of_ayah']} Ayat'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                  ),
                );
              },
            ),
    );
  }
}