/// Core constants for the Holyweek Tracker app.
library;

/// API configuration constants.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the backend server.
  static const String baseUrl = 'http://192.168.97.2:5000/api';

  /// Endpoints.
  static const String confraternities = '/confraternities';
  static const String processionsLive = '/processions/live';
  static const String trackingLive = '/tracking/live';
}

/// App-wide constants.
class AppConstants {
  AppConstants._();

  /// App name.
  static const String appName = 'Holyweek Tracker';

  /// Default polling interval for live tracking (in seconds).
  static const int trackingPollingIntervalSeconds = 10;

  /// Municipalities in the Sorrento Peninsula.
  static const List<String> municipalities = [
    'Sorrento',
    'Sant\'Agnello',
    'Piano di Sorrento',
    'Meta',
  ];
}
