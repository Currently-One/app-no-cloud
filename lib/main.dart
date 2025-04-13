import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

import 'main/select_device_widget.dart';

void main() {
  tz.initializeTimeZones();
  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  static const marigold50 = Color.fromARGB(255, 255, 240, 219);
  static const marigold200 = Color.fromARGB(255, 255, 216, 160);
  static const marigold300 = Color.fromARGB(255, 255, 200, 121);
  static const marigold500 = Color.fromARGB(255, 255, 150, 2);
  static const neutral100 = Color.fromARGB(255, 240, 240, 239);
  static const neutral200 = Color.fromARGB(255, 221, 220, 218);
  static const neutral500 = Color.fromARGB(255, 92, 87, 81);
  static const neutral900 = Color.fromARGB(255, 32, 30, 28);
  static const neutralWhite = Colors.white;
  static const poppy200 = Color.fromARGB(255, 251, 152, 145);
  static const poppy300 = Color.fromARGB(255, 0xFB, 0x6D, 0x63);
  static const poppy400 = Color.fromARGB(255, 0xF6, 0x4E, 0x42);
  static const poppy500 = Color.fromARGB(255, 244, 16, 0);
  static const leaf200 = Color.fromARGB(255, 180, 238, 196);
  static const leaf400 = Color.fromARGB(255, 113, 221, 143);
  static const leaf500 = Color.fromARGB(255, 62, 204, 101);
  static const aqua200 = Color.fromARGB(255, 205, 236, 244);
  static const aqua400 = Color.fromARGB(255, 129, 206, 224);

  // static const usageLow =
  static const flashColorTheme = ColorScheme.light(
    surface: marigold50,
    onSurface: neutral900,
    primary: neutral900,
    onPrimary: neutral900,
    secondary: marigold300,
    onSecondary: neutral500,
    tertiary: marigold500,
    onTertiary: neutral900,
    error: poppy500,
    onError: neutralWhite,
    surfaceContainerHighest: neutral100,
    onSurfaceVariant: neutral500, // Me icon color
  );
  static const flashTextTheme = TextTheme(
    bodyMedium: TextStyle(fontFamily: "General Sans"),
  );


  static late final Location defaultLocation;

  AppWidget({super.key}) {
    defaultLocation = getLocation("Europe/Stockholm");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currently',
      theme: ThemeData(
        // COLOR
        colorScheme: flashColorTheme,
        // TYPOGRAPHY & ICONOGRAPHY
        textTheme: flashTextTheme,
        cardTheme: const CardTheme(
          surfaceTintColor: Colors.transparent,
        ),
        useMaterial3: true,
      ),
      home: const SelectDeviceWidget(),
    );
  }
}

