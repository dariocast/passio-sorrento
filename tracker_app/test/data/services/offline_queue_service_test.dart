import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/data/services/offline_queue_service.dart';

void main() {
  group('QueuedPosition serialization', () {
    test('toJson produces correct map', () {
      final position = QueuedPosition(
        confraternityId: 'uuid-1',
        latitude: 40.6263,
        longitude: 14.3758,
        secret: 'capofila123',
        timestamp: DateTime.utc(2026, 4, 17, 12, 0, 0),
      );

      final json = position.toJson();

      expect(json['confraternityId'], 'uuid-1');
      expect(json['latitude'], 40.6263);
      expect(json['longitude'], 14.3758);
      expect(json['secret'], 'capofila123');
      expect(json['timestamp'], '2026-04-17T12:00:00.000Z');
    });

    test('fromJson restores position correctly', () {
      final json = {
        'confraternityId': 'uuid-2',
        'latitude': 40.63,
        'longitude': 14.38,
        'secret': 'test123',
        'timestamp': '2026-04-17T14:30:00.000Z',
      };

      final position = QueuedPosition.fromJson(json);

      expect(position.confraternityId, 'uuid-2');
      expect(position.latitude, 40.63);
      expect(position.longitude, 14.38);
      expect(position.secret, 'test123');
      expect(position.timestamp, DateTime.utc(2026, 4, 17, 14, 30, 0));
    });

    test('roundtrip toJson/fromJson preserves data', () {
      final original = QueuedPosition(
        confraternityId: 'uuid-3',
        latitude: 40.625,
        longitude: 14.370,
        secret: 'secret',
        timestamp: DateTime.utc(2026, 4, 17, 18, 45, 30),
      );

      final restored = QueuedPosition.fromJson(original.toJson());

      expect(restored.confraternityId, original.confraternityId);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.secret, original.secret);
      expect(restored.timestamp, original.timestamp);
    });
  });
}
