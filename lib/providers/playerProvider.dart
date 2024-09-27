
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';


class PlayerProvider with ChangeNotifier{

  String cacheMusic = "";

  final Logger _log = Logger('RecordProvider');
  AudioSource? voiceSound;
  SoundHandle? voiceHandle;
  double echo = 0.0;
  double reverb = 0.0;
  double vocalVolume = 1.0;
  bool isPlayingKaraoke = false;
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> soundPosition = ValueNotifier(Duration.zero);
  late Duration soundLength = Duration.zero;
  StreamSubscription<StreamSoundEvent>? subscription;


  Future<bool>initRecordedVoiceFile({required String recordedVoicePath})async{

    if(!SoLoud.instance.isInitialized){
      await SoLoud.instance.init().then(
            (_) {
          Logger('main').info('player started');
          SoLoud.instance.setVisualizationEnabled(true);
          SoLoud.instance.setGlobalVolume(1);
          SoLoud.instance.setMaxActiveVoiceCount(32);
        },
        onError: (Object e) {
          Logger('main').severe('player starting error: $e');
        },
      );

      //SoLoud.instance.isFilterActive(FilterType.echoFilter);
      SoLoud.instance.addGlobalFilter(FilterType.echoFilter);
      SoLoud.instance.addGlobalFilter(FilterType.freeverbFilter);
      SoLoud.instance.setFilterParameter(FilterType.echoFilter, 0, echo*0.01);
      SoLoud.instance.setFilterParameter(FilterType.freeverbFilter, 0, echo*0.01);

    }

    try {
      voiceSound = await SoLoud.instance.loadFile(recordedVoicePath);
      //musicSound = await SoLoud.instance.loadFile(cachedMusicFilePath);


      // SoLoud.instance.addGlobalFilter(FilterType.echoFilter);
      // SoLoud.instance.addGlobalFilter(FilterType.freeverbFilter);
      // SoLoud.instance.setFilterParameter(FilterType.echoFilter, 0, equalizer.echo*0.01);
      // SoLoud.instance.setFilterParameter(FilterType.freeverbFilter, 0, equalizer.echo*0.01);

      if (voiceSound != null) {
        soundLength = SoLoud.instance.getLength(voiceSound!);
        prepareAndPlay();
        startTimer();
      }
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound . Ignoring.", e);
    }
    return false;
  }

  Future<void> prepareAndPlay() async {
    try {
      voiceHandle = await SoLoud.instance.play(voiceSound!,paused: true); // Initially paused
      // musicHandle = await SoLoud.instance.play(musicSound!, paused: true); // Initially paused

      SoLoud.instance.setVolume(voiceHandle!, 1);
      //  SoLoud.instance.setVolume(musicHandle!, equalizer.musicVolume*0.01);


      //startVoiceRecording();
      subscription = voiceSound!.soundEvents.listen((eventResult) {
        if (eventResult.event == SoundEventType.handleIsNoMoreValid) {
          resetPlayer();
        }
      });
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound . Ignoring.", e);
    }
  }
  void resetPlayer() {
    if(kDebugMode){
      print("\n\n=====================  resetPlayer() called ========================\n");
      print("location: playBackProvider\n");
      print("=====================  resetPlayer() called ========================\n\n");
    }

    isPlayingKaraoke = false;

    //karaokePlayer.setPlayerMode(PlayerMode.lowLatency);
    SoLoud.instance.stop(voiceHandle!);
    soundPosition.value = Duration.zero;
    isPlaying.value = false;
    prepareAndPlay(); // Reset the audio to its initial state
  }


  ValueNotifier<String> positionText = ValueNotifier('');
  Timer? timer;
  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (voiceHandle != null) {
        soundPosition.value = SoLoud.instance.getPosition(voiceHandle!);
        notifyListeners();
        if (soundPosition.value >= soundLength) {
          resetPlayer();
        }
        // lyricsController.progress = Duration(seconds: soundPosition.value.inSeconds);
        updateSoLoudPlayerPosition();
      }
      notifyListeners();
    });
  }
  updateSoLoudPlayerPosition(){
    if(voiceHandle != null){
      positionText.value = '${soundPosition.value.inMinutes}:${(soundPosition.value.inSeconds % 60).toString().padLeft(2, '0')}';
      notifyListeners();
    }
    notifyListeners();
  }


  void toggleVoicePlayPause() async {

    if (voiceHandle != null ) {
      try{
        SoLoud.instance.pauseSwitch(voiceHandle!);
        // SoLoud.instance.pauseSwitch(musicHandle!);
        isPlaying.value = !SoLoud.instance.getPause(voiceHandle!);
        if (kDebugMode) {
          print("${isPlaying.value}");
        }
      }on SoLoudException catch (e) {
        _log.severe("Cannot play sound . Ignoring.", e);
      }
    }
    notifyListeners();
  }

}