import 'dart:convert';
import 'package:flutter/services.dart';

class InventorySchema {
  InventorySchema(this.fields, this.tiers);
  final List<Map<String, dynamic>> fields;
  final List<Map<String, dynamic>> tiers;

  static Future<InventorySchema> load() async {
    final json =
        jsonDecode(await rootBundle.loadString('assets/inventory_schema.json'))
            as Map<String, dynamic>;
    return InventorySchema(
        List<Map<String, dynamic>>.from(json['fields'] as List),
        List<Map<String, dynamic>>.from(json['tiers'] as List));
  }

  Map<String, dynamic> defaults() => {
        for (final field in fields)
          if (field.containsKey('default'))
            field['key'] as String: field['default'],
      };

  static String? validateValue(Map<String, dynamic> field, dynamic value) {
    if (value == null || value == '') {
      return field['required'] == true ? 'Required' : null;
    }
    final type = field['type'];
    if (['money', 'decimal', 'integer'].contains(type)) {
      final number = num.tryParse('$value');
      if (number == null ||
          !number.isFinite ||
          number < 0 ||
          number > 999999999) {
        return 'Enter a non-negative number';
      }
      if (field['positive'] == true && number <= 0) {
        return 'Must be greater than zero';
      }
      if (field['max'] != null && number > (field['max'] as num)) {
        return 'Maximum ${field['max']}';
      }
      if (type == 'integer' && number != number.round()) {
        return 'Enter a whole number';
      }
      if (type == 'money' && !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch('$value')) {
        return 'Use up to two decimal places';
      }
    } else if (type == 'date') {
      final date = DateTime.tryParse('$value');
      if (date == null || date.toIso8601String().substring(0, 10) != value) {
        return 'Use YYYY-MM-DD';
      }
    } else if (type == 'url') {
      final uri = Uri.tryParse('$value');
      if (uri == null ||
          !['http', 'https'].contains(uri.scheme) ||
          uri.host.isEmpty) {
        return 'Enter an http or https URL';
      }
    } else if (type == 'select' &&
        !(field['options'] as List).contains(value)) {
      return 'Choose a listed option';
    } else if (type == 'text' &&
        '$value'.length > (field['maxLength'] as int? ?? 255)) {
      return 'Maximum ${field['maxLength'] ?? 255} characters';
    }
    return null;
  }

  void validate(Map<String, dynamic> data) {
    for (final field in fields) {
      final value = data[field['key']];
      final error = validateValue(field, value);
      if (error != null) throw FormatException('${field['label']}: $error');
      if (field['type'] == 'rows' && value != null) {
        if (value is! List || value.length > 500) {
          throw FormatException('${field['label']}: maximum 500 rows');
        }
        for (final row in value) {
          for (final child
              in List<Map<String, dynamic>>.from(field['fields'] as List)) {
            final error = validateValue(child, (row as Map)[child['key']]);
            if (error != null) {
              throw FormatException(
                  '${field['label']} / ${child['label']}: $error');
            }
          }
        }
      }
    }
    for (final key in ['units', 'batches']) {
      final identity = {'units': 'unit', 'batches': 'lot'}[key];
      final ids = ((data[key] ?? []) as List)
          .map((row) => '${row[identity]}'.toLowerCase())
          .toList();
      if (ids.toSet().length != ids.length) {
        throw FormatException('$key: duplicate identifiers');
      }
    }
    num number(dynamic value) => num.tryParse('$value') ?? 0;
    if (((data['batches'] ?? []) as List)
            .fold<num>(0, (sum, row) => sum + number(row['quantity'])) >
        number(data['quantity'])) {
      throw const FormatException(
          'Batch quantities cannot exceed stock on hand');
    }
    for (final row in (data['price_tiers'] ?? []) as List) {
      if ('${row['effective_from'] ?? ''}'.isNotEmpty &&
          '${row['effective_to'] ?? ''}'.isNotEmpty &&
          '${row['effective_to']}'.compareTo('${row['effective_from']}') < 0) {
        throw const FormatException(
            'Price tier end date must follow start date');
      }
    }
  }
}
