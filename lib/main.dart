import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

import 'main/select_device_widget.dart';

void main() {
  tz.initializeTimeZones();
  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  static late final Location defaultLocation;

  AppWidget({super.key}) {
    defaultLocation = getLocation("Europe/Stockholm");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currently',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const SelectDeviceWidget(),
    );
  }
}

