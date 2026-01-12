/// HTTP implementation of HomeRepository for real backend communication.
library;

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;

import '../../domain/entities/confraternity.dart';
import '../../domain/entities/procession.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/confraternity_model.dart';

/// Implementation of [HomeRepository] that fetches data from the real backend API.
/// 
/// Uses platform-aware base URL:
/// - Android emulator: `10.0.2.2` (maps to host localhost)
/// - iOS simulator/device: `localhost`
class HomeRepositoryHttp implements HomeRepository {
  HomeRepositoryHttp({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Returns the appropriate base URL based on the platform.
  /// 
  /// Android emulators use a special IP (10.0.2.2) to access the host machine.
  /// iOS simulators can use localhost directly.
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }

  @override
  Future<List<Confraternity>> getConfraternities() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/confraternities'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        return jsonList
            .map((json) => ConfraternityModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Failed to load confraternities',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException('No internet connection or server unreachable');
    } on FormatException {
      throw const DataParsingException('Invalid response format from server');
    } catch (e) {
      if (e is HttpException || e is NetworkException || e is DataParsingException) {
        rethrow;
      }
      throw RepositoryException('Unexpected error: $e');
    }
  }

  @override
  Future<List<Procession>> getUpcomingProcessions() async {
    // TODO: Implement when endpoint is available
    return const [];
  }

  @override
  Future<List<Procession>> getLiveProcessions() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/processions/live'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        return jsonList.map((json) => _processionFromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw HttpException(
          'Failed to load live processions',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException('No internet connection or server unreachable');
    } on FormatException {
      throw const DataParsingException('Invalid response format from server');
    } catch (e) {
      if (e is HttpException || e is NetworkException || e is DataParsingException) {
        rethrow;
      }
      throw RepositoryException('Unexpected error: $e');
    }
  }

  /// Parses a Procession from JSON.
  /// 
  /// Note: This is a simplified parser. In a full implementation,
  /// we would create a ProcessionModel class similar to ConfraternityModel.
  Procession _processionFromJson(Map<String, dynamic> json) {
    return Procession(
      id: json['procession_id'] as String,
      confraternityId: json['confraternity_id'] as String,
      day: json['day'] as String,
      exitTime: DateTime.parse(json['timestamp'] as String),
      expectedReturnTime: json['last_update'] != null
          ? DateTime.parse(json['last_update'] as String)
          : null,
      isLive: true, // If it's in live endpoint, it's live
    );
  }
}

// Custom exception classes for better error handling

/// Exception thrown when an HTTP request fails.
class HttpException implements Exception {
  const HttpException(this.message, {this.statusCode});
  
  final String message;
  final int? statusCode;
  
  @override
  String toString() => 'HttpException: $message (status: $statusCode)';
}

/// Exception thrown when there's a network connectivity issue.
class NetworkException implements Exception {
  const NetworkException(this.message);
  
  final String message;
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when response data cannot be parsed.
class DataParsingException implements Exception {
  const DataParsingException(this.message);
  
  final String message;
  
  @override
  String toString() => 'DataParsingException: $message';
}

/// Generic repository exception.
class RepositoryException implements Exception {
  const RepositoryException(this.message);
  
  final String message;
  
  @override
  String toString() => 'RepositoryException: $message';
}
