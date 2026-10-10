import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum BusinessCheckoutType {
  fnb('Food & Beverage', '/pos'),
  retail('Grocery / Retail', '/pos/retail');

  const BusinessCheckoutType(this.label, this.route);
  final String label;
  final String route;
}

class BusinessProfile {
  const BusinessProfile(this.id, this.name, {this.demo = false});
  final String id, name;
  final bool demo;
  String get databaseName => switch (id) {
        'company' => 'xantara_company',
        'demo' => 'xantara_pos',
        _ => 'xantara_business_$id',
      };
  String get storeScope => id == 'demo' ? '' : id;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'demo': demo};
  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    if (!RegExp(r'^(company|demo|[a-f0-9-]{36})$').hasMatch(id)) {
      throw const FormatException('Invalid business profile identifier.');
    }
    return BusinessProfile(id, json['name'] as String, demo: id == 'demo');
  }
}

/// One durable manifest, with legacy database names preserved in place.
class BusinessProfileCatalog {
  BusinessProfileCatalog(this.preferences);
  final SharedPreferences preferences;
  static const key = 'xantara.business-profiles.v1';
  List<BusinessProfile> get profiles {
    final saved = preferences.getString(key);
    if (saved == null) {
      return const [
        BusinessProfile('company', 'Existing business'),
        BusinessProfile('demo', 'Training workspace', demo: true)
      ];
    }
    return (jsonDecode(saved)['profiles'] as List)
        .map((p) =>
            BusinessProfile.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();
  }

  String? get activeId {
    final saved = preferences.getString(key);
    return saved == null ? null : jsonDecode(saved)['active'] as String;
  }

  Future<void> select(String id) => _save(profiles, id);
  Future<BusinessProfile> add(String name) async {
    final label = name.trim();
    if (label.isEmpty ||
        label.length > 100 ||
        RegExp(r'[\x00-\x1f]').hasMatch(label)) {
      throw ArgumentError('Enter a business name of 1 to 100 characters.');
    }
    if (profiles.any((p) => p.name.toLowerCase() == label.toLowerCase())) {
      throw ArgumentError('Use a different profile name.');
    }
    final profile = BusinessProfile(const Uuid().v4(), label);
    await _save([...profiles, profile], activeId ?? 'company');
    return profile;
  }

  Future<void> _save(List<BusinessProfile> items, String active) async {
    if (!items.any((p) => p.id == active)) {
      throw StateError('Unknown business profile.');
    }
    if (!await preferences.setString(
        key,
        jsonEncode({
          'active': active,
          'profiles': items.map((p) => p.toJson()).toList()
        }))) {
      throw StateError('Business profile could not be saved.');
    }
  }
}
