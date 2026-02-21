import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single queued GPS position waiting to be sent.
class QueuedPosition {
  final String confraternityId;
  final double latitude;
  final double longitude;
  final String secret;
  final DateTime timestamp;

  const QueuedPosition({
    required this.confraternityId,
    required this.latitude,
    required this.longitude,
    required this.secret,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'confraternityId': confraternityId,
    'latitude': latitude,
    'longitude': longitude,
    'secret': secret,
    'timestamp': timestamp.toIso8601String(),
  };

  factory QueuedPosition.fromJson(Map<String, dynamic> json) {
    return QueuedPosition(
      confraternityId: json['confraternityId'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      secret: json['secret'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Service for buffering GPS positions when the network is unavailable.
///
/// Positions are persisted to SharedPreferences as a JSON array.
/// When connectivity returns, the queue is flushed by sending each
/// position to the server in chronological order.
class OfflineQueueService {
  static const _queueKey = 'offline_position_queue';

  /// Adds a position to the offline queue.
  Future<void> enqueue(QueuedPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _loadQueue(prefs);
    queue.add(position);
    await _saveQueue(prefs, queue);
  }

  /// Returns all queued positions in chronological order.
  Future<List<QueuedPosition>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadQueue(prefs);
  }

  /// Returns the number of positions currently in the queue.
  Future<int> get queueLength async {
    final queue = await getQueue();
    return queue.length;
  }

  /// Removes the first [count] positions from the queue.
  ///
  /// Call this after successfully sending positions to the server.
  Future<void> dequeue(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _loadQueue(prefs);
    if (count >= queue.length) {
      await prefs.remove(_queueKey);
    } else {
      queue.removeRange(0, count);
      await _saveQueue(prefs, queue);
    }
  }

  /// Removes all positions from the queue.
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  /// Whether the queue has any pending positions.
  Future<bool> get hasItems async {
    final queue = await getQueue();
    return queue.isNotEmpty;
  }

  Future<List<QueuedPosition>> _loadQueue(SharedPreferences prefs) {
    final jsonString = prefs.getString(_queueKey);
    if (jsonString == null) return Future.value([]);

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return Future.value(
        jsonList.map((json) => QueuedPosition.fromJson(json)).toList(),
      );
    } catch (e) {
      // If the queue is corrupted, clear it
      return Future.value([]);
    }
  }

  Future<void> _saveQueue(
    SharedPreferences prefs,
    List<QueuedPosition> queue,
  ) async {
    final jsonString = jsonEncode(queue.map((p) => p.toJson()).toList());
    await prefs.setString(_queueKey, jsonString);
  }
}
