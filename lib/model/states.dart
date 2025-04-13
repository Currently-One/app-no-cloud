import 'dart:collection';

import 'package:flutter/material.dart';

class StateEvent {
  final int t;
  int? w, wh, ph;

  StateEvent({
    required this.t,
    this.w,
    this.wh,
    this.ph,
  });

  factory StateEvent.fromJson(Map<String, dynamic> map) => StateEvent(
    t: map["sec"],
    w: map["W"],
    wh: map["Wh"],
    ph: map["Ph"],
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

  StateEvent? get last => _states.isEmpty ? null : _states.values.last;
}
