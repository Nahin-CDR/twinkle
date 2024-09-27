import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twinkle/providers/recordProvider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/enums.dart';
import '../widgets/recordButton.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late RecordProvider recordProvider;

  @override
  void initState() {
    recordProvider = Provider.of<RecordProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Screen"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Timer Display
            ValueListenableBuilder<String>(
              valueListenable: recordProvider.formattedTime,
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
            // Slider to show sound position
            ValueListenableBuilder<Duration>(
              valueListenable: recordProvider.soundPosition,
              builder: (context, soundPosition, child) {
                return Slider(
                  value: soundPosition.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    // You can add functionality to seek recording if needed
                  },
                  min: 0.0,
                  max: 60000.0, // Assuming a max length of 60 seconds
                  activeColor: Colors.orangeAccent,
                  inactiveColor: Colors.white,
                );
              },
            ),
            // Recording control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start/Resume Recording Button
                // recordButton(
                //   recordProvider,
                //   screenSize
                // ),
                ElevatedButton(
                  onPressed: () {
                    recordProvider.toggleRecordButton();
                    // recordProvider.voiceRecorderStatus.value == RecorderStatus.recording
                    //     ? recordProvider.pauseVoiceRecording()
                    //     : recordProvider.startVoiceRecording();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: ValueListenableBuilder<RecorderStatus>(
                    valueListenable: recordProvider.voiceRecorderStatus,
                    builder: (BuildContext context, RecorderStatus value, Widget? child) {
                      return Text(
                        value == RecorderStatus.recording ? 'Pause' : 'Record',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    })
                ),
                // Stop Recording Button
                ElevatedButton(
                  onPressed: () {
                    recordProvider.stopVoiceRecording();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Stop',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            // Delete recording button
            ElevatedButton.icon(
              onPressed: () {
                recordProvider.deleteRecordedFile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black45,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'Delete Recording',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

