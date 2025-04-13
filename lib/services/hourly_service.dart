import 'package:currently_local/model/device.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

import '../model/hourly.dart';

class HourlyService {
  final Device device;

  HourlyService(this.device);

  Iterable<Hourly> get diffed {
    Hourly? prev;
    for (Hourly value in device.hours.hourlyByHour.values) {
      prev?.dWh = value.wh - prev.wh;
      debugPrint("  dWh ${prev?.dWh} ${prev?.ms}");
      prev?.dPh = value.ph - prev.ph;
      // final dWh = null != prev ? value.wh - prev!.wh : null;
      // final dPh = null != prev ? value.ph - prev!.ph : null;
      // final cost = ((dWh ?? 0) - (dPh ?? 0)) *
      //     (priceEntry?.price ?? 0) ~/
      //     100000;
      // final merged = null != prev ? Hourly(prev!.sec, )
      prev = value;
    }
    ;
    return device.hours.hourlyByHour.values;
  }

  List<Hourly> getHourlyList(DateTime startHour, DateTime endHour) {
    final complete = diffed
        .where((h) =>
            startHour.millisecondsSinceEpoch <= h.ms &&
            h.ms < endHour.millisecondsSinceEpoch)
        .toList(growable: true);
    final lastState = device.states.last;
    if (complete.isNotEmpty && null != lastState) {
      final now = TZDateTime.now(device.location);
      final currentTime = Hourly.truncated(now);
      final dWh = null != lastState.wh
          ? lastState.wh! - (complete.last.wh)
          : null;
      final dPh = null != lastState.ph
          ? lastState.ph! - (complete.last.ph)
          : null;
      final current = Hourly(
        sec: now.millisecondsSinceEpoch ~/ 1000,
        wh: lastState.wh ?? 0,
        ph: lastState.ph ?? 0,
        dWh: dWh,
        dPh: dPh,
        ms: currentTime.millisecondsSinceEpoch,
      );
      complete.add(current);
    }
    return complete;
  }
}
