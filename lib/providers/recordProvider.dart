import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../constants/enums.dart';

class RecordProvider with ChangeNotifier{
  // when the full song played the recording should be automatically stopped

  final audioRecorderNew = AudioRecorder();
  String recordedAudioPath = "";
  bool recordingVoice = false;
  bool isDownloadingKaraokeFile = false;
  bool isKaraokeMusicReadyToPlay = false;
  String karaokeMusicPath = "";
  Duration duration = Duration.zero;



  ValueNotifier<RecorderStatus> voiceRecorderStatus = ValueNotifier(RecorderStatus.stopped);

  void toggleRecordButton(){

    switch(voiceRecorderStatus.value){
      case RecorderStatus.paused:
        resumeVoiceRecording();
        break;
      case RecorderStatus.recording:
        pauseVoiceRecording();
        break;
      case RecorderStatus.stopped:
        startVoiceRecording();
        break;
      default:
        break;
    }
    if(kDebugMode){
      print("Recording status : ${voiceRecorderStatus.value}");
    }
  }
  Future<void> startVoiceRecording() async {
    try{
      final isSupported = await audioRecorderNew.isEncoderSupported(AudioEncoder.aacLc);
      if (kDebugMode) {
        print("${AudioEncoder.aacLc.name} supported : $isSupported");
        print("************ Recording started from recordProvider *********** ");
      }
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/audio0_${DateTime.now().millisecondsSinceEpoch}.wav';

      Timer(const Duration(milliseconds: 10), () async {
        await audioRecorderNew.start(
          const RecordConfig(
              noiseSuppress: true,
              encoder: AudioEncoder.wav,
              bitRate: 128000,//32000,
              echoCancel: true
          ),
          path: path,
        );
      });
      recordingVoice = true;
      voiceRecorderStatus.value = RecorderStatus.recording;
      startTimer();
      notifyListeners();
    }catch(e) {
      if(kDebugMode){
        print("Error occurred : $e");
      }
    }
  }
  Future<void>stopVoiceRecording() async {
    final path = await audioRecorderNew.stop();
    if(path != null) {
      recordedAudioPath = path;
      notifyListeners();
      if (kDebugMode) {
        print("recordedAudioPath : $recordedAudioPath");
      }
    }else{
      if(kDebugMode){
        print("\n\nError stopping recording\n\n");
      }
    }
    voiceRecorderStatus.value = RecorderStatus.stopped; // status updated of voice recording
    notifyListeners();
  }
  Future<void> pauseVoiceRecording() async {
    await audioRecorderNew.pause();
    voiceRecorderStatus.value = RecorderStatus.paused; // status updated of recording
    notifyListeners();
    if (kDebugMode) {
      print("************ Recording PAUSED from recordProvider *********** ");
    }
    stopTimer();
    notifyListeners();
  }

  Future<void> resumeVoiceRecording() async {
    await audioRecorderNew.resume();
    voiceRecorderStatus.value = RecorderStatus.recording; // status updated of voice recording
    if (kDebugMode) {
      print("************ Recording RESUMED from recordProvider *********** ");
    }
    startTimer();
    notifyListeners();
  }


  void backToInitialStateOfRecording() {
    recordingVoice = false;
    notifyListeners();
  }









  // code to delete recorded voice
  Future<void> deleteRecordedFile() async {
    if(voiceRecorderStatus.value != RecorderStatus.stopped){
      Fluttertoast.showToast(msg: 'you need to stop recording first');
      return;
    }
    if (recordedAudioPath.isNotEmpty) {
      final file = File(recordedAudioPath);
      try {
        if (await file.exists()) {
          await file.delete();
          if (kDebugMode) {
            print("File deleted: $recordedAudioPath");
          }
        }
        Fluttertoast.showToast(
            msg: "recorded voice deleted",
            backgroundColor: Colors.teal
        );
      } catch (e) {
        if (kDebugMode) {
          print("Error deleting file: $e");
        }
      }
    }
  }





  // =================================================================================================
  // now its time to write coder for download the karaoke file to cache
  // which will be played in recording voice








  // Play karaoke from cache with soLoud ===============================================================












  Timer? _timer;

  final ValueNotifier<Duration> soundPosition = ValueNotifier(Duration.zero);
  final ValueNotifier<String> formattedTime = ValueNotifier("");

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      soundPosition.value = Duration(seconds: soundPosition.value.inSeconds + 1);
      updatePosition();
    });
  }
  void updatePosition(){
    formattedTime.value = '${soundPosition.value.inMinutes}:${(soundPosition.value.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void stopTimer() {
    _timer?.cancel();
  }
}
