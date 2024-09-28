
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';


class PlayerProvider with ChangeNotifier{

  String cacheMusic = "";

  final Logger _log = Logger('RecordProvider');
  AudioSource? voiceAudioSource;
  SoundHandle? voiceHandle;
  double echo = 0.0;
  double reverb = 0.0;
  double vocalVolume = 1.0;
  bool isPlayingKaraoke = false;
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> soundPosition = ValueNotifier(Duration.zero);
  late Duration soundLength = Duration.zero;
  StreamSubscription<StreamSoundEvent>? subscription;

  void updateEchoValue(double updatedValue) {
    if (kDebugMode) {
      print("Updated ECHO value : $updatedValue");
    }
    if(voiceAudioSource != null){
      final voiceSoundFilter = voiceAudioSource!.filters.echoFilter;
      voiceSoundFilter.wet(soundHandle: voiceHandle).value = updatedValue;
      echo = updatedValue;
    }
    notifyListeners();
  }
  void updateReverbValue(double value){
    if(reverb != value){
      reverb = value;

    }
  }

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

    }
    try {
      voiceAudioSource = await SoLoud.instance.loadFile(recordedVoicePath);
      if (voiceAudioSource != null) {
        soundLength = SoLoud.instance.getLength(voiceAudioSource!);
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
      voiceHandle = await SoLoud.instance.play(voiceAudioSource!,paused: true); // Initially paused

      SoLoud.instance.setVolume(voiceHandle!, 1);
      //  SoLoud.instance.setVolume(musicHandle!, equalizer.musicVolume*0.01);
      /*
       => make a filter
       => activate the filter
       =>
       */

      final voiceSoundFilter = voiceAudioSource!.filters.echoFilter;
      if(!voiceSoundFilter.isActive){
        voiceSoundFilter.activate();
      }
      voiceSoundFilter.wet(soundHandle: voiceHandle).value = echo;

      if (kDebugMode) {
        print("activated echo filter $echo");
      }

      subscription = voiceAudioSource!.soundEvents.listen((eventResult) {
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

  // just for demo purposes not implemented
  Future<void> playMultipleSoundsWithEffects() async {
    //await initialize();

    // Load two different audio files
    AudioSource sound1 = await SoLoud.instance.loadAsset('assets/audio/sound1.mp3');
    AudioSource sound2 = await SoLoud.instance.loadAsset('assets/audio/sound2.mp3');

    // Create separate filters for each sound
    final filter1 = sound1.filters.echoFilter;
    final filter2 = sound2.filters.freeverbFilter;

    // Activate filters before playing the sounds
    filter1.activate();
    filter2.activate();

    // Play the sounds with separate filters applied
    final h1 = await SoLoud.instance.play(sound1);
    final h2 = await SoLoud.instance.play(sound2);

    // Set distinct filter values
    const echoValue = 0.5;
    const reverbValue = 0.7;

    // Apply echo effect to sound1
    filter1.wet(soundHandle: h1).value = echoValue;
    filter1.wet(soundHandle: h1).oscillateFilterParameter(
      from: 0.1,
      to: 1.0,
      time: const Duration(seconds: 3),
    );

    // Apply reverb effect to sound2
    filter2.wet(soundHandle: h2).value = reverbValue;
    filter2.wet(soundHandle: h2).oscillateFilterParameter(
      from: 0.2,
      to: 1.5,
      time: const Duration(seconds: 4),
    );

    //await delay(6000); // Let both sounds play with their effects

    // Deactivate filters
    filter1.deactivate();
    filter2.deactivate();

  }


}