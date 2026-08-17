/// Configuration for location tracking.
class TrackingConfig {
  final String confraternityId;
  final String confraternityName;
  final String secret;
  final String serverUrl;
  final int intervalSeconds;

  const TrackingConfig({
    required this.confraternityId,
    required this.confraternityName,
    required this.secret,
    required this.serverUrl,
    required this.intervalSeconds,
  });

  TrackingConfig copyWith({
    String? confraternityId,
    String? confraternityName,
    String? secret,
    String? serverUrl,
    int? intervalSeconds,
  }) {
    return TrackingConfig(
      confraternityId: confraternityId ?? this.confraternityId,
      confraternityName: confraternityName ?? this.confraternityName,
      secret: secret ?? this.secret,
      serverUrl: serverUrl ?? this.serverUrl,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confraternityId': confraternityId,
      'confraternityName': confraternityName,
      'secret': secret,
      'serverUrl': serverUrl,
      'intervalSeconds': intervalSeconds,
    };
  }

  factory TrackingConfig.fromJson(Map<String, dynamic> json) {
    return TrackingConfig(
      confraternityId: json['confraternityId'] as String,
      confraternityName: json['confraternityName'] as String,
      secret: json['secret'] as String,
      serverUrl: json['serverUrl'] as String,
      intervalSeconds: json['intervalSeconds'] as int,
    );
  }

  static const defaultConfig = TrackingConfig(
    confraternityId: '',
    confraternityName: '',
    secret: 'capofila123',
    serverUrl: 'https://passio-sorrento-api.onrender.com/api',
    intervalSeconds: 30,
  );
}
