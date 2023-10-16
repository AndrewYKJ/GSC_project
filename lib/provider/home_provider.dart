import 'package:flutter/material.dart';

class DrawerState extends ChangeNotifier {
  bool _stateOpen = false;

  bool get getState {
    return _stateOpen;
  }

  void setState(bool state) {
    _stateOpen = !_stateOpen;
    notifyListeners();
  }
}
