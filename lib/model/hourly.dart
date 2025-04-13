import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class Hourly {
  final int sec, wh, ph;
  int ms;
  int? dWh, dPh, price, cost;

  Hourly({
    required this.sec,
    required this.wh,
    required this.ph,
    this.dWh,
    this.dPh,
    this.price,
    this.cost,
    this.ms = 0,
  });

  factory Hourly.fromJson(Map<dynamic, dynamic> map) {
    return Hourly(
      sec: map['sec'],
      wh: map['Wh'],
      ph: map['Ph'],
    );
  }

  static TZDateTime truncated(TZDateTime precise) {
    final truncated = TZDateTime(
      precise.location,
      precise.year,
      precise.month,
      precise.day,
      precise.hour,
    );
    return truncated;
  }

  static TZDateTime addDay(TZDateTime before) {
    TZDateTime next = before.add(Duration(hours: 23));
    while (before.day == next.day) {
      next = next.add(Duration(hours: 1));
    }
    return next;
  }

  static TZDateTime midnight(TZDateTime precise) {
    final truncated = TZDateTime(
      precise.location,
      precise.year,
      precise.month,
      precise.day,
      0,
    );
    return truncated;
  }

  static TZDateTime shiftDays(TZDateTime from, int days) =>
      from.add(Duration(days: days));

  DateTime get startHour => DateTime.fromMillisecondsSinceEpoch(ms);
}

class HourlyEvents extends ChangeNotifier {
  final Location _location;
  final hourlyByHour = SplayTreeMap<int, Hourly>();

  HourlyEvents(this._location);

  void add(Hourly h) {
    final exact =
        TZDateTime.fromMillisecondsSinceEpoch(_location, h.sec * 1000);
    final nearest = Hourly.truncated(exact);
    final key = nearest.millisecondsSinceEpoch;
    hourlyByHour.putIfAbsent(key, () {
      debugPrint("+ hourly ${h.sec} ${h.wh}Wh");
      h.ms = key;
      return h;
    });
    notifyListeners();
  }
}
