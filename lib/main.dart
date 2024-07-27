import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api/suno_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Generator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'CustomFont',
      ),
      home: MusicGeneratorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicGeneratorScreen extends StatefulWidget {
  @override
  _MusicGeneratorScreenState createState() => _MusicGeneratorScreenState();
}

class _MusicGeneratorScreenState extends State<MusicGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  List<dynamic> _songs = [];
  bool _isPlaying = false;
  String? _playingSongUrl;
  late AudioPlayer _audioPlayer;
  late SunoApi _sunoApi;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _sunoApi = SunoApi();
    _sunoApi.init(
        '_cfuvid=NRSn.vNEVxWN2NM5LVLkVgS2JSlXI9YuO5Fmnorjbuk-1718693099122-0.0.1.1-604800000; ajs_anonymous_id=d8f227b9-619c-40d4-b5b7-fcb80095b64b; __cf_bm=JBkcLOTiN0.4v5v50idb_EWx5EV74LVPWR28UqehSJo-1718734928-1.0.1.1-1YgOOqdLmtU7sHLPZRz_O0aqymVTemEi7zG6Ufnc6KqGI2o24afdLq5jCjtkBMX2AKOYCE8NZ29QWPZTScEzWA; __client=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImNsaWVudF8yaTQxSEN1clFCNnpFUmpXQ1UyVlA4RDJQaXQiLCJyb3RhdGluZ190b2tlbiI6Imw1N3BsaTVmMGRnb2ZrdmM4NTJ5N2RkMXVrbWVieHowZHAzbnJlNWEifQ.Xm4nskrTpS5htHgxNYftPMgk3HXPfaTTj7cScLRe9usq0QtbNCT-L5bjEmcHIhztYkFwWCf2h3HnnBmtsgfU4bX8tbIrvXDvqvjFy5eKxXmhI4PvJNVaDxh5BMgzeDPtWHgoL7w-r2n4jn9LqkeLSoXJwDMMPBE6R5AsSsFO2a_fU9BpGWdW2IQF3ypOqR7sM9T0kuQDYgAQmp6LaMrWc9lwGDeyVpVxBXIVunxIqwxlzShhiomuHK4a9AxDMZn3X0PcPZ9Npb6Wwsf3HT3dtBMn4oJEhFtSxCTGFsev_uyDkZp8QQjYT2-boUMWessRyWVnLf9VDky_zOCIjpz7Jg; __client_uat=1718734952; mp_26ced217328f4737497bd6ba6641ca1c_mixpanel=%7B%22distinct_id%22%3A%20%221f1e86df-d75b-4722-92dd-07d4f1c49e2c%22%2C%22%24device_id%22%3A%20%221902a176e742391-0ee5ba25c4caf9-19525637-157188-1902a176e742391%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22%24initial_referrer%22%3A%20%22https%3A%2F%2Fwww.google.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22www.google.com%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpus%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpu%22%3A%20%7B%7D%2C%22__mpr%22%3A%20%5B%5D%2C%22__mpap%22%3A%20%5B%5D%2C%22%24user_id%22%3A%20%221f1e86df-d75b-4722-92dd-07d4f1c49e2c%22%7D'); // Replace with your actual cookie
  }

  Future<void> _generateSong() async {
    FocusScope.of(context).unfocus(); // Hide the keyboard
    setState(() {
      _isLoading = true; // Show the loader
    });

    final String prompt = _promptController.text;
    final String style = _styleController.text;

    try {
      final songs =
          await _sunoApi.generateSong(prompt, style, SunoApi.defaultModel);
      if (songs.isNotEmpty) {
        setState(() {
          _songs = songs;
        });
      } else {
        setState(() {
          _songs = []; // Clear the list if no songs are returned
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _songs = []; // Clear the list if there's an error
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide the loader
      });
    }
  }

  Future<void> _playSong(String url) async {
    if (_isPlaying && _playingSongUrl == url) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();
      setState(() {
        _isPlaying = true;
        _playingSongUrl = url;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Music Generator',
          style: GoogleFonts.pacifico(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.music_note),
            color: Colors.white,
            onPressed: () {
              // Action for music icon
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {
              // Action for settings
            },
          ),
        ],
        elevation: 10,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _promptController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Enter prompt',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _styleController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Enter music style',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : ElevatedButton(
                    onPressed: _generateSong,
                    child: Text('Generate Song'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      backgroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  return SongCard(
                    song: _songs[index],
                    isPlaying: _isPlaying &&
                        _playingSongUrl == _songs[index]['audio_url'],
                    onPlayPause: () => _playSong(_songs[index]['audio_url']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongCard extends StatelessWidget {
  final Map<String, dynamic> song;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const SongCard({
    Key? key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              song['image_url'] ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: Icon(
                  Icons.music_note,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song['title']?.toString().isNotEmpty == true
                      ? song['title']
                      : (song['metadata']['prompt'] ?? 'Unknown')
                          .toString()
                          .split(' ')
                          .map((word) =>
                              word[0].toUpperCase() + word.substring(1))
                          .join(' '),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song["metadata"]["tags"]
                      .toString()
                      .split(' ')
                      .map((word) => word[0].toUpperCase() + word.substring(1))
                      .join(' '),
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 30,
            ),
            onPressed: onPlayPause,
          ),
        ],
      ),
    );
  }
}
