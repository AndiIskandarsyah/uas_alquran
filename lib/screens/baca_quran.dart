import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({Key? key}) : super(key: key);

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  List<dynamic> surahList = [];
  List<dynamic> filteredSurahList = [];
  bool isLoading = true;
  String searchQuery = '';
  Map<String, dynamic>? bookmarkedSurah;
  String? currentlyPlayingUrl;

  // Global Audio Player to be shared across all AudioPlayerWidget
  final AudioPlayer _globalAudioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchSurahData();
    _loadBookmark(); // Load bookmark saat aplikasi dimulai
  }

  @override
  void dispose() {
    _globalAudioPlayer.dispose();
    super.dispose();
  }

  Future<void> fetchSurahData() async {
    const url = 'https://quran-api.santrikoding.com/api/surah';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          surahList = json.decode(response.body);
          filteredSurahList = surahList; // Salin daftar awal
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterSurahList(String query) {
    setState(() {
      searchQuery = query;
      filteredSurahList = surahList.where((surah) {
        final namaLatin = surah['nama_latin']?.toLowerCase() ?? '';
        final arti = surah['arti']?.toLowerCase() ?? '';
        final deskripsi =
            _stripHtmlTags(surah['deskripsi']?.toLowerCase() ?? '');
        return namaLatin.contains(query.toLowerCase()) ||
            arti.contains(query.toLowerCase()) ||
            deskripsi.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    if (bookmarkedSurah != null) {
      await prefs.setString('bookmarkedSurah', json.encode(bookmarkedSurah));
    }
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkData = prefs.getString('bookmarkedSurah');
    if (bookmarkData != null) {
      setState(() {
        bookmarkedSurah = json.decode(bookmarkData);
      });
    }
  }

  void _showBookmarkedSurahDetails() {
    if (bookmarkedSurah != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(bookmarkedSurah!['nama_latin']),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Arti: ${bookmarkedSurah!['arti']}'),
                  Text('Jumlah Ayat: ${bookmarkedSurah!['jumlah_ayat']}'),
                  Text('Tempat Turun: ${bookmarkedSurah!['tempat_turun']}'),
                  const SizedBox(height: 8),
                  Text(
                    'Deskripsi:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_stripHtmlTags(bookmarkedSurah!['deskripsi'])),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada surah yang dibookmark')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Surah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _showBookmarkedSurahDetails,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: _filterSurahList,
              decoration: InputDecoration(
                hintText: 'Cari surah...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredSurahList.length,
              itemBuilder: (context, index) {
                final surah = filteredSurahList[index];
                return AudioPlayerWidget(
                  title: surah['nama_latin'],
                  audioUrl: surah['audio'],
                  arti: surah['arti'],
                  jumlahAyat: surah['jumlah_ayat'],
                  tempatTurun: surah['tempat_turun'],
                  deskripsi: _stripHtmlTags(surah['deskripsi']),
                  globalAudioPlayer: _globalAudioPlayer,
                  currentlyPlayingUrl: currentlyPlayingUrl,
                  onPlayingChanged: (url) {
                    setState(() {
                      currentlyPlayingUrl = url;
                      bookmarkedSurah = surah;
                      _saveBookmark();
                    });
                  },
                );
              },
            ),
    );
  }

  // Fungsi untuk menghapus elemen HTML
  String _stripHtmlTags(String htmlText) {
    final document = html_parser.parse(htmlText);
    return document.body?.text ?? '';
  }
}

// Widget untuk memutar audio
class AudioPlayerWidget extends StatelessWidget {
  final String title;
  final String audioUrl;
  final String arti;
  final int jumlahAyat;
  final String tempatTurun;
  final String deskripsi;
  final AudioPlayer globalAudioPlayer;
  final String? currentlyPlayingUrl;
  final ValueChanged<String?> onPlayingChanged;

  const AudioPlayerWidget({
    Key? key,
    required this.title,
    required this.audioUrl,
    required this.arti,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.deskripsi,
    required this.globalAudioPlayer,
    required this.currentlyPlayingUrl,
    required this.onPlayingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(title),
        subtitle: Text('Arti: $arti (${tempatTurun})'),
        trailing: IconButton(
          icon: Icon(
            currentlyPlayingUrl == audioUrl ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () {
            if (currentlyPlayingUrl == audioUrl) {
              globalAudioPlayer.pause();
              onPlayingChanged(null);
            } else {
              globalAudioPlayer.setUrl(audioUrl).then((_) {
                globalAudioPlayer.play();
                onPlayingChanged(audioUrl);
              });
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jumlah Ayat: $jumlahAyat',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deskripsi:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(deskripsi),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
