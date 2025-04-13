import 'package:currently_local/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

import '../model/device.dart';
import '../model/hourly.dart';
import 'hourly_chart.dart';

class AnalysisTab extends StatefulWidget {
  const AnalysisTab({super.key});

  @override
  State<StatefulWidget> createState() => _AnalysisState();
}

class _AnalysisState extends State<AnalysisTab> {
  static final selectorFormat = DateFormat("d MMM");
  int _dayShift = 0;

  void _onPreviousDay() => setState(() {
        _dayShift--;
      });

  void _onNextDay() => setState(() {
        if (_dayShift < 1) {
          _dayShift++;
        }
      });

  void Function()? _onToday() => 0 == _dayShift
      ? null
      : () => setState(() {
            _dayShift = 0;
          });

  @override
  Widget build(BuildContext context) {
    return Consumer<Device?>(
      builder: (context, device, child) {
        final now =
            TZDateTime.now(device?.location ?? AppWidget.defaultLocation);
        final midnight = Hourly.midnight(now);
        final startHour = Hourly.shiftDays(midnight, _dayShift);
        final endHour = Hourly.addDay(startHour);

        Widget buildSelector(BuildContext context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: _onPreviousDay, icon: Icon(Icons.arrow_back_ios)),
              Text(
                selectorFormat.format(startHour),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                  onPressed: _onNextDay, icon: Icon(Icons.arrow_forward_ios)),
              ElevatedButton(
                  onPressed: _onToday(),
                  child: Icon(Icons.calendar_today_rounded)),
            ],
          );
        }

        Widget buildChart(BuildContext context) => HourlyChart(
            device: device!, startHour: startHour, endHour: endHour);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildSelector(context),
            Expanded(
              child: Card(
                color: AppWidget.neutralWhite,
                child: buildChart(context),
              ),
            ),
          ],
        );
      },
    );
  }
}
