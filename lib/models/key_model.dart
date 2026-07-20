import 'package:flutter/material.dart';

class LicenseKey {
  final String key;
  final bool active;
  final String? deviceId;
  final DateTime? registeredAt;
  final DateTime? expiresAt;
  final int duration;
  final String unit;

  LicenseKey({
    required this.key,
    required this.active,
    this.deviceId,
    this.registeredAt,
    this.expiresAt,
    required this.duration,
    required this.unit,
  });

  factory LicenseKey.fromJson(String key, Map<String, dynamic> json) {
    return LicenseKey(
      key: key,
      active: json['active'] ?? false,
      deviceId: json['device_id'],
      registeredAt: json['registered_at'] != null
          ? DateTime.parse(json['registered_at'])
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      duration: json['duration'] ?? 0,
      unit: json['unit'] ?? 'days',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'device_id': deviceId,
      'registered_at': registeredAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'duration': duration,
      'unit': unit,
    };
  }

  String get statusText => active ? 'ACTIVE' : 'BLOCKED';
  String get expiryText {
    if (expiresAt == null) return 'Not activated';
    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) return 'EXPIRED';
    final diff = expiresAt!.difference(now);
    if (diff.inDays > 0) return '${diff.inDays}d remaining';
    if (diff.inHours > 0) return '${diff.inHours}h remaining';
    return 'Expiring soon';
  }

  Color get statusColor => active
      ? (expiresAt != null && expiresAt!.isBefore(DateTime.now())
          ? Colors.orange
          : Colors.green)
      : Colors.red;
}
