import 'dart:collection';

import 'package:flutter/material.dart';

class StateEvent {
  final int t;
  int? w, wh;

  StateEvent({
    required this.t,
    this.w,
    this.wh,
  });

  factory StateEvent.fromJson(Map<String, dynamic> map) => StateEvent(
    t: map["sec"],
    w: map["W"],
    wh: map["Wh"],
  );
}

class StatesCache extends ChangeNotifier {
  final _states = SplayTreeMap<int, StateEvent>();

  void add(StateEvent state) {
    _states[state.t] = state;
    debugPrint("+ state t: ${state.t} ${state.w}W ${state.wh}Wh");
    notifyListeners();
  }

  get size => _states.length;
}
