import 'dart:async';
import 'dart:convert';

import 'package:currently_local/main.dart';
import 'package:currently_local/model/hourly.dart';
import 'package:currently_local/model/states.dart';
import 'package:eventsource/eventsource.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class Device extends ChangeNotifier {

  final String deviceId;
  String? localIP;
  String? name;
  String? remoteUrl;
  String? status;

  late HourlyEvents _hourlyEvents;
  final StatesCache _statesCache = StatesCache();

  Device({
    required this.deviceId,
    this.localIP,
    this.name,
    this.remoteUrl,
  }) {
    _hourlyEvents = HourlyEvents(location);
  }

  Future<StreamSubscription>? listen() {
    Future<StreamSubscription>? sub;
    if (null != localIP) {
      sub = _connect(localIP!);
    }

    if (null == sub && null != remoteUrl) {
      sub = _connect(remoteUrl!);
    }
    return sub;
  }

  HourlyEvents get hours => _hourlyEvents;

  Location get location => AppWidget.defaultLocation;

  StatesCache get states => _statesCache;

  void _addHourly(Hourly hourly) {
    _hourlyEvents.add(hourly);
  }

  void _addState(StateEvent state) {
    _statesCache.add(state);
  }

  Future<StreamSubscription>? _connect(String authorityOrUrl) {
    const path = "events";
    final url = authorityOrUrl.startsWith("https://")
        ? Uri.https(authorityOrUrl.substring(8), path)
        : authorityOrUrl.startsWith("http://")
            ? Uri.http(authorityOrUrl.substring(7), path)
            : Uri.http(authorityOrUrl, path);
    return EventSource.connect(url).then((eventSource) => eventSource
            .timeout(const Duration(seconds: 20), onTimeout: (EventSink sink) {
          debugPrint(' timeout 20 for $deviceId');
          sink.close();
          _connect(authorityOrUrl);
        }).listen(
          _onEvent,
          onDone: () {
            debugPrint('  onDone for $deviceId');
          },
          onError: (err) {
            debugPrint('  onError $err for $deviceId');
          },
        ));
  }

  void _onEvent(Event event) {
    if (null != event.data && event.data!.startsWith("{")) {
      try {
        final jsonMap = jsonDecode(event.data!);
        switch (event.event) {
          case "config":
            debugPrint('${event.event} from $deviceId ${event.data}');
            name = jsonMap["name"];
            remoteUrl = jsonMap["remoteUrl"];
            notifyListeners();
            break;
          case "state":
            final stateEvent = StateEvent.fromJson(jsonMap);
            _addState(stateEvent);
            break;
          case "transition":
            break;
          case "ping":
            break;
          case "progress":
            break;
          case "hourly":
            final hourlyEvent = Hourly.fromJson(jsonMap);
            _addHourly(hourlyEvent);
            break;
        }
      } catch (fe) {
        debugPrint("ERROR parsing event");
        debugPrint("${event.data}");
      }
    } else {
      switch (event.event) {
        case "status":
          status = event.data;
          notifyListeners();
          break;
      }
    }
  }
}
