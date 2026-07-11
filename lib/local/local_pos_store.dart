import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalPosStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class SharedPreferencesPosStore implements LocalPosStore {
  const SharedPreferencesPosStore(this.preferences);

  final SharedPreferences preferences;

  @override
  Future<String?> read(String key) async => preferences.getString(key);

  @override
  Future<void> write(String key, String value) async {
    final saved = await preferences.setString(key, value);
    if (!saved) throw StateError('Unable to save local POS data.');
  }

  @override
  Future<void> remove(String key) async {
    final removed = await preferences.remove(key);
    if (!removed && preferences.containsKey(key)) {
      throw StateError('Unable to remove local POS data.');
    }
  }
}

class MemoryPosStore implements LocalPosStore {
  MemoryPosStore([Map<String, String>? initial]) : _values = {...?initial};

  final Map<String, String> _values;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }

  Map<String, Object?> decode(String key) =>
      jsonDecode(_values[key]!) as Map<String, Object?>;
}
