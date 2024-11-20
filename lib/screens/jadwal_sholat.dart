import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class DropdownPage extends StatefulWidget {
  @override
  _DropdownPageState createState() => _DropdownPageState();
}

class _DropdownPageState extends State<DropdownPage> {
  List<dynamic> lokasiList = []; // Menyimpan data lokasi
  String? selectedLokasi; // Menyimpan ID lokasi yang dipilih
  List<dynamic> jadwalSholat = []; // Menyimpan data jadwal sholat
  String? selectedMonth; // Menyimpan bulan yang dipilih
  String? selectedYear; // Menyimpan tahun yang dipilih
  bool isLoading = false; // Indikator saat data sedang diambil

  @override
  void initState() {
    super.initState();
    _loadLokasiData(); // Memuat data lokasi
  }

  // Fungsi untuk memuat data lokasi dari file JSON
  Future<void> _loadLokasiData() async {
    final String response = await rootBundle.loadString('assets/lokasi.json');
    final data = json.decode(response);
    setState(() {
      lokasiList = data;
    });
  }

  // Fungsi untuk mengambil jadwal sholat berdasarkan kota, tahun, dan bulan
  Future<void> _fetchJadwalSholat(String kotaId, String tahun, String bulan) async {
    setState(() {
      isLoading = true; // Memulai indikator loading
    });

    final response = await http.get(
      Uri.parse('https://api.myquran.com/v2/sholat/jadwal/$kotaId/$tahun/$bulan'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        jadwalSholat = data['data']['jadwal'];
        isLoading = false; // Selesai mengambil data
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat jadwal sholat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Dropdown untuk memilih kota
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Kota',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedLokasi,
                      items: lokasiList.map((lokasi) {
                        return DropdownMenuItem<String>(
                          value: lokasi['id'],
                          child: Text(lokasi['lokasi']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLokasi = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Dropdown untuk memilih bulan
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Bulan',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedMonth,
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem<String>(
                          value: (index + 1).toString().padLeft(2, '0'),
                          child: Text('${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Dropdown untuk memilih tahun
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Tahun',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedYear,
                      items: ['2024', '2025'].map((year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Tombol untuk memuat jadwal sholat
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Tampilkan Jadwal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (selectedLokasi != null && selectedMonth != null && selectedYear != null) {
                          _fetchJadwalSholat(selectedLokasi!, selectedYear!, selectedMonth!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pilih semua opsi terlebih dahulu!'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Indikator saat memuat data
            if (isLoading) const CircularProgressIndicator(),

            // Menampilkan jadwal sholat jika ada
            if (jadwalSholat.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: jadwalSholat.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final jadwal = jadwalSholat[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ListTile(
                        title: Text(jadwal['tanggal']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Imsak: ${jadwal['imsak']}'),
                            Text('Subuh: ${jadwal['subuh']}'),
                            Text('Dzuhur: ${jadwal['dzuhur']}'),
                            Text('Ashar: ${jadwal['ashar']}'),
                            Text('Maghrib: ${jadwal['maghrib']}'),
                            Text('Isya: ${jadwal['isya']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Pesan jika jadwal kosong
            if (!isLoading && jadwalSholat.isEmpty)
              const Text(
                'Pilih kota, bulan, dan tahun untuk melihat jadwal sholat.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
