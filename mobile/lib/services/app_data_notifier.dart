import 'package:flutter/foundation.dart';

class AppDataNotifier extends ChangeNotifier {
  AppDataNotifier._();

  static final AppDataNotifier instance = AppDataNotifier._();

  void notifyDataChanged() => notifyListeners();
}
