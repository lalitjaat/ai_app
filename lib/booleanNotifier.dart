import 'package:flutter/material.dart';

class BooleanNotifier extends ChangeNotifier {
  bool boolvalue = false;

  bool get value => boolvalue;

  void toggleValue() {
    boolvalue = !boolvalue;
    print("${value} notifier real value");
    notifyListeners();  // This line is important to notify the UI
  }
}
