import 'dart:async';
import 'dart:convert';

import 'package:eventsource/eventsource.dart';
import 'package:flutter/material.dart';

class Device extends ChangeNotifier {
  final String deviceId;
  String? localIP;
  String? name;
  String? remoteUrl;
  String? status;

  Device({
    required this.deviceId,
    this.localIP,
    this.name,
    this.remoteUrl,
  });

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
          // _eventSub?.cancel();
          // _sendPort.send(StatusEvent(online: false));
          // _connect();
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
            break;
          case "transition":
            break;
          case "ping":
            break;
          case "progress":
            break;
          case "hourly":
            // debugPrint('${event.event} ${event.data} from $deviceId');
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
