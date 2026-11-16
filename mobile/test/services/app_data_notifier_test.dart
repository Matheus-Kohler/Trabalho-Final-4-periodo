import 'package:flutter_test/flutter_test.dart';
import 'package:rpg_manager/services/app_data_notifier.dart';

void main() {
  test('notifies listeners when application data changes', () {
    final notifier = AppDataNotifier.instance;
    var notifications = 0;
    void listener() => notifications++;

    notifier.addListener(listener);
    notifier.notifyDataChanged();
    notifier.removeListener(listener);

    expect(notifications, 1);
  });
}
