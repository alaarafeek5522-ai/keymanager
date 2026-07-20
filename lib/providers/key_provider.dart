import 'package:flutter/material.dart';
import '../models/key_model.dart';
import '../services/gist_service.dart';
import 'dart:math';

class KeyProvider extends ChangeNotifier {
  final GistService _gistService = GistService();
  Map<String, dynamic> _data = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<LicenseKey> get keys {
    final keysMap = _data['keys'] as Map<String, dynamic>? ?? {};
    return keysMap.entries
        .map((e) => LicenseKey.fromJson(e.key, e.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  int get activeCount => keys.where((k) => k.active).length;
  int get totalCount => keys.length;

  Future<void> loadKeys() async {
    _setLoading(true);
    try {
      _data = await _gistService.getData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> addKey(String key, int duration, String unit) async {
    _data.putIfAbsent('keys', () => {});
    if (_data['keys'].containsKey(key)) throw Exception('Key already exists');

    _data['keys'][key] = {
      'active': true,
      'device_id': null,
      'registered_at': null,
      'expires_at': null,
      'duration': duration,
      'unit': unit,
    };
    await _gistService.saveData(_data);
    notifyListeners();
  }

  Future<void> deleteKey(String key) async {
    _data['keys']?.remove(key);
    await _gistService.saveData(_data);
    notifyListeners();
  }

  Future<void> toggleKey(String key, bool active) async {
    if (_data['keys']?[key] != null) {
      _data['keys'][key]['active'] = active;
      await _gistService.saveData(_data);
      notifyListeners();
    }
  }

  Future<void> resetDevice(String key) async {
    if (_data['keys']?[key] != null) {
      _data['keys'][key]['device_id'] = null;
      _data['keys'][key]['registered_at'] = null;
      await _gistService.saveData(_data);
      notifyListeners();
    }
  }

  Future<void> renewKey(String key, int duration, String unit) async {
    if (_data['keys']?[key] != null) {
      _data['keys'][key]['duration'] = duration;
      _data['keys'][key]['unit'] = unit;
      _data['keys'][key]['registered_at'] = null;
      _data['keys'][key]['expires_at'] = null;
      _data['keys'][key]['device_id'] = null;
      _data['keys'][key]['active'] = true;
      await _gistService.saveData(_data);
      notifyListeners();
    }
  }

  Future<void> generateBulkKeys() async {
    final random = Random();
    final categories = [
      (30, 1, 'months', 'MONTH'),
      (30, 1, 'weeks', 'WEEK'),
      (30, 1, 'days', 'DAY'),
    ];

    for (final (count, duration, unit, prefix) in categories) {
      for (var i = 0; i < count; i++) {
        String key;
        do {
          key = '$prefix-${_randomBlock(random)}-${_randomBlock(random)}';
        } while (_data['keys']?.containsKey(key) ?? false);

        _data.putIfAbsent('keys', () => {});
        _data['keys'][key] = {
          'active': true,
          'device_id': null,
          'registered_at': null,
          'expires_at': null,
          'duration': duration,
          'unit': unit,
        };
      }
    }
    await _gistService.saveData(_data);
    notifyListeners();
  }

  String _randomBlock(Random random) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
