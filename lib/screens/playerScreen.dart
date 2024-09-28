import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/playerProvider.dart';

class PlayerScreen extends StatefulWidget {
  final String voicePath;
  const PlayerScreen({required this.voicePath,super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late PlayerProvider playerProvider;

  @override
  void initState() {
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.initRecordedVoiceFile(recordedVoicePath: widget.voicePath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player Screen"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Timer Display for Position
            ValueListenableBuilder<String>(
              valueListenable: playerProvider.positionText,
              builder: (context, formattedTime, child) {
                return Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),

            // Play/Pause button
            ValueListenableBuilder<bool>(
              valueListenable: playerProvider.isPlaying,
              builder: (context, isPlaying, child) {
                return ElevatedButton.icon(
                  onPressed: () {
                    playerProvider.toggleVoicePlayPause();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    isPlaying ? "Pause" : "Play",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            // Echo Control Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Echo", style: TextStyle(color: Colors.white, fontSize: 18)),
                Slider(
                  value: playerProvider.echo,
                  onChanged: (value) {
                    setState(() {
                      playerProvider.updateEchoValue(value);
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.orangeAccent,
                  inactiveColor: Colors.white,
                ),
              ],
            ),

            // Reverb Control Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Reverb", style: TextStyle(color: Colors.white, fontSize: 18)),
                Slider(
                  value: playerProvider.reverb,
                  onChanged: (value) {
                   playerProvider.updateReverbValue(value);
                  },
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.orangeAccent,
                  inactiveColor: Colors.white,
                ),
              ],
            ),

            // Volume Control Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Volume", style: TextStyle(color: Colors.white, fontSize: 18)),
                Slider(
                  value: playerProvider.vocalVolume,
                  onChanged: (value) {
                    setState(() {
                      playerProvider.vocalVolume = value;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.orangeAccent,
                  inactiveColor: Colors.white,
                ),
              ],
            ),

            // Slider to show playback progress
            ValueListenableBuilder<Duration>(
              valueListenable: playerProvider.soundPosition,
              builder: (context, position, child) {
                return Slider(
                  value: position.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    // Add functionality to seek playback if necessary
                  },
                  min: 0.0,
                  max: playerProvider.soundLength.inMilliseconds.toDouble(),
                  activeColor: Colors.orangeAccent,
                  inactiveColor: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
