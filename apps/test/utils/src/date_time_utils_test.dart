import 'package:docu_fill/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TODO: Implement tests for date_time_utils.dart', () {
    final dateTime = DateTime.now();
    final dateTimeString = dateTime.toString();
    final time = DateTimeUtils.format(
      dateTimeString,
      format: "'Ngày' dd, 'tháng' MM, 'năm' yyyy",
    );
    expect(true, true);
  });
}
