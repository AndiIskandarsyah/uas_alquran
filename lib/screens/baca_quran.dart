import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:html/parser.dart' as html_parser;

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({Key? key}) : super(key: key);

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  List<dynamic> surahList = [];
  bool isLoading = true;

  // Global Audio Player to be shared across all AudioPlayerWidget
  final AudioPlayer _globalAudioPlayer = AudioPlayer();
  String? currentlyPlayingUrl;

  @override
  void initState() {
    super.initState();
    fetchSurahData();
  }

  Future<void> fetchSurahData() async {
    const url = 'https://quran-api.santrikoding.com/api/surah';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          surahList = json.decode(response.body);
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

  @override
  void dispose() {
    _globalAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Surah'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: surahList.length,
              itemBuilder: (context, index) {
                final surah = surahList[index];
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

class AudioPlayerWidget extends StatefulWidget {
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
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late Stream<bool> _isPlayingStream;

  @override
  void initState() {
    super.initState();
    _isPlayingStream = widget.globalAudioPlayer.playingStream.map((playing) {
      return widget.currentlyPlayingUrl == widget.audioUrl && playing;
    });
  }

  void _playAudio() async {
    try {
      if (widget.currentlyPlayingUrl != widget.audioUrl) {
        await widget.globalAudioPlayer.stop();
        widget.onPlayingChanged(null);
      }
      await widget.globalAudioPlayer.setUrl(widget.audioUrl);
      await widget.globalAudioPlayer.play();
      widget.onPlayingChanged(widget.audioUrl);
    } catch (e) {
      debugPrint('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to play audio')),
      );
    }
  }

  void _pauseAudio() async {
    try {
      await widget.globalAudioPlayer.pause();
      widget.onPlayingChanged(null);
    } catch (e) {
      debugPrint('Error pausing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to pause audio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: StreamBuilder<bool>(
        stream: _isPlayingStream,
        builder: (context, snapshot) {
          final isPlaying = snapshot.data ?? false;
          return ExpansionTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.blue),
                  onPressed: _playAudio,
                ),
                IconButton(
                  icon: const Icon(Icons.pause, color: Colors.orange),
                  onPressed: _pauseAudio,
                ),
              ],
            ),
            title: Text(widget.title),
            subtitle: Text('Arti: ${widget.arti} (${widget.tempatTurun})'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumlah Ayat: ${widget.jumlahAyat}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deskripsi:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.deskripsi),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
