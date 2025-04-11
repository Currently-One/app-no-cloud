import 'package:currently_local/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

import '../model/device.dart';

class AnalysisTab extends StatefulWidget {
  const AnalysisTab({super.key});

  @override
  State<StatefulWidget> createState() => _AnalysisState();
}

class _AnalysisState extends State<AnalysisTab> {
  int _dayShift = 0;

  void _onPreviousDay() =>
      setState(() {
        _dayShift--;
      });

  void _onNextDay() => setState(() {
    if (_dayShift < 1) {
      _dayShift++;
    }
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Device?>(builder: (context, device, child) {
      Widget _buildSelector(BuildContext context) {
        final now = TZDateTime.now(device?.location ?? AppWidget.defaultLocation);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: _onPreviousDay, icon: Icon(Icons.arrow_back_ios)),
            IconButton(
                onPressed: _onNextDay, icon: Icon(Icons.arrow_forward_ios)),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSelector(context),
        ],
      );
    },);
  }
}
