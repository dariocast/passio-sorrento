import 'package:flutter_test/flutter_test.dart';
import 'package:holyweek/core/constants/constants.dart';

void main() {
  test('AppConstants contains correct app name', () {
    expect(AppConstants.appName, 'Passio Sorrento');
  });

  test('ApiConstants contains correct endpoints', () {
    expect(ApiConstants.confraternities, '/confraternities');
    expect(ApiConstants.processionsLive, '/processions/live');
    expect(ApiConstants.trackingLive, '/tracking/live');
  });
}
