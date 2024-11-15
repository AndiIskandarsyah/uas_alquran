import 'package:flutter/material.dart';

class PencarianPage extends StatefulWidget {
  final List<dynamic> daftarSurat;

  const PencarianPage({super.key, required this.daftarSurat});

  @override
  State<PencarianPage> createState() => _PencarianPageState();
}

class _PencarianPageState extends State<PencarianPage> {
  String _searchTerm = '';
  bool _isSpecificSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencarian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  _searchTerm = text;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari Surah...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _searchTerm = '';
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Opsi Pencarian:'),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('MENDEKATI'),
                      selected: !_isSpecificSearch,
                      onSelected: (value) {
                        setState(() {
                          _isSpecificSearch = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8.0),
                    ChoiceChip(
                      label: const Text('SPESIFIK'),
                      selected: _isSpecificSearch,
                      onSelected: (value) {
                        setState(() {
                          _isSpecificSearch = true;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_searchTerm.isNotEmpty)
            _buildSearchResult()
          else
            const Expanded(
              child: Center(
                child: Text('Masukkan kata kunci pencarian'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResult() {
    final searchResult = _searchTerm.toLowerCase();
    final filteredSurat = widget.daftarSurat.where((surat) =>
        surat['name'].toLowerCase().contains(searchResult) ||
        surat['name_translations']['ar']
            .toLowerCase()
            .contains(searchResult) ||
        surat['name_translations']['id']
            .toLowerCase()
            .contains(searchResult));

    if (filteredSurat.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('Surah tidak ditemukan'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredSurat.length,
        itemBuilder: (context, index) {
          final surat = filteredSurat.elementAt(index);
          return ListTile(
            title: Text(surat['name']),
            onTap: () {
              // Navigasi ke halaman detail surah
              // ...
            },
          );
        },
      ),
    );
  }
}
