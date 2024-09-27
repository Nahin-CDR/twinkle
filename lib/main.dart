import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twinkle/providers/playerProvider.dart';
import 'package:twinkle/providers/recordProvider.dart';
import 'package:twinkle/screens/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=> RecordProvider()),
          ChangeNotifierProvider(create: (context)=> PlayerProvider())
        ],
      child: MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.tealAccent.shade400,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            sliderTheme: const SliderThemeData(
              trackHeight: 1,
              thumbColor:  Colors.blueGrey,
              activeTrackColor:  Colors.blueGrey,
              inactiveTrackColor:  Colors.green,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayColor:  Colors.blueGrey,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor:  Colors.black,
                unselectedItemColor:  Colors.white
            ),
            colorScheme: const ColorScheme.dark(
              primary:  Colors.green,
            )
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen() ,
      ),  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen.  // Replace with your main screen
    );
  }
}

