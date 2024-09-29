# twinkle


Twinkle is an innovative voice recording app built with Flutter, featuring real-time audio effects using the powerful flutter_soloud package. Users can easily record their voice, play it back, and customize their recordings by adding echo effects. Experience seamless audio manipulation with a simple and intuitive interface!


```

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
```