// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BranchesTable extends Branches with TableInfo<$BranchesTable, Branche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, code, name, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branches';
  @override
  VerificationContext validateIntegrity(Insertable<Branche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Branche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Branche(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BranchesTable createAlias(String alias) {
    return $BranchesTable(attachedDatabase, alias);
  }
}

class Branche extends DataClass implements Insertable<Branche> {
  final String id;
  final String code;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  const Branche(
      {required this.id,
      required this.code,
      required this.name,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BranchesCompanion toCompanion(bool nullToAbsent) {
    return BranchesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Branche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Branche(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Branche copyWith(
          {String? id,
          String? code,
          String? name,
          bool? isActive,
          DateTime? createdAt}) =>
      Branche(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Branche copyWithCompanion(BranchesCompanion data) {
    return Branche(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Branche(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Branche &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class BranchesCompanion extends UpdateCompanion<Branche> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BranchesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchesCompanion.insert({
    required String id,
    required String code,
    required String name,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Branche> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? name,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BranchesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TerminalsTable extends Terminals
    with TableInfo<$TerminalsTable, Terminal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TerminalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _machineIdentificationNumberMeta =
      const VerificationMeta('machineIdentificationNumber');
  @override
  late final GeneratedColumn<String> machineIdentificationNumber =
      GeneratedColumn<String>(
          'machine_identification_number', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _permitToUseNumberMeta =
      const VerificationMeta('permitToUseNumber');
  @override
  late final GeneratedColumn<String> permitToUseNumber =
      GeneratedColumn<String>('permit_to_use_number', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _machineSerialNumberMeta =
      const VerificationMeta('machineSerialNumber');
  @override
  late final GeneratedColumn<String> machineSerialNumber =
      GeneratedColumn<String>('machine_serial_number', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        branchId,
        code,
        machineIdentificationNumber,
        permitToUseNumber,
        machineSerialNumber,
        isActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'terminals';
  @override
  VerificationContext validateIntegrity(Insertable<Terminal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('machine_identification_number')) {
      context.handle(
          _machineIdentificationNumberMeta,
          machineIdentificationNumber.isAcceptableOrUnknown(
              data['machine_identification_number']!,
              _machineIdentificationNumberMeta));
    } else if (isInserting) {
      context.missing(_machineIdentificationNumberMeta);
    }
    if (data.containsKey('permit_to_use_number')) {
      context.handle(
          _permitToUseNumberMeta,
          permitToUseNumber.isAcceptableOrUnknown(
              data['permit_to_use_number']!, _permitToUseNumberMeta));
    } else if (isInserting) {
      context.missing(_permitToUseNumberMeta);
    }
    if (data.containsKey('machine_serial_number')) {
      context.handle(
          _machineSerialNumberMeta,
          machineSerialNumber.isAcceptableOrUnknown(
              data['machine_serial_number']!, _machineSerialNumberMeta));
    } else if (isInserting) {
      context.missing(_machineSerialNumberMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {branchId, code},
        {machineIdentificationNumber},
      ];
  @override
  Terminal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Terminal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      machineIdentificationNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}machine_identification_number'])!,
      permitToUseNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permit_to_use_number'])!,
      machineSerialNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}machine_serial_number'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TerminalsTable createAlias(String alias) {
    return $TerminalsTable(attachedDatabase, alias);
  }
}

class Terminal extends DataClass implements Insertable<Terminal> {
  final String id;
  final String branchId;
  final String code;
  final String machineIdentificationNumber;
  final String permitToUseNumber;
  final String machineSerialNumber;
  final bool isActive;
  final DateTime createdAt;
  const Terminal(
      {required this.id,
      required this.branchId,
      required this.code,
      required this.machineIdentificationNumber,
      required this.permitToUseNumber,
      required this.machineSerialNumber,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['branch_id'] = Variable<String>(branchId);
    map['code'] = Variable<String>(code);
    map['machine_identification_number'] =
        Variable<String>(machineIdentificationNumber);
    map['permit_to_use_number'] = Variable<String>(permitToUseNumber);
    map['machine_serial_number'] = Variable<String>(machineSerialNumber);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TerminalsCompanion toCompanion(bool nullToAbsent) {
    return TerminalsCompanion(
      id: Value(id),
      branchId: Value(branchId),
      code: Value(code),
      machineIdentificationNumber: Value(machineIdentificationNumber),
      permitToUseNumber: Value(permitToUseNumber),
      machineSerialNumber: Value(machineSerialNumber),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Terminal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Terminal(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String>(json['branchId']),
      code: serializer.fromJson<String>(json['code']),
      machineIdentificationNumber:
          serializer.fromJson<String>(json['machineIdentificationNumber']),
      permitToUseNumber: serializer.fromJson<String>(json['permitToUseNumber']),
      machineSerialNumber:
          serializer.fromJson<String>(json['machineSerialNumber']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String>(branchId),
      'code': serializer.toJson<String>(code),
      'machineIdentificationNumber':
          serializer.toJson<String>(machineIdentificationNumber),
      'permitToUseNumber': serializer.toJson<String>(permitToUseNumber),
      'machineSerialNumber': serializer.toJson<String>(machineSerialNumber),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Terminal copyWith(
          {String? id,
          String? branchId,
          String? code,
          String? machineIdentificationNumber,
          String? permitToUseNumber,
          String? machineSerialNumber,
          bool? isActive,
          DateTime? createdAt}) =>
      Terminal(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        code: code ?? this.code,
        machineIdentificationNumber:
            machineIdentificationNumber ?? this.machineIdentificationNumber,
        permitToUseNumber: permitToUseNumber ?? this.permitToUseNumber,
        machineSerialNumber: machineSerialNumber ?? this.machineSerialNumber,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Terminal copyWithCompanion(TerminalsCompanion data) {
    return Terminal(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      code: data.code.present ? data.code.value : this.code,
      machineIdentificationNumber: data.machineIdentificationNumber.present
          ? data.machineIdentificationNumber.value
          : this.machineIdentificationNumber,
      permitToUseNumber: data.permitToUseNumber.present
          ? data.permitToUseNumber.value
          : this.permitToUseNumber,
      machineSerialNumber: data.machineSerialNumber.present
          ? data.machineSerialNumber.value
          : this.machineSerialNumber,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Terminal(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('code: $code, ')
          ..write('machineIdentificationNumber: $machineIdentificationNumber, ')
          ..write('permitToUseNumber: $permitToUseNumber, ')
          ..write('machineSerialNumber: $machineSerialNumber, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      branchId,
      code,
      machineIdentificationNumber,
      permitToUseNumber,
      machineSerialNumber,
      isActive,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Terminal &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.code == this.code &&
          other.machineIdentificationNumber ==
              this.machineIdentificationNumber &&
          other.permitToUseNumber == this.permitToUseNumber &&
          other.machineSerialNumber == this.machineSerialNumber &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class TerminalsCompanion extends UpdateCompanion<Terminal> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<String> code;
  final Value<String> machineIdentificationNumber;
  final Value<String> permitToUseNumber;
  final Value<String> machineSerialNumber;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TerminalsCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.code = const Value.absent(),
    this.machineIdentificationNumber = const Value.absent(),
    this.permitToUseNumber = const Value.absent(),
    this.machineSerialNumber = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TerminalsCompanion.insert({
    required String id,
    required String branchId,
    required String code,
    required String machineIdentificationNumber,
    required String permitToUseNumber,
    required String machineSerialNumber,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        branchId = Value(branchId),
        code = Value(code),
        machineIdentificationNumber = Value(machineIdentificationNumber),
        permitToUseNumber = Value(permitToUseNumber),
        machineSerialNumber = Value(machineSerialNumber),
        createdAt = Value(createdAt);
  static Insertable<Terminal> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? code,
    Expression<String>? machineIdentificationNumber,
    Expression<String>? permitToUseNumber,
    Expression<String>? machineSerialNumber,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (code != null) 'code': code,
      if (machineIdentificationNumber != null)
        'machine_identification_number': machineIdentificationNumber,
      if (permitToUseNumber != null) 'permit_to_use_number': permitToUseNumber,
      if (machineSerialNumber != null)
        'machine_serial_number': machineSerialNumber,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TerminalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? branchId,
      Value<String>? code,
      Value<String>? machineIdentificationNumber,
      Value<String>? permitToUseNumber,
      Value<String>? machineSerialNumber,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TerminalsCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      code: code ?? this.code,
      machineIdentificationNumber:
          machineIdentificationNumber ?? this.machineIdentificationNumber,
      permitToUseNumber: permitToUseNumber ?? this.permitToUseNumber,
      machineSerialNumber: machineSerialNumber ?? this.machineSerialNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (machineIdentificationNumber.present) {
      map['machine_identification_number'] =
          Variable<String>(machineIdentificationNumber.value);
    }
    if (permitToUseNumber.present) {
      map['permit_to_use_number'] = Variable<String>(permitToUseNumber.value);
    }
    if (machineSerialNumber.present) {
      map['machine_serial_number'] =
          Variable<String>(machineSerialNumber.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TerminalsCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('code: $code, ')
          ..write('machineIdentificationNumber: $machineIdentificationNumber, ')
          ..write('permitToUseNumber: $permitToUseNumber, ')
          ..write('machineSerialNumber: $machineSerialNumber, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffUsersTable extends StaffUsers
    with TableInfo<$StaffUsersTable, StaffUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailNormalizedMeta =
      const VerificationMeta('emailNormalized');
  @override
  late final GeneratedColumn<String> emailNormalized = GeneratedColumn<String>(
      'email_normalized', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordSaltMeta =
      const VerificationMeta('passwordSalt');
  @override
  late final GeneratedColumn<String> passwordSalt = GeneratedColumn<String>(
      'password_salt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordAlgorithmMeta =
      const VerificationMeta('passwordAlgorithm');
  @override
  late final GeneratedColumn<String> passwordAlgorithm =
      GeneratedColumn<String>('password_algorithm', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordIterationsMeta =
      const VerificationMeta('passwordIterations');
  @override
  late final GeneratedColumn<int> passwordIterations = GeneratedColumn<int>(
      'password_iterations', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _failedLoginAttemptsMeta =
      const VerificationMeta('failedLoginAttempts');
  @override
  late final GeneratedColumn<int> failedLoginAttempts = GeneratedColumn<int>(
      'failed_login_attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lockedUntilMeta =
      const VerificationMeta('lockedUntil');
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
      'locked_until', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastLoginAtMeta =
      const VerificationMeta('lastLoginAt');
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
      'last_login_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        displayName,
        emailNormalized,
        role,
        passwordHash,
        passwordSalt,
        passwordAlgorithm,
        passwordIterations,
        failedLoginAttempts,
        lockedUntil,
        lastLoginAt,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_users';
  @override
  VerificationContext validateIntegrity(Insertable<StaffUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email_normalized')) {
      context.handle(
          _emailNormalizedMeta,
          emailNormalized.isAcceptableOrUnknown(
              data['email_normalized']!, _emailNormalizedMeta));
    } else if (isInserting) {
      context.missing(_emailNormalizedMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('password_salt')) {
      context.handle(
          _passwordSaltMeta,
          passwordSalt.isAcceptableOrUnknown(
              data['password_salt']!, _passwordSaltMeta));
    } else if (isInserting) {
      context.missing(_passwordSaltMeta);
    }
    if (data.containsKey('password_algorithm')) {
      context.handle(
          _passwordAlgorithmMeta,
          passwordAlgorithm.isAcceptableOrUnknown(
              data['password_algorithm']!, _passwordAlgorithmMeta));
    } else if (isInserting) {
      context.missing(_passwordAlgorithmMeta);
    }
    if (data.containsKey('password_iterations')) {
      context.handle(
          _passwordIterationsMeta,
          passwordIterations.isAcceptableOrUnknown(
              data['password_iterations']!, _passwordIterationsMeta));
    } else if (isInserting) {
      context.missing(_passwordIterationsMeta);
    }
    if (data.containsKey('failed_login_attempts')) {
      context.handle(
          _failedLoginAttemptsMeta,
          failedLoginAttempts.isAcceptableOrUnknown(
              data['failed_login_attempts']!, _failedLoginAttemptsMeta));
    }
    if (data.containsKey('locked_until')) {
      context.handle(
          _lockedUntilMeta,
          lockedUntil.isAcceptableOrUnknown(
              data['locked_until']!, _lockedUntilMeta));
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
          _lastLoginAtMeta,
          lastLoginAt.isAcceptableOrUnknown(
              data['last_login_at']!, _lastLoginAtMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      emailNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}email_normalized'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      passwordSalt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_salt'])!,
      passwordAlgorithm: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}password_algorithm'])!,
      passwordIterations: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}password_iterations'])!,
      failedLoginAttempts: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}failed_login_attempts'])!,
      lockedUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}locked_until']),
      lastLoginAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_login_at']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StaffUsersTable createAlias(String alias) {
    return $StaffUsersTable(attachedDatabase, alias);
  }
}

class StaffUser extends DataClass implements Insertable<StaffUser> {
  final String id;
  final String displayName;
  final String emailNormalized;
  final String role;
  final String passwordHash;
  final String passwordSalt;
  final String passwordAlgorithm;
  final int passwordIterations;
  final int failedLoginAttempts;
  final DateTime? lockedUntil;
  final DateTime? lastLoginAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StaffUser(
      {required this.id,
      required this.displayName,
      required this.emailNormalized,
      required this.role,
      required this.passwordHash,
      required this.passwordSalt,
      required this.passwordAlgorithm,
      required this.passwordIterations,
      required this.failedLoginAttempts,
      this.lockedUntil,
      this.lastLoginAt,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['email_normalized'] = Variable<String>(emailNormalized);
    map['role'] = Variable<String>(role);
    map['password_hash'] = Variable<String>(passwordHash);
    map['password_salt'] = Variable<String>(passwordSalt);
    map['password_algorithm'] = Variable<String>(passwordAlgorithm);
    map['password_iterations'] = Variable<int>(passwordIterations);
    map['failed_login_attempts'] = Variable<int>(failedLoginAttempts);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StaffUsersCompanion toCompanion(bool nullToAbsent) {
    return StaffUsersCompanion(
      id: Value(id),
      displayName: Value(displayName),
      emailNormalized: Value(emailNormalized),
      role: Value(role),
      passwordHash: Value(passwordHash),
      passwordSalt: Value(passwordSalt),
      passwordAlgorithm: Value(passwordAlgorithm),
      passwordIterations: Value(passwordIterations),
      failedLoginAttempts: Value(failedLoginAttempts),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StaffUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffUser(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      emailNormalized: serializer.fromJson<String>(json['emailNormalized']),
      role: serializer.fromJson<String>(json['role']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      passwordSalt: serializer.fromJson<String>(json['passwordSalt']),
      passwordAlgorithm: serializer.fromJson<String>(json['passwordAlgorithm']),
      passwordIterations: serializer.fromJson<int>(json['passwordIterations']),
      failedLoginAttempts:
          serializer.fromJson<int>(json['failedLoginAttempts']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'emailNormalized': serializer.toJson<String>(emailNormalized),
      'role': serializer.toJson<String>(role),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'passwordSalt': serializer.toJson<String>(passwordSalt),
      'passwordAlgorithm': serializer.toJson<String>(passwordAlgorithm),
      'passwordIterations': serializer.toJson<int>(passwordIterations),
      'failedLoginAttempts': serializer.toJson<int>(failedLoginAttempts),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StaffUser copyWith(
          {String? id,
          String? displayName,
          String? emailNormalized,
          String? role,
          String? passwordHash,
          String? passwordSalt,
          String? passwordAlgorithm,
          int? passwordIterations,
          int? failedLoginAttempts,
          Value<DateTime?> lockedUntil = const Value.absent(),
          Value<DateTime?> lastLoginAt = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      StaffUser(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        emailNormalized: emailNormalized ?? this.emailNormalized,
        role: role ?? this.role,
        passwordHash: passwordHash ?? this.passwordHash,
        passwordSalt: passwordSalt ?? this.passwordSalt,
        passwordAlgorithm: passwordAlgorithm ?? this.passwordAlgorithm,
        passwordIterations: passwordIterations ?? this.passwordIterations,
        failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
        lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
        lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StaffUser copyWithCompanion(StaffUsersCompanion data) {
    return StaffUser(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      emailNormalized: data.emailNormalized.present
          ? data.emailNormalized.value
          : this.emailNormalized,
      role: data.role.present ? data.role.value : this.role,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      passwordSalt: data.passwordSalt.present
          ? data.passwordSalt.value
          : this.passwordSalt,
      passwordAlgorithm: data.passwordAlgorithm.present
          ? data.passwordAlgorithm.value
          : this.passwordAlgorithm,
      passwordIterations: data.passwordIterations.present
          ? data.passwordIterations.value
          : this.passwordIterations,
      failedLoginAttempts: data.failedLoginAttempts.present
          ? data.failedLoginAttempts.value
          : this.failedLoginAttempts,
      lockedUntil:
          data.lockedUntil.present ? data.lockedUntil.value : this.lockedUntil,
      lastLoginAt:
          data.lastLoginAt.present ? data.lastLoginAt.value : this.lastLoginAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffUser(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('emailNormalized: $emailNormalized, ')
          ..write('role: $role, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('passwordAlgorithm: $passwordAlgorithm, ')
          ..write('passwordIterations: $passwordIterations, ')
          ..write('failedLoginAttempts: $failedLoginAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      displayName,
      emailNormalized,
      role,
      passwordHash,
      passwordSalt,
      passwordAlgorithm,
      passwordIterations,
      failedLoginAttempts,
      lockedUntil,
      lastLoginAt,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffUser &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.emailNormalized == this.emailNormalized &&
          other.role == this.role &&
          other.passwordHash == this.passwordHash &&
          other.passwordSalt == this.passwordSalt &&
          other.passwordAlgorithm == this.passwordAlgorithm &&
          other.passwordIterations == this.passwordIterations &&
          other.failedLoginAttempts == this.failedLoginAttempts &&
          other.lockedUntil == this.lockedUntil &&
          other.lastLoginAt == this.lastLoginAt &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StaffUsersCompanion extends UpdateCompanion<StaffUser> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> emailNormalized;
  final Value<String> role;
  final Value<String> passwordHash;
  final Value<String> passwordSalt;
  final Value<String> passwordAlgorithm;
  final Value<int> passwordIterations;
  final Value<int> failedLoginAttempts;
  final Value<DateTime?> lockedUntil;
  final Value<DateTime?> lastLoginAt;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StaffUsersCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.emailNormalized = const Value.absent(),
    this.role = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.passwordAlgorithm = const Value.absent(),
    this.passwordIterations = const Value.absent(),
    this.failedLoginAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffUsersCompanion.insert({
    required String id,
    required String displayName,
    required String emailNormalized,
    required String role,
    required String passwordHash,
    required String passwordSalt,
    required String passwordAlgorithm,
    required int passwordIterations,
    this.failedLoginAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        displayName = Value(displayName),
        emailNormalized = Value(emailNormalized),
        role = Value(role),
        passwordHash = Value(passwordHash),
        passwordSalt = Value(passwordSalt),
        passwordAlgorithm = Value(passwordAlgorithm),
        passwordIterations = Value(passwordIterations),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<StaffUser> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? emailNormalized,
    Expression<String>? role,
    Expression<String>? passwordHash,
    Expression<String>? passwordSalt,
    Expression<String>? passwordAlgorithm,
    Expression<int>? passwordIterations,
    Expression<int>? failedLoginAttempts,
    Expression<DateTime>? lockedUntil,
    Expression<DateTime>? lastLoginAt,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (emailNormalized != null) 'email_normalized': emailNormalized,
      if (role != null) 'role': role,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (passwordSalt != null) 'password_salt': passwordSalt,
      if (passwordAlgorithm != null) 'password_algorithm': passwordAlgorithm,
      if (passwordIterations != null) 'password_iterations': passwordIterations,
      if (failedLoginAttempts != null)
        'failed_login_attempts': failedLoginAttempts,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffUsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? displayName,
      Value<String>? emailNormalized,
      Value<String>? role,
      Value<String>? passwordHash,
      Value<String>? passwordSalt,
      Value<String>? passwordAlgorithm,
      Value<int>? passwordIterations,
      Value<int>? failedLoginAttempts,
      Value<DateTime?>? lockedUntil,
      Value<DateTime?>? lastLoginAt,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return StaffUsersCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      emailNormalized: emailNormalized ?? this.emailNormalized,
      role: role ?? this.role,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      passwordAlgorithm: passwordAlgorithm ?? this.passwordAlgorithm,
      passwordIterations: passwordIterations ?? this.passwordIterations,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (emailNormalized.present) {
      map['email_normalized'] = Variable<String>(emailNormalized.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (passwordSalt.present) {
      map['password_salt'] = Variable<String>(passwordSalt.value);
    }
    if (passwordAlgorithm.present) {
      map['password_algorithm'] = Variable<String>(passwordAlgorithm.value);
    }
    if (passwordIterations.present) {
      map['password_iterations'] = Variable<int>(passwordIterations.value);
    }
    if (failedLoginAttempts.present) {
      map['failed_login_attempts'] = Variable<int>(failedLoginAttempts.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffUsersCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('emailNormalized: $emailNormalized, ')
          ..write('role: $role, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('passwordAlgorithm: $passwordAlgorithm, ')
          ..write('passwordIterations: $passwordIterations, ')
          ..write('failedLoginAttempts: $failedLoginAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffBranchAccessTable extends StaffBranchAccess
    with TableInfo<$StaffBranchAccessTable, StaffBranchAccessData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffBranchAccessTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _staffUserIdMeta =
      const VerificationMeta('staffUserId');
  @override
  late final GeneratedColumn<String> staffUserId = GeneratedColumn<String>(
      'staff_user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES staff_users (id)'));
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _grantedAtMeta =
      const VerificationMeta('grantedAt');
  @override
  late final GeneratedColumn<DateTime> grantedAt = GeneratedColumn<DateTime>(
      'granted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _grantedByMeta =
      const VerificationMeta('grantedBy');
  @override
  late final GeneratedColumn<String> grantedBy = GeneratedColumn<String>(
      'granted_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [staffUserId, branchId, grantedAt, grantedBy];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_branch_access';
  @override
  VerificationContext validateIntegrity(
      Insertable<StaffBranchAccessData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('staff_user_id')) {
      context.handle(
          _staffUserIdMeta,
          staffUserId.isAcceptableOrUnknown(
              data['staff_user_id']!, _staffUserIdMeta));
    } else if (isInserting) {
      context.missing(_staffUserIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('granted_at')) {
      context.handle(_grantedAtMeta,
          grantedAt.isAcceptableOrUnknown(data['granted_at']!, _grantedAtMeta));
    } else if (isInserting) {
      context.missing(_grantedAtMeta);
    }
    if (data.containsKey('granted_by')) {
      context.handle(_grantedByMeta,
          grantedBy.isAcceptableOrUnknown(data['granted_by']!, _grantedByMeta));
    } else if (isInserting) {
      context.missing(_grantedByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {staffUserId, branchId};
  @override
  StaffBranchAccessData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffBranchAccessData(
      staffUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}staff_user_id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      grantedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}granted_at'])!,
      grantedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}granted_by'])!,
    );
  }

  @override
  $StaffBranchAccessTable createAlias(String alias) {
    return $StaffBranchAccessTable(attachedDatabase, alias);
  }
}

class StaffBranchAccessData extends DataClass
    implements Insertable<StaffBranchAccessData> {
  final String staffUserId;
  final String branchId;
  final DateTime grantedAt;
  final String grantedBy;
  const StaffBranchAccessData(
      {required this.staffUserId,
      required this.branchId,
      required this.grantedAt,
      required this.grantedBy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['staff_user_id'] = Variable<String>(staffUserId);
    map['branch_id'] = Variable<String>(branchId);
    map['granted_at'] = Variable<DateTime>(grantedAt);
    map['granted_by'] = Variable<String>(grantedBy);
    return map;
  }

  StaffBranchAccessCompanion toCompanion(bool nullToAbsent) {
    return StaffBranchAccessCompanion(
      staffUserId: Value(staffUserId),
      branchId: Value(branchId),
      grantedAt: Value(grantedAt),
      grantedBy: Value(grantedBy),
    );
  }

  factory StaffBranchAccessData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffBranchAccessData(
      staffUserId: serializer.fromJson<String>(json['staffUserId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      grantedAt: serializer.fromJson<DateTime>(json['grantedAt']),
      grantedBy: serializer.fromJson<String>(json['grantedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'staffUserId': serializer.toJson<String>(staffUserId),
      'branchId': serializer.toJson<String>(branchId),
      'grantedAt': serializer.toJson<DateTime>(grantedAt),
      'grantedBy': serializer.toJson<String>(grantedBy),
    };
  }

  StaffBranchAccessData copyWith(
          {String? staffUserId,
          String? branchId,
          DateTime? grantedAt,
          String? grantedBy}) =>
      StaffBranchAccessData(
        staffUserId: staffUserId ?? this.staffUserId,
        branchId: branchId ?? this.branchId,
        grantedAt: grantedAt ?? this.grantedAt,
        grantedBy: grantedBy ?? this.grantedBy,
      );
  StaffBranchAccessData copyWithCompanion(StaffBranchAccessCompanion data) {
    return StaffBranchAccessData(
      staffUserId:
          data.staffUserId.present ? data.staffUserId.value : this.staffUserId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      grantedAt: data.grantedAt.present ? data.grantedAt.value : this.grantedAt,
      grantedBy: data.grantedBy.present ? data.grantedBy.value : this.grantedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffBranchAccessData(')
          ..write('staffUserId: $staffUserId, ')
          ..write('branchId: $branchId, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('grantedBy: $grantedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(staffUserId, branchId, grantedAt, grantedBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffBranchAccessData &&
          other.staffUserId == this.staffUserId &&
          other.branchId == this.branchId &&
          other.grantedAt == this.grantedAt &&
          other.grantedBy == this.grantedBy);
}

class StaffBranchAccessCompanion
    extends UpdateCompanion<StaffBranchAccessData> {
  final Value<String> staffUserId;
  final Value<String> branchId;
  final Value<DateTime> grantedAt;
  final Value<String> grantedBy;
  final Value<int> rowid;
  const StaffBranchAccessCompanion({
    this.staffUserId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.grantedAt = const Value.absent(),
    this.grantedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffBranchAccessCompanion.insert({
    required String staffUserId,
    required String branchId,
    required DateTime grantedAt,
    required String grantedBy,
    this.rowid = const Value.absent(),
  })  : staffUserId = Value(staffUserId),
        branchId = Value(branchId),
        grantedAt = Value(grantedAt),
        grantedBy = Value(grantedBy);
  static Insertable<StaffBranchAccessData> custom({
    Expression<String>? staffUserId,
    Expression<String>? branchId,
    Expression<DateTime>? grantedAt,
    Expression<String>? grantedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (staffUserId != null) 'staff_user_id': staffUserId,
      if (branchId != null) 'branch_id': branchId,
      if (grantedAt != null) 'granted_at': grantedAt,
      if (grantedBy != null) 'granted_by': grantedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffBranchAccessCompanion copyWith(
      {Value<String>? staffUserId,
      Value<String>? branchId,
      Value<DateTime>? grantedAt,
      Value<String>? grantedBy,
      Value<int>? rowid}) {
    return StaffBranchAccessCompanion(
      staffUserId: staffUserId ?? this.staffUserId,
      branchId: branchId ?? this.branchId,
      grantedAt: grantedAt ?? this.grantedAt,
      grantedBy: grantedBy ?? this.grantedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (staffUserId.present) {
      map['staff_user_id'] = Variable<String>(staffUserId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (grantedAt.present) {
      map['granted_at'] = Variable<DateTime>(grantedAt.value);
    }
    if (grantedBy.present) {
      map['granted_by'] = Variable<String>(grantedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffBranchAccessCompanion(')
          ..write('staffUserId: $staffUserId, ')
          ..write('branchId: $branchId, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('grantedBy: $grantedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taxCategoryMeta =
      const VerificationMeta('taxCategory');
  @override
  late final GeneratedColumn<String> taxCategory = GeneratedColumn<String>(
      'tax_category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceCentavosMeta =
      const VerificationMeta('unitPriceCentavos');
  @override
  late final GeneratedColumn<int> unitPriceCentavos = GeneratedColumn<int>(
      'unit_price_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('uncategorized'));
  static const VerificationMeta _colorArgbMeta =
      const VerificationMeta('colorArgb');
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
      'color_argb', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFF6F4E37));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sku,
        name,
        taxCategory,
        unitPriceCentavos,
        categoryId,
        colorArgb,
        isActive,
        version,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tax_category')) {
      context.handle(
          _taxCategoryMeta,
          taxCategory.isAcceptableOrUnknown(
              data['tax_category']!, _taxCategoryMeta));
    } else if (isInserting) {
      context.missing(_taxCategoryMeta);
    }
    if (data.containsKey('unit_price_centavos')) {
      context.handle(
          _unitPriceCentavosMeta,
          unitPriceCentavos.isAcceptableOrUnknown(
              data['unit_price_centavos']!, _unitPriceCentavosMeta));
    } else if (isInserting) {
      context.missing(_unitPriceCentavosMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('color_argb')) {
      context.handle(_colorArgbMeta,
          colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      taxCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tax_category'])!,
      unitPriceCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}unit_price_centavos'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      colorArgb: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_argb'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String sku;
  final String name;
  final String taxCategory;
  final int unitPriceCentavos;
  final String categoryId;
  final int colorArgb;
  final bool isActive;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Product(
      {required this.id,
      required this.sku,
      required this.name,
      required this.taxCategory,
      required this.unitPriceCentavos,
      required this.categoryId,
      required this.colorArgb,
      required this.isActive,
      required this.version,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sku'] = Variable<String>(sku);
    map['name'] = Variable<String>(name);
    map['tax_category'] = Variable<String>(taxCategory);
    map['unit_price_centavos'] = Variable<int>(unitPriceCentavos);
    map['category_id'] = Variable<String>(categoryId);
    map['color_argb'] = Variable<int>(colorArgb);
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      sku: Value(sku),
      name: Value(name),
      taxCategory: Value(taxCategory),
      unitPriceCentavos: Value(unitPriceCentavos),
      categoryId: Value(categoryId),
      colorArgb: Value(colorArgb),
      isActive: Value(isActive),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      sku: serializer.fromJson<String>(json['sku']),
      name: serializer.fromJson<String>(json['name']),
      taxCategory: serializer.fromJson<String>(json['taxCategory']),
      unitPriceCentavos: serializer.fromJson<int>(json['unitPriceCentavos']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sku': serializer.toJson<String>(sku),
      'name': serializer.toJson<String>(name),
      'taxCategory': serializer.toJson<String>(taxCategory),
      'unitPriceCentavos': serializer.toJson<int>(unitPriceCentavos),
      'categoryId': serializer.toJson<String>(categoryId),
      'colorArgb': serializer.toJson<int>(colorArgb),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Product copyWith(
          {String? id,
          String? sku,
          String? name,
          String? taxCategory,
          int? unitPriceCentavos,
          String? categoryId,
          int? colorArgb,
          bool? isActive,
          int? version,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Product(
        id: id ?? this.id,
        sku: sku ?? this.sku,
        name: name ?? this.name,
        taxCategory: taxCategory ?? this.taxCategory,
        unitPriceCentavos: unitPriceCentavos ?? this.unitPriceCentavos,
        categoryId: categoryId ?? this.categoryId,
        colorArgb: colorArgb ?? this.colorArgb,
        isActive: isActive ?? this.isActive,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      sku: data.sku.present ? data.sku.value : this.sku,
      name: data.name.present ? data.name.value : this.name,
      taxCategory:
          data.taxCategory.present ? data.taxCategory.value : this.taxCategory,
      unitPriceCentavos: data.unitPriceCentavos.present
          ? data.unitPriceCentavos.value
          : this.unitPriceCentavos,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('taxCategory: $taxCategory, ')
          ..write('unitPriceCentavos: $unitPriceCentavos, ')
          ..write('categoryId: $categoryId, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sku, name, taxCategory, unitPriceCentavos,
      categoryId, colorArgb, isActive, version, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.name == this.name &&
          other.taxCategory == this.taxCategory &&
          other.unitPriceCentavos == this.unitPriceCentavos &&
          other.categoryId == this.categoryId &&
          other.colorArgb == this.colorArgb &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> sku;
  final Value<String> name;
  final Value<String> taxCategory;
  final Value<int> unitPriceCentavos;
  final Value<String> categoryId;
  final Value<int> colorArgb;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.name = const Value.absent(),
    this.taxCategory = const Value.absent(),
    this.unitPriceCentavos = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String sku,
    required String name,
    required String taxCategory,
    required int unitPriceCentavos,
    this.categoryId = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sku = Value(sku),
        name = Value(name),
        taxCategory = Value(taxCategory),
        unitPriceCentavos = Value(unitPriceCentavos),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? sku,
    Expression<String>? name,
    Expression<String>? taxCategory,
    Expression<int>? unitPriceCentavos,
    Expression<String>? categoryId,
    Expression<int>? colorArgb,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (taxCategory != null) 'tax_category': taxCategory,
      if (unitPriceCentavos != null) 'unit_price_centavos': unitPriceCentavos,
      if (categoryId != null) 'category_id': categoryId,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sku,
      Value<String>? name,
      Value<String>? taxCategory,
      Value<int>? unitPriceCentavos,
      Value<String>? categoryId,
      Value<int>? colorArgb,
      Value<bool>? isActive,
      Value<int>? version,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      taxCategory: taxCategory ?? this.taxCategory,
      unitPriceCentavos: unitPriceCentavos ?? this.unitPriceCentavos,
      categoryId: categoryId ?? this.categoryId,
      colorArgb: colorArgb ?? this.colorArgb,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (taxCategory.present) {
      map['tax_category'] = Variable<String>(taxCategory.value);
    }
    if (unitPriceCentavos.present) {
      map['unit_price_centavos'] = Variable<int>(unitPriceCentavos.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('taxCategory: $taxCategory, ')
          ..write('unitPriceCentavos: $unitPriceCentavos, ')
          ..write('categoryId: $categoryId, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BranchInventoriesTable extends BranchInventories
    with TableInfo<$BranchInventoriesTable, BranchInventory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchInventoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _stockOnHandMeta =
      const VerificationMeta('stockOnHand');
  @override
  late final GeneratedColumn<int> stockOnHand = GeneratedColumn<int>(
      'stock_on_hand', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reorderPointMeta =
      const VerificationMeta('reorderPoint');
  @override
  late final GeneratedColumn<int> reorderPoint = GeneratedColumn<int>(
      'reorder_point', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [branchId, productId, stockOnHand, reorderPoint, version, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branch_inventories';
  @override
  VerificationContext validateIntegrity(Insertable<BranchInventory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('stock_on_hand')) {
      context.handle(
          _stockOnHandMeta,
          stockOnHand.isAcceptableOrUnknown(
              data['stock_on_hand']!, _stockOnHandMeta));
    }
    if (data.containsKey('reorder_point')) {
      context.handle(
          _reorderPointMeta,
          reorderPoint.isAcceptableOrUnknown(
              data['reorder_point']!, _reorderPointMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {branchId, productId};
  @override
  BranchInventory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BranchInventory(
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      stockOnHand: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_on_hand'])!,
      reorderPoint: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reorder_point'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BranchInventoriesTable createAlias(String alias) {
    return $BranchInventoriesTable(attachedDatabase, alias);
  }
}

class BranchInventory extends DataClass implements Insertable<BranchInventory> {
  final String branchId;
  final String productId;
  final int stockOnHand;
  final int reorderPoint;
  final int version;
  final DateTime updatedAt;
  const BranchInventory(
      {required this.branchId,
      required this.productId,
      required this.stockOnHand,
      required this.reorderPoint,
      required this.version,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['branch_id'] = Variable<String>(branchId);
    map['product_id'] = Variable<String>(productId);
    map['stock_on_hand'] = Variable<int>(stockOnHand);
    map['reorder_point'] = Variable<int>(reorderPoint);
    map['version'] = Variable<int>(version);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BranchInventoriesCompanion toCompanion(bool nullToAbsent) {
    return BranchInventoriesCompanion(
      branchId: Value(branchId),
      productId: Value(productId),
      stockOnHand: Value(stockOnHand),
      reorderPoint: Value(reorderPoint),
      version: Value(version),
      updatedAt: Value(updatedAt),
    );
  }

  factory BranchInventory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BranchInventory(
      branchId: serializer.fromJson<String>(json['branchId']),
      productId: serializer.fromJson<String>(json['productId']),
      stockOnHand: serializer.fromJson<int>(json['stockOnHand']),
      reorderPoint: serializer.fromJson<int>(json['reorderPoint']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'branchId': serializer.toJson<String>(branchId),
      'productId': serializer.toJson<String>(productId),
      'stockOnHand': serializer.toJson<int>(stockOnHand),
      'reorderPoint': serializer.toJson<int>(reorderPoint),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BranchInventory copyWith(
          {String? branchId,
          String? productId,
          int? stockOnHand,
          int? reorderPoint,
          int? version,
          DateTime? updatedAt}) =>
      BranchInventory(
        branchId: branchId ?? this.branchId,
        productId: productId ?? this.productId,
        stockOnHand: stockOnHand ?? this.stockOnHand,
        reorderPoint: reorderPoint ?? this.reorderPoint,
        version: version ?? this.version,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  BranchInventory copyWithCompanion(BranchInventoriesCompanion data) {
    return BranchInventory(
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      productId: data.productId.present ? data.productId.value : this.productId,
      stockOnHand:
          data.stockOnHand.present ? data.stockOnHand.value : this.stockOnHand,
      reorderPoint: data.reorderPoint.present
          ? data.reorderPoint.value
          : this.reorderPoint,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BranchInventory(')
          ..write('branchId: $branchId, ')
          ..write('productId: $productId, ')
          ..write('stockOnHand: $stockOnHand, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      branchId, productId, stockOnHand, reorderPoint, version, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BranchInventory &&
          other.branchId == this.branchId &&
          other.productId == this.productId &&
          other.stockOnHand == this.stockOnHand &&
          other.reorderPoint == this.reorderPoint &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt);
}

class BranchInventoriesCompanion extends UpdateCompanion<BranchInventory> {
  final Value<String> branchId;
  final Value<String> productId;
  final Value<int> stockOnHand;
  final Value<int> reorderPoint;
  final Value<int> version;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BranchInventoriesCompanion({
    this.branchId = const Value.absent(),
    this.productId = const Value.absent(),
    this.stockOnHand = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchInventoriesCompanion.insert({
    required String branchId,
    required String productId,
    this.stockOnHand = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : branchId = Value(branchId),
        productId = Value(productId),
        updatedAt = Value(updatedAt);
  static Insertable<BranchInventory> custom({
    Expression<String>? branchId,
    Expression<String>? productId,
    Expression<int>? stockOnHand,
    Expression<int>? reorderPoint,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (branchId != null) 'branch_id': branchId,
      if (productId != null) 'product_id': productId,
      if (stockOnHand != null) 'stock_on_hand': stockOnHand,
      if (reorderPoint != null) 'reorder_point': reorderPoint,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchInventoriesCompanion copyWith(
      {Value<String>? branchId,
      Value<String>? productId,
      Value<int>? stockOnHand,
      Value<int>? reorderPoint,
      Value<int>? version,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return BranchInventoriesCompanion(
      branchId: branchId ?? this.branchId,
      productId: productId ?? this.productId,
      stockOnHand: stockOnHand ?? this.stockOnHand,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (stockOnHand.present) {
      map['stock_on_hand'] = Variable<int>(stockOnHand.value);
    }
    if (reorderPoint.present) {
      map['reorder_point'] = Variable<int>(reorderPoint.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchInventoriesCompanion(')
          ..write('branchId: $branchId, ')
          ..write('productId: $productId, ')
          ..write('stockOnHand: $stockOnHand, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceSequencesTable extends InvoiceSequences
    with TableInfo<$InvoiceSequencesTable, InvoiceSequence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceSequencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _terminalIdMeta =
      const VerificationMeta('terminalId');
  @override
  late final GeneratedColumn<String> terminalId = GeneratedColumn<String>(
      'terminal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES terminals (id)'));
  static const VerificationMeta _nextValueMeta =
      const VerificationMeta('nextValue');
  @override
  late final GeneratedColumn<int> nextValue = GeneratedColumn<int>(
      'next_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [terminalId, nextValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_sequences';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceSequence> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('terminal_id')) {
      context.handle(
          _terminalIdMeta,
          terminalId.isAcceptableOrUnknown(
              data['terminal_id']!, _terminalIdMeta));
    } else if (isInserting) {
      context.missing(_terminalIdMeta);
    }
    if (data.containsKey('next_value')) {
      context.handle(_nextValueMeta,
          nextValue.isAcceptableOrUnknown(data['next_value']!, _nextValueMeta));
    } else if (isInserting) {
      context.missing(_nextValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {terminalId};
  @override
  InvoiceSequence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceSequence(
      terminalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}terminal_id'])!,
      nextValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}next_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InvoiceSequencesTable createAlias(String alias) {
    return $InvoiceSequencesTable(attachedDatabase, alias);
  }
}

class InvoiceSequence extends DataClass implements Insertable<InvoiceSequence> {
  final String terminalId;
  final int nextValue;
  final DateTime updatedAt;
  const InvoiceSequence(
      {required this.terminalId,
      required this.nextValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['terminal_id'] = Variable<String>(terminalId);
    map['next_value'] = Variable<int>(nextValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoiceSequencesCompanion toCompanion(bool nullToAbsent) {
    return InvoiceSequencesCompanion(
      terminalId: Value(terminalId),
      nextValue: Value(nextValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory InvoiceSequence.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceSequence(
      terminalId: serializer.fromJson<String>(json['terminalId']),
      nextValue: serializer.fromJson<int>(json['nextValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'terminalId': serializer.toJson<String>(terminalId),
      'nextValue': serializer.toJson<int>(nextValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InvoiceSequence copyWith(
          {String? terminalId, int? nextValue, DateTime? updatedAt}) =>
      InvoiceSequence(
        terminalId: terminalId ?? this.terminalId,
        nextValue: nextValue ?? this.nextValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InvoiceSequence copyWithCompanion(InvoiceSequencesCompanion data) {
    return InvoiceSequence(
      terminalId:
          data.terminalId.present ? data.terminalId.value : this.terminalId,
      nextValue: data.nextValue.present ? data.nextValue.value : this.nextValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceSequence(')
          ..write('terminalId: $terminalId, ')
          ..write('nextValue: $nextValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(terminalId, nextValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceSequence &&
          other.terminalId == this.terminalId &&
          other.nextValue == this.nextValue &&
          other.updatedAt == this.updatedAt);
}

class InvoiceSequencesCompanion extends UpdateCompanion<InvoiceSequence> {
  final Value<String> terminalId;
  final Value<int> nextValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InvoiceSequencesCompanion({
    this.terminalId = const Value.absent(),
    this.nextValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceSequencesCompanion.insert({
    required String terminalId,
    required int nextValue,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : terminalId = Value(terminalId),
        nextValue = Value(nextValue),
        updatedAt = Value(updatedAt);
  static Insertable<InvoiceSequence> custom({
    Expression<String>? terminalId,
    Expression<int>? nextValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (terminalId != null) 'terminal_id': terminalId,
      if (nextValue != null) 'next_value': nextValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceSequencesCompanion copyWith(
      {Value<String>? terminalId,
      Value<int>? nextValue,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return InvoiceSequencesCompanion(
      terminalId: terminalId ?? this.terminalId,
      nextValue: nextValue ?? this.nextValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (terminalId.present) {
      map['terminal_id'] = Variable<String>(terminalId.value);
    }
    if (nextValue.present) {
      map['next_value'] = Variable<int>(nextValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceSequencesCompanion(')
          ..write('terminalId: $terminalId, ')
          ..write('nextValue: $nextValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _terminalIdMeta =
      const VerificationMeta('terminalId');
  @override
  late final GeneratedColumn<String> terminalId = GeneratedColumn<String>(
      'terminal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES terminals (id)'));
  static const VerificationMeta _issuedAtMeta =
      const VerificationMeta('issuedAt');
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
      'issued_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentReferenceMeta =
      const VerificationMeta('paymentReference');
  @override
  late final GeneratedColumn<String> paymentReference = GeneratedColumn<String>(
      'payment_reference', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalCentavosMeta =
      const VerificationMeta('totalCentavos');
  @override
  late final GeneratedColumn<int> totalCentavos = GeneratedColumn<int>(
      'total_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _vatableSalesCentavosMeta =
      const VerificationMeta('vatableSalesCentavos');
  @override
  late final GeneratedColumn<int> vatableSalesCentavos = GeneratedColumn<int>(
      'vatable_sales_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _vatAmountCentavosMeta =
      const VerificationMeta('vatAmountCentavos');
  @override
  late final GeneratedColumn<int> vatAmountCentavos = GeneratedColumn<int>(
      'vat_amount_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _zeroRatedSalesCentavosMeta =
      const VerificationMeta('zeroRatedSalesCentavos');
  @override
  late final GeneratedColumn<int> zeroRatedSalesCentavos = GeneratedColumn<int>(
      'zero_rated_sales_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _vatExemptSalesCentavosMeta =
      const VerificationMeta('vatExemptSalesCentavos');
  @override
  late final GeneratedColumn<int> vatExemptSalesCentavos = GeneratedColumn<int>(
      'vat_exempt_sales_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nonVatSalesCentavosMeta =
      const VerificationMeta('nonVatSalesCentavos');
  @override
  late final GeneratedColumn<int> nonVatSalesCentavos = GeneratedColumn<int>(
      'non_vat_sales_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sellerNameMeta =
      const VerificationMeta('sellerName');
  @override
  late final GeneratedColumn<String> sellerName = GeneratedColumn<String>(
      'seller_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellerTinMeta =
      const VerificationMeta('sellerTin');
  @override
  late final GeneratedColumn<String> sellerTin = GeneratedColumn<String>(
      'seller_tin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellerAddressMeta =
      const VerificationMeta('sellerAddress');
  @override
  late final GeneratedColumn<String> sellerAddress = GeneratedColumn<String>(
      'seller_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellerRegistrationTypeMeta =
      const VerificationMeta('sellerRegistrationType');
  @override
  late final GeneratedColumn<String> sellerRegistrationType =
      GeneratedColumn<String>('seller_registration_type', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchCodeMeta =
      const VerificationMeta('branchCode');
  @override
  late final GeneratedColumn<String> branchCode = GeneratedColumn<String>(
      'branch_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _machineIdentificationNumberMeta =
      const VerificationMeta('machineIdentificationNumber');
  @override
  late final GeneratedColumn<String> machineIdentificationNumber =
      GeneratedColumn<String>(
          'machine_identification_number', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _permitToUseNumberMeta =
      const VerificationMeta('permitToUseNumber');
  @override
  late final GeneratedColumn<String> permitToUseNumber =
      GeneratedColumn<String>('permit_to_use_number', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _machineSerialNumberMeta =
      const VerificationMeta('machineSerialNumber');
  @override
  late final GeneratedColumn<String> machineSerialNumber =
      GeneratedColumn<String>('machine_serial_number', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _softwareNameMeta =
      const VerificationMeta('softwareName');
  @override
  late final GeneratedColumn<String> softwareName = GeneratedColumn<String>(
      'software_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _softwareVersionMeta =
      const VerificationMeta('softwareVersion');
  @override
  late final GeneratedColumn<String> softwareVersion = GeneratedColumn<String>(
      'software_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _buyerNameMeta =
      const VerificationMeta('buyerName');
  @override
  late final GeneratedColumn<String> buyerName = GeneratedColumn<String>(
      'buyer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buyerTinMeta =
      const VerificationMeta('buyerTin');
  @override
  late final GeneratedColumn<String> buyerTin = GeneratedColumn<String>(
      'buyer_tin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buyerAddressMeta =
      const VerificationMeta('buyerAddress');
  @override
  late final GeneratedColumn<String> buyerAddress = GeneratedColumn<String>(
      'buyer_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _voidedAtMeta =
      const VerificationMeta('voidedAt');
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
      'voided_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _voidReasonMeta =
      const VerificationMeta('voidReason');
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
      'void_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalInvoiceIdMeta =
      const VerificationMeta('originalInvoiceId');
  @override
  late final GeneratedColumn<String> originalInvoiceId =
      GeneratedColumn<String>('original_invoice_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceNumber,
        branchId,
        terminalId,
        issuedAt,
        status,
        paymentMethod,
        paymentReference,
        totalCentavos,
        vatableSalesCentavos,
        vatAmountCentavos,
        zeroRatedSalesCentavos,
        vatExemptSalesCentavos,
        nonVatSalesCentavos,
        sellerName,
        sellerTin,
        sellerAddress,
        sellerRegistrationType,
        branchCode,
        machineIdentificationNumber,
        permitToUseNumber,
        machineSerialNumber,
        softwareName,
        softwareVersion,
        buyerName,
        buyerTin,
        buyerAddress,
        voidedAt,
        voidReason,
        originalInvoiceId,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('terminal_id')) {
      context.handle(
          _terminalIdMeta,
          terminalId.isAcceptableOrUnknown(
              data['terminal_id']!, _terminalIdMeta));
    } else if (isInserting) {
      context.missing(_terminalIdMeta);
    }
    if (data.containsKey('issued_at')) {
      context.handle(_issuedAtMeta,
          issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta));
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('payment_reference')) {
      context.handle(
          _paymentReferenceMeta,
          paymentReference.isAcceptableOrUnknown(
              data['payment_reference']!, _paymentReferenceMeta));
    } else if (isInserting) {
      context.missing(_paymentReferenceMeta);
    }
    if (data.containsKey('total_centavos')) {
      context.handle(
          _totalCentavosMeta,
          totalCentavos.isAcceptableOrUnknown(
              data['total_centavos']!, _totalCentavosMeta));
    } else if (isInserting) {
      context.missing(_totalCentavosMeta);
    }
    if (data.containsKey('vatable_sales_centavos')) {
      context.handle(
          _vatableSalesCentavosMeta,
          vatableSalesCentavos.isAcceptableOrUnknown(
              data['vatable_sales_centavos']!, _vatableSalesCentavosMeta));
    } else if (isInserting) {
      context.missing(_vatableSalesCentavosMeta);
    }
    if (data.containsKey('vat_amount_centavos')) {
      context.handle(
          _vatAmountCentavosMeta,
          vatAmountCentavos.isAcceptableOrUnknown(
              data['vat_amount_centavos']!, _vatAmountCentavosMeta));
    } else if (isInserting) {
      context.missing(_vatAmountCentavosMeta);
    }
    if (data.containsKey('zero_rated_sales_centavos')) {
      context.handle(
          _zeroRatedSalesCentavosMeta,
          zeroRatedSalesCentavos.isAcceptableOrUnknown(
              data['zero_rated_sales_centavos']!, _zeroRatedSalesCentavosMeta));
    } else if (isInserting) {
      context.missing(_zeroRatedSalesCentavosMeta);
    }
    if (data.containsKey('vat_exempt_sales_centavos')) {
      context.handle(
          _vatExemptSalesCentavosMeta,
          vatExemptSalesCentavos.isAcceptableOrUnknown(
              data['vat_exempt_sales_centavos']!, _vatExemptSalesCentavosMeta));
    } else if (isInserting) {
      context.missing(_vatExemptSalesCentavosMeta);
    }
    if (data.containsKey('non_vat_sales_centavos')) {
      context.handle(
          _nonVatSalesCentavosMeta,
          nonVatSalesCentavos.isAcceptableOrUnknown(
              data['non_vat_sales_centavos']!, _nonVatSalesCentavosMeta));
    } else if (isInserting) {
      context.missing(_nonVatSalesCentavosMeta);
    }
    if (data.containsKey('seller_name')) {
      context.handle(
          _sellerNameMeta,
          sellerName.isAcceptableOrUnknown(
              data['seller_name']!, _sellerNameMeta));
    } else if (isInserting) {
      context.missing(_sellerNameMeta);
    }
    if (data.containsKey('seller_tin')) {
      context.handle(_sellerTinMeta,
          sellerTin.isAcceptableOrUnknown(data['seller_tin']!, _sellerTinMeta));
    } else if (isInserting) {
      context.missing(_sellerTinMeta);
    }
    if (data.containsKey('seller_address')) {
      context.handle(
          _sellerAddressMeta,
          sellerAddress.isAcceptableOrUnknown(
              data['seller_address']!, _sellerAddressMeta));
    } else if (isInserting) {
      context.missing(_sellerAddressMeta);
    }
    if (data.containsKey('seller_registration_type')) {
      context.handle(
          _sellerRegistrationTypeMeta,
          sellerRegistrationType.isAcceptableOrUnknown(
              data['seller_registration_type']!, _sellerRegistrationTypeMeta));
    } else if (isInserting) {
      context.missing(_sellerRegistrationTypeMeta);
    }
    if (data.containsKey('branch_code')) {
      context.handle(
          _branchCodeMeta,
          branchCode.isAcceptableOrUnknown(
              data['branch_code']!, _branchCodeMeta));
    } else if (isInserting) {
      context.missing(_branchCodeMeta);
    }
    if (data.containsKey('machine_identification_number')) {
      context.handle(
          _machineIdentificationNumberMeta,
          machineIdentificationNumber.isAcceptableOrUnknown(
              data['machine_identification_number']!,
              _machineIdentificationNumberMeta));
    } else if (isInserting) {
      context.missing(_machineIdentificationNumberMeta);
    }
    if (data.containsKey('permit_to_use_number')) {
      context.handle(
          _permitToUseNumberMeta,
          permitToUseNumber.isAcceptableOrUnknown(
              data['permit_to_use_number']!, _permitToUseNumberMeta));
    } else if (isInserting) {
      context.missing(_permitToUseNumberMeta);
    }
    if (data.containsKey('machine_serial_number')) {
      context.handle(
          _machineSerialNumberMeta,
          machineSerialNumber.isAcceptableOrUnknown(
              data['machine_serial_number']!, _machineSerialNumberMeta));
    } else if (isInserting) {
      context.missing(_machineSerialNumberMeta);
    }
    if (data.containsKey('software_name')) {
      context.handle(
          _softwareNameMeta,
          softwareName.isAcceptableOrUnknown(
              data['software_name']!, _softwareNameMeta));
    } else if (isInserting) {
      context.missing(_softwareNameMeta);
    }
    if (data.containsKey('software_version')) {
      context.handle(
          _softwareVersionMeta,
          softwareVersion.isAcceptableOrUnknown(
              data['software_version']!, _softwareVersionMeta));
    } else if (isInserting) {
      context.missing(_softwareVersionMeta);
    }
    if (data.containsKey('buyer_name')) {
      context.handle(_buyerNameMeta,
          buyerName.isAcceptableOrUnknown(data['buyer_name']!, _buyerNameMeta));
    }
    if (data.containsKey('buyer_tin')) {
      context.handle(_buyerTinMeta,
          buyerTin.isAcceptableOrUnknown(data['buyer_tin']!, _buyerTinMeta));
    }
    if (data.containsKey('buyer_address')) {
      context.handle(
          _buyerAddressMeta,
          buyerAddress.isAcceptableOrUnknown(
              data['buyer_address']!, _buyerAddressMeta));
    }
    if (data.containsKey('voided_at')) {
      context.handle(_voidedAtMeta,
          voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta));
    }
    if (data.containsKey('void_reason')) {
      context.handle(
          _voidReasonMeta,
          voidReason.isAcceptableOrUnknown(
              data['void_reason']!, _voidReasonMeta));
    }
    if (data.containsKey('original_invoice_id')) {
      context.handle(
          _originalInvoiceIdMeta,
          originalInvoiceId.isAcceptableOrUnknown(
              data['original_invoice_id']!, _originalInvoiceIdMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      terminalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}terminal_id'])!,
      issuedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}issued_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      paymentReference: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}payment_reference'])!,
      totalCentavos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_centavos'])!,
      vatableSalesCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}vatable_sales_centavos'])!,
      vatAmountCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}vat_amount_centavos'])!,
      zeroRatedSalesCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}zero_rated_sales_centavos'])!,
      vatExemptSalesCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}vat_exempt_sales_centavos'])!,
      nonVatSalesCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}non_vat_sales_centavos'])!,
      sellerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller_name'])!,
      sellerTin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller_tin'])!,
      sellerAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller_address'])!,
      sellerRegistrationType: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}seller_registration_type'])!,
      branchCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_code'])!,
      machineIdentificationNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}machine_identification_number'])!,
      permitToUseNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}permit_to_use_number'])!,
      machineSerialNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}machine_serial_number'])!,
      softwareName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}software_name'])!,
      softwareVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}software_version'])!,
      buyerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer_name']),
      buyerTin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer_tin']),
      buyerAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer_address']),
      voidedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}voided_at']),
      voidReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}void_reason']),
      originalInvoiceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_invoice_id']),
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String invoiceNumber;
  final String branchId;
  final String terminalId;
  final DateTime issuedAt;
  final String status;
  final String paymentMethod;
  final String paymentReference;
  final int totalCentavos;
  final int vatableSalesCentavos;
  final int vatAmountCentavos;
  final int zeroRatedSalesCentavos;
  final int vatExemptSalesCentavos;
  final int nonVatSalesCentavos;
  final String sellerName;
  final String sellerTin;
  final String sellerAddress;
  final String sellerRegistrationType;
  final String branchCode;
  final String machineIdentificationNumber;
  final String permitToUseNumber;
  final String machineSerialNumber;
  final String softwareName;
  final String softwareVersion;
  final String? buyerName;
  final String? buyerTin;
  final String? buyerAddress;
  final DateTime? voidedAt;
  final String? voidReason;
  final String? originalInvoiceId;
  final bool synced;
  const Invoice(
      {required this.id,
      required this.invoiceNumber,
      required this.branchId,
      required this.terminalId,
      required this.issuedAt,
      required this.status,
      required this.paymentMethod,
      required this.paymentReference,
      required this.totalCentavos,
      required this.vatableSalesCentavos,
      required this.vatAmountCentavos,
      required this.zeroRatedSalesCentavos,
      required this.vatExemptSalesCentavos,
      required this.nonVatSalesCentavos,
      required this.sellerName,
      required this.sellerTin,
      required this.sellerAddress,
      required this.sellerRegistrationType,
      required this.branchCode,
      required this.machineIdentificationNumber,
      required this.permitToUseNumber,
      required this.machineSerialNumber,
      required this.softwareName,
      required this.softwareVersion,
      this.buyerName,
      this.buyerTin,
      this.buyerAddress,
      this.voidedAt,
      this.voidReason,
      this.originalInvoiceId,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['branch_id'] = Variable<String>(branchId);
    map['terminal_id'] = Variable<String>(terminalId);
    map['issued_at'] = Variable<DateTime>(issuedAt);
    map['status'] = Variable<String>(status);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_reference'] = Variable<String>(paymentReference);
    map['total_centavos'] = Variable<int>(totalCentavos);
    map['vatable_sales_centavos'] = Variable<int>(vatableSalesCentavos);
    map['vat_amount_centavos'] = Variable<int>(vatAmountCentavos);
    map['zero_rated_sales_centavos'] = Variable<int>(zeroRatedSalesCentavos);
    map['vat_exempt_sales_centavos'] = Variable<int>(vatExemptSalesCentavos);
    map['non_vat_sales_centavos'] = Variable<int>(nonVatSalesCentavos);
    map['seller_name'] = Variable<String>(sellerName);
    map['seller_tin'] = Variable<String>(sellerTin);
    map['seller_address'] = Variable<String>(sellerAddress);
    map['seller_registration_type'] = Variable<String>(sellerRegistrationType);
    map['branch_code'] = Variable<String>(branchCode);
    map['machine_identification_number'] =
        Variable<String>(machineIdentificationNumber);
    map['permit_to_use_number'] = Variable<String>(permitToUseNumber);
    map['machine_serial_number'] = Variable<String>(machineSerialNumber);
    map['software_name'] = Variable<String>(softwareName);
    map['software_version'] = Variable<String>(softwareVersion);
    if (!nullToAbsent || buyerName != null) {
      map['buyer_name'] = Variable<String>(buyerName);
    }
    if (!nullToAbsent || buyerTin != null) {
      map['buyer_tin'] = Variable<String>(buyerTin);
    }
    if (!nullToAbsent || buyerAddress != null) {
      map['buyer_address'] = Variable<String>(buyerAddress);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<DateTime>(voidedAt);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    if (!nullToAbsent || originalInvoiceId != null) {
      map['original_invoice_id'] = Variable<String>(originalInvoiceId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      branchId: Value(branchId),
      terminalId: Value(terminalId),
      issuedAt: Value(issuedAt),
      status: Value(status),
      paymentMethod: Value(paymentMethod),
      paymentReference: Value(paymentReference),
      totalCentavos: Value(totalCentavos),
      vatableSalesCentavos: Value(vatableSalesCentavos),
      vatAmountCentavos: Value(vatAmountCentavos),
      zeroRatedSalesCentavos: Value(zeroRatedSalesCentavos),
      vatExemptSalesCentavos: Value(vatExemptSalesCentavos),
      nonVatSalesCentavos: Value(nonVatSalesCentavos),
      sellerName: Value(sellerName),
      sellerTin: Value(sellerTin),
      sellerAddress: Value(sellerAddress),
      sellerRegistrationType: Value(sellerRegistrationType),
      branchCode: Value(branchCode),
      machineIdentificationNumber: Value(machineIdentificationNumber),
      permitToUseNumber: Value(permitToUseNumber),
      machineSerialNumber: Value(machineSerialNumber),
      softwareName: Value(softwareName),
      softwareVersion: Value(softwareVersion),
      buyerName: buyerName == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerName),
      buyerTin: buyerTin == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerTin),
      buyerAddress: buyerAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerAddress),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      originalInvoiceId: originalInvoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originalInvoiceId),
      synced: Value(synced),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      branchId: serializer.fromJson<String>(json['branchId']),
      terminalId: serializer.fromJson<String>(json['terminalId']),
      issuedAt: serializer.fromJson<DateTime>(json['issuedAt']),
      status: serializer.fromJson<String>(json['status']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentReference: serializer.fromJson<String>(json['paymentReference']),
      totalCentavos: serializer.fromJson<int>(json['totalCentavos']),
      vatableSalesCentavos:
          serializer.fromJson<int>(json['vatableSalesCentavos']),
      vatAmountCentavos: serializer.fromJson<int>(json['vatAmountCentavos']),
      zeroRatedSalesCentavos:
          serializer.fromJson<int>(json['zeroRatedSalesCentavos']),
      vatExemptSalesCentavos:
          serializer.fromJson<int>(json['vatExemptSalesCentavos']),
      nonVatSalesCentavos:
          serializer.fromJson<int>(json['nonVatSalesCentavos']),
      sellerName: serializer.fromJson<String>(json['sellerName']),
      sellerTin: serializer.fromJson<String>(json['sellerTin']),
      sellerAddress: serializer.fromJson<String>(json['sellerAddress']),
      sellerRegistrationType:
          serializer.fromJson<String>(json['sellerRegistrationType']),
      branchCode: serializer.fromJson<String>(json['branchCode']),
      machineIdentificationNumber:
          serializer.fromJson<String>(json['machineIdentificationNumber']),
      permitToUseNumber: serializer.fromJson<String>(json['permitToUseNumber']),
      machineSerialNumber:
          serializer.fromJson<String>(json['machineSerialNumber']),
      softwareName: serializer.fromJson<String>(json['softwareName']),
      softwareVersion: serializer.fromJson<String>(json['softwareVersion']),
      buyerName: serializer.fromJson<String?>(json['buyerName']),
      buyerTin: serializer.fromJson<String?>(json['buyerTin']),
      buyerAddress: serializer.fromJson<String?>(json['buyerAddress']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      originalInvoiceId:
          serializer.fromJson<String?>(json['originalInvoiceId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'branchId': serializer.toJson<String>(branchId),
      'terminalId': serializer.toJson<String>(terminalId),
      'issuedAt': serializer.toJson<DateTime>(issuedAt),
      'status': serializer.toJson<String>(status),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentReference': serializer.toJson<String>(paymentReference),
      'totalCentavos': serializer.toJson<int>(totalCentavos),
      'vatableSalesCentavos': serializer.toJson<int>(vatableSalesCentavos),
      'vatAmountCentavos': serializer.toJson<int>(vatAmountCentavos),
      'zeroRatedSalesCentavos': serializer.toJson<int>(zeroRatedSalesCentavos),
      'vatExemptSalesCentavos': serializer.toJson<int>(vatExemptSalesCentavos),
      'nonVatSalesCentavos': serializer.toJson<int>(nonVatSalesCentavos),
      'sellerName': serializer.toJson<String>(sellerName),
      'sellerTin': serializer.toJson<String>(sellerTin),
      'sellerAddress': serializer.toJson<String>(sellerAddress),
      'sellerRegistrationType':
          serializer.toJson<String>(sellerRegistrationType),
      'branchCode': serializer.toJson<String>(branchCode),
      'machineIdentificationNumber':
          serializer.toJson<String>(machineIdentificationNumber),
      'permitToUseNumber': serializer.toJson<String>(permitToUseNumber),
      'machineSerialNumber': serializer.toJson<String>(machineSerialNumber),
      'softwareName': serializer.toJson<String>(softwareName),
      'softwareVersion': serializer.toJson<String>(softwareVersion),
      'buyerName': serializer.toJson<String?>(buyerName),
      'buyerTin': serializer.toJson<String?>(buyerTin),
      'buyerAddress': serializer.toJson<String?>(buyerAddress),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
      'originalInvoiceId': serializer.toJson<String?>(originalInvoiceId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Invoice copyWith(
          {String? id,
          String? invoiceNumber,
          String? branchId,
          String? terminalId,
          DateTime? issuedAt,
          String? status,
          String? paymentMethod,
          String? paymentReference,
          int? totalCentavos,
          int? vatableSalesCentavos,
          int? vatAmountCentavos,
          int? zeroRatedSalesCentavos,
          int? vatExemptSalesCentavos,
          int? nonVatSalesCentavos,
          String? sellerName,
          String? sellerTin,
          String? sellerAddress,
          String? sellerRegistrationType,
          String? branchCode,
          String? machineIdentificationNumber,
          String? permitToUseNumber,
          String? machineSerialNumber,
          String? softwareName,
          String? softwareVersion,
          Value<String?> buyerName = const Value.absent(),
          Value<String?> buyerTin = const Value.absent(),
          Value<String?> buyerAddress = const Value.absent(),
          Value<DateTime?> voidedAt = const Value.absent(),
          Value<String?> voidReason = const Value.absent(),
          Value<String?> originalInvoiceId = const Value.absent(),
          bool? synced}) =>
      Invoice(
        id: id ?? this.id,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        branchId: branchId ?? this.branchId,
        terminalId: terminalId ?? this.terminalId,
        issuedAt: issuedAt ?? this.issuedAt,
        status: status ?? this.status,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentReference: paymentReference ?? this.paymentReference,
        totalCentavos: totalCentavos ?? this.totalCentavos,
        vatableSalesCentavos: vatableSalesCentavos ?? this.vatableSalesCentavos,
        vatAmountCentavos: vatAmountCentavos ?? this.vatAmountCentavos,
        zeroRatedSalesCentavos:
            zeroRatedSalesCentavos ?? this.zeroRatedSalesCentavos,
        vatExemptSalesCentavos:
            vatExemptSalesCentavos ?? this.vatExemptSalesCentavos,
        nonVatSalesCentavos: nonVatSalesCentavos ?? this.nonVatSalesCentavos,
        sellerName: sellerName ?? this.sellerName,
        sellerTin: sellerTin ?? this.sellerTin,
        sellerAddress: sellerAddress ?? this.sellerAddress,
        sellerRegistrationType:
            sellerRegistrationType ?? this.sellerRegistrationType,
        branchCode: branchCode ?? this.branchCode,
        machineIdentificationNumber:
            machineIdentificationNumber ?? this.machineIdentificationNumber,
        permitToUseNumber: permitToUseNumber ?? this.permitToUseNumber,
        machineSerialNumber: machineSerialNumber ?? this.machineSerialNumber,
        softwareName: softwareName ?? this.softwareName,
        softwareVersion: softwareVersion ?? this.softwareVersion,
        buyerName: buyerName.present ? buyerName.value : this.buyerName,
        buyerTin: buyerTin.present ? buyerTin.value : this.buyerTin,
        buyerAddress:
            buyerAddress.present ? buyerAddress.value : this.buyerAddress,
        voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
        voidReason: voidReason.present ? voidReason.value : this.voidReason,
        originalInvoiceId: originalInvoiceId.present
            ? originalInvoiceId.value
            : this.originalInvoiceId,
        synced: synced ?? this.synced,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      terminalId:
          data.terminalId.present ? data.terminalId.value : this.terminalId,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      status: data.status.present ? data.status.value : this.status,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentReference: data.paymentReference.present
          ? data.paymentReference.value
          : this.paymentReference,
      totalCentavos: data.totalCentavos.present
          ? data.totalCentavos.value
          : this.totalCentavos,
      vatableSalesCentavos: data.vatableSalesCentavos.present
          ? data.vatableSalesCentavos.value
          : this.vatableSalesCentavos,
      vatAmountCentavos: data.vatAmountCentavos.present
          ? data.vatAmountCentavos.value
          : this.vatAmountCentavos,
      zeroRatedSalesCentavos: data.zeroRatedSalesCentavos.present
          ? data.zeroRatedSalesCentavos.value
          : this.zeroRatedSalesCentavos,
      vatExemptSalesCentavos: data.vatExemptSalesCentavos.present
          ? data.vatExemptSalesCentavos.value
          : this.vatExemptSalesCentavos,
      nonVatSalesCentavos: data.nonVatSalesCentavos.present
          ? data.nonVatSalesCentavos.value
          : this.nonVatSalesCentavos,
      sellerName:
          data.sellerName.present ? data.sellerName.value : this.sellerName,
      sellerTin: data.sellerTin.present ? data.sellerTin.value : this.sellerTin,
      sellerAddress: data.sellerAddress.present
          ? data.sellerAddress.value
          : this.sellerAddress,
      sellerRegistrationType: data.sellerRegistrationType.present
          ? data.sellerRegistrationType.value
          : this.sellerRegistrationType,
      branchCode:
          data.branchCode.present ? data.branchCode.value : this.branchCode,
      machineIdentificationNumber: data.machineIdentificationNumber.present
          ? data.machineIdentificationNumber.value
          : this.machineIdentificationNumber,
      permitToUseNumber: data.permitToUseNumber.present
          ? data.permitToUseNumber.value
          : this.permitToUseNumber,
      machineSerialNumber: data.machineSerialNumber.present
          ? data.machineSerialNumber.value
          : this.machineSerialNumber,
      softwareName: data.softwareName.present
          ? data.softwareName.value
          : this.softwareName,
      softwareVersion: data.softwareVersion.present
          ? data.softwareVersion.value
          : this.softwareVersion,
      buyerName: data.buyerName.present ? data.buyerName.value : this.buyerName,
      buyerTin: data.buyerTin.present ? data.buyerTin.value : this.buyerTin,
      buyerAddress: data.buyerAddress.present
          ? data.buyerAddress.value
          : this.buyerAddress,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason:
          data.voidReason.present ? data.voidReason.value : this.voidReason,
      originalInvoiceId: data.originalInvoiceId.present
          ? data.originalInvoiceId.value
          : this.originalInvoiceId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('branchId: $branchId, ')
          ..write('terminalId: $terminalId, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('status: $status, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentReference: $paymentReference, ')
          ..write('totalCentavos: $totalCentavos, ')
          ..write('vatableSalesCentavos: $vatableSalesCentavos, ')
          ..write('vatAmountCentavos: $vatAmountCentavos, ')
          ..write('zeroRatedSalesCentavos: $zeroRatedSalesCentavos, ')
          ..write('vatExemptSalesCentavos: $vatExemptSalesCentavos, ')
          ..write('nonVatSalesCentavos: $nonVatSalesCentavos, ')
          ..write('sellerName: $sellerName, ')
          ..write('sellerTin: $sellerTin, ')
          ..write('sellerAddress: $sellerAddress, ')
          ..write('sellerRegistrationType: $sellerRegistrationType, ')
          ..write('branchCode: $branchCode, ')
          ..write('machineIdentificationNumber: $machineIdentificationNumber, ')
          ..write('permitToUseNumber: $permitToUseNumber, ')
          ..write('machineSerialNumber: $machineSerialNumber, ')
          ..write('softwareName: $softwareName, ')
          ..write('softwareVersion: $softwareVersion, ')
          ..write('buyerName: $buyerName, ')
          ..write('buyerTin: $buyerTin, ')
          ..write('buyerAddress: $buyerAddress, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('originalInvoiceId: $originalInvoiceId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        invoiceNumber,
        branchId,
        terminalId,
        issuedAt,
        status,
        paymentMethod,
        paymentReference,
        totalCentavos,
        vatableSalesCentavos,
        vatAmountCentavos,
        zeroRatedSalesCentavos,
        vatExemptSalesCentavos,
        nonVatSalesCentavos,
        sellerName,
        sellerTin,
        sellerAddress,
        sellerRegistrationType,
        branchCode,
        machineIdentificationNumber,
        permitToUseNumber,
        machineSerialNumber,
        softwareName,
        softwareVersion,
        buyerName,
        buyerTin,
        buyerAddress,
        voidedAt,
        voidReason,
        originalInvoiceId,
        synced
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.branchId == this.branchId &&
          other.terminalId == this.terminalId &&
          other.issuedAt == this.issuedAt &&
          other.status == this.status &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentReference == this.paymentReference &&
          other.totalCentavos == this.totalCentavos &&
          other.vatableSalesCentavos == this.vatableSalesCentavos &&
          other.vatAmountCentavos == this.vatAmountCentavos &&
          other.zeroRatedSalesCentavos == this.zeroRatedSalesCentavos &&
          other.vatExemptSalesCentavos == this.vatExemptSalesCentavos &&
          other.nonVatSalesCentavos == this.nonVatSalesCentavos &&
          other.sellerName == this.sellerName &&
          other.sellerTin == this.sellerTin &&
          other.sellerAddress == this.sellerAddress &&
          other.sellerRegistrationType == this.sellerRegistrationType &&
          other.branchCode == this.branchCode &&
          other.machineIdentificationNumber ==
              this.machineIdentificationNumber &&
          other.permitToUseNumber == this.permitToUseNumber &&
          other.machineSerialNumber == this.machineSerialNumber &&
          other.softwareName == this.softwareName &&
          other.softwareVersion == this.softwareVersion &&
          other.buyerName == this.buyerName &&
          other.buyerTin == this.buyerTin &&
          other.buyerAddress == this.buyerAddress &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason &&
          other.originalInvoiceId == this.originalInvoiceId &&
          other.synced == this.synced);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> invoiceNumber;
  final Value<String> branchId;
  final Value<String> terminalId;
  final Value<DateTime> issuedAt;
  final Value<String> status;
  final Value<String> paymentMethod;
  final Value<String> paymentReference;
  final Value<int> totalCentavos;
  final Value<int> vatableSalesCentavos;
  final Value<int> vatAmountCentavos;
  final Value<int> zeroRatedSalesCentavos;
  final Value<int> vatExemptSalesCentavos;
  final Value<int> nonVatSalesCentavos;
  final Value<String> sellerName;
  final Value<String> sellerTin;
  final Value<String> sellerAddress;
  final Value<String> sellerRegistrationType;
  final Value<String> branchCode;
  final Value<String> machineIdentificationNumber;
  final Value<String> permitToUseNumber;
  final Value<String> machineSerialNumber;
  final Value<String> softwareName;
  final Value<String> softwareVersion;
  final Value<String?> buyerName;
  final Value<String?> buyerTin;
  final Value<String?> buyerAddress;
  final Value<DateTime?> voidedAt;
  final Value<String?> voidReason;
  final Value<String?> originalInvoiceId;
  final Value<bool> synced;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.branchId = const Value.absent(),
    this.terminalId = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentReference = const Value.absent(),
    this.totalCentavos = const Value.absent(),
    this.vatableSalesCentavos = const Value.absent(),
    this.vatAmountCentavos = const Value.absent(),
    this.zeroRatedSalesCentavos = const Value.absent(),
    this.vatExemptSalesCentavos = const Value.absent(),
    this.nonVatSalesCentavos = const Value.absent(),
    this.sellerName = const Value.absent(),
    this.sellerTin = const Value.absent(),
    this.sellerAddress = const Value.absent(),
    this.sellerRegistrationType = const Value.absent(),
    this.branchCode = const Value.absent(),
    this.machineIdentificationNumber = const Value.absent(),
    this.permitToUseNumber = const Value.absent(),
    this.machineSerialNumber = const Value.absent(),
    this.softwareName = const Value.absent(),
    this.softwareVersion = const Value.absent(),
    this.buyerName = const Value.absent(),
    this.buyerTin = const Value.absent(),
    this.buyerAddress = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.originalInvoiceId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String invoiceNumber,
    required String branchId,
    required String terminalId,
    required DateTime issuedAt,
    required String status,
    required String paymentMethod,
    required String paymentReference,
    required int totalCentavos,
    required int vatableSalesCentavos,
    required int vatAmountCentavos,
    required int zeroRatedSalesCentavos,
    required int vatExemptSalesCentavos,
    required int nonVatSalesCentavos,
    required String sellerName,
    required String sellerTin,
    required String sellerAddress,
    required String sellerRegistrationType,
    required String branchCode,
    required String machineIdentificationNumber,
    required String permitToUseNumber,
    required String machineSerialNumber,
    required String softwareName,
    required String softwareVersion,
    this.buyerName = const Value.absent(),
    this.buyerTin = const Value.absent(),
    this.buyerAddress = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.originalInvoiceId = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceNumber = Value(invoiceNumber),
        branchId = Value(branchId),
        terminalId = Value(terminalId),
        issuedAt = Value(issuedAt),
        status = Value(status),
        paymentMethod = Value(paymentMethod),
        paymentReference = Value(paymentReference),
        totalCentavos = Value(totalCentavos),
        vatableSalesCentavos = Value(vatableSalesCentavos),
        vatAmountCentavos = Value(vatAmountCentavos),
        zeroRatedSalesCentavos = Value(zeroRatedSalesCentavos),
        vatExemptSalesCentavos = Value(vatExemptSalesCentavos),
        nonVatSalesCentavos = Value(nonVatSalesCentavos),
        sellerName = Value(sellerName),
        sellerTin = Value(sellerTin),
        sellerAddress = Value(sellerAddress),
        sellerRegistrationType = Value(sellerRegistrationType),
        branchCode = Value(branchCode),
        machineIdentificationNumber = Value(machineIdentificationNumber),
        permitToUseNumber = Value(permitToUseNumber),
        machineSerialNumber = Value(machineSerialNumber),
        softwareName = Value(softwareName),
        softwareVersion = Value(softwareVersion);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? branchId,
    Expression<String>? terminalId,
    Expression<DateTime>? issuedAt,
    Expression<String>? status,
    Expression<String>? paymentMethod,
    Expression<String>? paymentReference,
    Expression<int>? totalCentavos,
    Expression<int>? vatableSalesCentavos,
    Expression<int>? vatAmountCentavos,
    Expression<int>? zeroRatedSalesCentavos,
    Expression<int>? vatExemptSalesCentavos,
    Expression<int>? nonVatSalesCentavos,
    Expression<String>? sellerName,
    Expression<String>? sellerTin,
    Expression<String>? sellerAddress,
    Expression<String>? sellerRegistrationType,
    Expression<String>? branchCode,
    Expression<String>? machineIdentificationNumber,
    Expression<String>? permitToUseNumber,
    Expression<String>? machineSerialNumber,
    Expression<String>? softwareName,
    Expression<String>? softwareVersion,
    Expression<String>? buyerName,
    Expression<String>? buyerTin,
    Expression<String>? buyerAddress,
    Expression<DateTime>? voidedAt,
    Expression<String>? voidReason,
    Expression<String>? originalInvoiceId,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (branchId != null) 'branch_id': branchId,
      if (terminalId != null) 'terminal_id': terminalId,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (status != null) 'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentReference != null) 'payment_reference': paymentReference,
      if (totalCentavos != null) 'total_centavos': totalCentavos,
      if (vatableSalesCentavos != null)
        'vatable_sales_centavos': vatableSalesCentavos,
      if (vatAmountCentavos != null) 'vat_amount_centavos': vatAmountCentavos,
      if (zeroRatedSalesCentavos != null)
        'zero_rated_sales_centavos': zeroRatedSalesCentavos,
      if (vatExemptSalesCentavos != null)
        'vat_exempt_sales_centavos': vatExemptSalesCentavos,
      if (nonVatSalesCentavos != null)
        'non_vat_sales_centavos': nonVatSalesCentavos,
      if (sellerName != null) 'seller_name': sellerName,
      if (sellerTin != null) 'seller_tin': sellerTin,
      if (sellerAddress != null) 'seller_address': sellerAddress,
      if (sellerRegistrationType != null)
        'seller_registration_type': sellerRegistrationType,
      if (branchCode != null) 'branch_code': branchCode,
      if (machineIdentificationNumber != null)
        'machine_identification_number': machineIdentificationNumber,
      if (permitToUseNumber != null) 'permit_to_use_number': permitToUseNumber,
      if (machineSerialNumber != null)
        'machine_serial_number': machineSerialNumber,
      if (softwareName != null) 'software_name': softwareName,
      if (softwareVersion != null) 'software_version': softwareVersion,
      if (buyerName != null) 'buyer_name': buyerName,
      if (buyerTin != null) 'buyer_tin': buyerTin,
      if (buyerAddress != null) 'buyer_address': buyerAddress,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (originalInvoiceId != null) 'original_invoice_id': originalInvoiceId,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceNumber,
      Value<String>? branchId,
      Value<String>? terminalId,
      Value<DateTime>? issuedAt,
      Value<String>? status,
      Value<String>? paymentMethod,
      Value<String>? paymentReference,
      Value<int>? totalCentavos,
      Value<int>? vatableSalesCentavos,
      Value<int>? vatAmountCentavos,
      Value<int>? zeroRatedSalesCentavos,
      Value<int>? vatExemptSalesCentavos,
      Value<int>? nonVatSalesCentavos,
      Value<String>? sellerName,
      Value<String>? sellerTin,
      Value<String>? sellerAddress,
      Value<String>? sellerRegistrationType,
      Value<String>? branchCode,
      Value<String>? machineIdentificationNumber,
      Value<String>? permitToUseNumber,
      Value<String>? machineSerialNumber,
      Value<String>? softwareName,
      Value<String>? softwareVersion,
      Value<String?>? buyerName,
      Value<String?>? buyerTin,
      Value<String?>? buyerAddress,
      Value<DateTime?>? voidedAt,
      Value<String?>? voidReason,
      Value<String?>? originalInvoiceId,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      branchId: branchId ?? this.branchId,
      terminalId: terminalId ?? this.terminalId,
      issuedAt: issuedAt ?? this.issuedAt,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      totalCentavos: totalCentavos ?? this.totalCentavos,
      vatableSalesCentavos: vatableSalesCentavos ?? this.vatableSalesCentavos,
      vatAmountCentavos: vatAmountCentavos ?? this.vatAmountCentavos,
      zeroRatedSalesCentavos:
          zeroRatedSalesCentavos ?? this.zeroRatedSalesCentavos,
      vatExemptSalesCentavos:
          vatExemptSalesCentavos ?? this.vatExemptSalesCentavos,
      nonVatSalesCentavos: nonVatSalesCentavos ?? this.nonVatSalesCentavos,
      sellerName: sellerName ?? this.sellerName,
      sellerTin: sellerTin ?? this.sellerTin,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      sellerRegistrationType:
          sellerRegistrationType ?? this.sellerRegistrationType,
      branchCode: branchCode ?? this.branchCode,
      machineIdentificationNumber:
          machineIdentificationNumber ?? this.machineIdentificationNumber,
      permitToUseNumber: permitToUseNumber ?? this.permitToUseNumber,
      machineSerialNumber: machineSerialNumber ?? this.machineSerialNumber,
      softwareName: softwareName ?? this.softwareName,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      buyerName: buyerName ?? this.buyerName,
      buyerTin: buyerTin ?? this.buyerTin,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      originalInvoiceId: originalInvoiceId ?? this.originalInvoiceId,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (terminalId.present) {
      map['terminal_id'] = Variable<String>(terminalId.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentReference.present) {
      map['payment_reference'] = Variable<String>(paymentReference.value);
    }
    if (totalCentavos.present) {
      map['total_centavos'] = Variable<int>(totalCentavos.value);
    }
    if (vatableSalesCentavos.present) {
      map['vatable_sales_centavos'] = Variable<int>(vatableSalesCentavos.value);
    }
    if (vatAmountCentavos.present) {
      map['vat_amount_centavos'] = Variable<int>(vatAmountCentavos.value);
    }
    if (zeroRatedSalesCentavos.present) {
      map['zero_rated_sales_centavos'] =
          Variable<int>(zeroRatedSalesCentavos.value);
    }
    if (vatExemptSalesCentavos.present) {
      map['vat_exempt_sales_centavos'] =
          Variable<int>(vatExemptSalesCentavos.value);
    }
    if (nonVatSalesCentavos.present) {
      map['non_vat_sales_centavos'] = Variable<int>(nonVatSalesCentavos.value);
    }
    if (sellerName.present) {
      map['seller_name'] = Variable<String>(sellerName.value);
    }
    if (sellerTin.present) {
      map['seller_tin'] = Variable<String>(sellerTin.value);
    }
    if (sellerAddress.present) {
      map['seller_address'] = Variable<String>(sellerAddress.value);
    }
    if (sellerRegistrationType.present) {
      map['seller_registration_type'] =
          Variable<String>(sellerRegistrationType.value);
    }
    if (branchCode.present) {
      map['branch_code'] = Variable<String>(branchCode.value);
    }
    if (machineIdentificationNumber.present) {
      map['machine_identification_number'] =
          Variable<String>(machineIdentificationNumber.value);
    }
    if (permitToUseNumber.present) {
      map['permit_to_use_number'] = Variable<String>(permitToUseNumber.value);
    }
    if (machineSerialNumber.present) {
      map['machine_serial_number'] =
          Variable<String>(machineSerialNumber.value);
    }
    if (softwareName.present) {
      map['software_name'] = Variable<String>(softwareName.value);
    }
    if (softwareVersion.present) {
      map['software_version'] = Variable<String>(softwareVersion.value);
    }
    if (buyerName.present) {
      map['buyer_name'] = Variable<String>(buyerName.value);
    }
    if (buyerTin.present) {
      map['buyer_tin'] = Variable<String>(buyerTin.value);
    }
    if (buyerAddress.present) {
      map['buyer_address'] = Variable<String>(buyerAddress.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (originalInvoiceId.present) {
      map['original_invoice_id'] = Variable<String>(originalInvoiceId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('branchId: $branchId, ')
          ..write('terminalId: $terminalId, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('status: $status, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentReference: $paymentReference, ')
          ..write('totalCentavos: $totalCentavos, ')
          ..write('vatableSalesCentavos: $vatableSalesCentavos, ')
          ..write('vatAmountCentavos: $vatAmountCentavos, ')
          ..write('zeroRatedSalesCentavos: $zeroRatedSalesCentavos, ')
          ..write('vatExemptSalesCentavos: $vatExemptSalesCentavos, ')
          ..write('nonVatSalesCentavos: $nonVatSalesCentavos, ')
          ..write('sellerName: $sellerName, ')
          ..write('sellerTin: $sellerTin, ')
          ..write('sellerAddress: $sellerAddress, ')
          ..write('sellerRegistrationType: $sellerRegistrationType, ')
          ..write('branchCode: $branchCode, ')
          ..write('machineIdentificationNumber: $machineIdentificationNumber, ')
          ..write('permitToUseNumber: $permitToUseNumber, ')
          ..write('machineSerialNumber: $machineSerialNumber, ')
          ..write('softwareName: $softwareName, ')
          ..write('softwareVersion: $softwareVersion, ')
          ..write('buyerName: $buyerName, ')
          ..write('buyerTin: $buyerTin, ')
          ..write('buyerAddress: $buyerAddress, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('originalInvoiceId: $originalInvoiceId, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceLinesTable extends InvoiceLines
    with TableInfo<$InvoiceLinesTable, InvoiceLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES invoices (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceCentavosMeta =
      const VerificationMeta('unitPriceCentavos');
  @override
  late final GeneratedColumn<int> unitPriceCentavos = GeneratedColumn<int>(
      'unit_price_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _discountCentavosMeta =
      const VerificationMeta('discountCentavos');
  @override
  late final GeneratedColumn<int> discountCentavos = GeneratedColumn<int>(
      'discount_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _taxCategoryMeta =
      const VerificationMeta('taxCategory');
  @override
  late final GeneratedColumn<String> taxCategory = GeneratedColumn<String>(
      'tax_category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lineTotalCentavosMeta =
      const VerificationMeta('lineTotalCentavos');
  @override
  late final GeneratedColumn<int> lineTotalCentavos = GeneratedColumn<int>(
      'line_total_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        productId,
        description,
        quantity,
        unitPriceCentavos,
        discountCentavos,
        taxCategory,
        lineTotalCentavos
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_lines';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_centavos')) {
      context.handle(
          _unitPriceCentavosMeta,
          unitPriceCentavos.isAcceptableOrUnknown(
              data['unit_price_centavos']!, _unitPriceCentavosMeta));
    } else if (isInserting) {
      context.missing(_unitPriceCentavosMeta);
    }
    if (data.containsKey('discount_centavos')) {
      context.handle(
          _discountCentavosMeta,
          discountCentavos.isAcceptableOrUnknown(
              data['discount_centavos']!, _discountCentavosMeta));
    } else if (isInserting) {
      context.missing(_discountCentavosMeta);
    }
    if (data.containsKey('tax_category')) {
      context.handle(
          _taxCategoryMeta,
          taxCategory.isAcceptableOrUnknown(
              data['tax_category']!, _taxCategoryMeta));
    } else if (isInserting) {
      context.missing(_taxCategoryMeta);
    }
    if (data.containsKey('line_total_centavos')) {
      context.handle(
          _lineTotalCentavosMeta,
          lineTotalCentavos.isAcceptableOrUnknown(
              data['line_total_centavos']!, _lineTotalCentavosMeta));
    } else if (isInserting) {
      context.missing(_lineTotalCentavosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPriceCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}unit_price_centavos'])!,
      discountCentavos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discount_centavos'])!,
      taxCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tax_category'])!,
      lineTotalCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}line_total_centavos'])!,
    );
  }

  @override
  $InvoiceLinesTable createAlias(String alias) {
    return $InvoiceLinesTable(attachedDatabase, alias);
  }
}

class InvoiceLine extends DataClass implements Insertable<InvoiceLine> {
  final String id;
  final String invoiceId;
  final String productId;
  final String description;
  final int quantity;
  final int unitPriceCentavos;
  final int discountCentavos;
  final String taxCategory;
  final int lineTotalCentavos;
  const InvoiceLine(
      {required this.id,
      required this.invoiceId,
      required this.productId,
      required this.description,
      required this.quantity,
      required this.unitPriceCentavos,
      required this.discountCentavos,
      required this.taxCategory,
      required this.lineTotalCentavos});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['product_id'] = Variable<String>(productId);
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_centavos'] = Variable<int>(unitPriceCentavos);
    map['discount_centavos'] = Variable<int>(discountCentavos);
    map['tax_category'] = Variable<String>(taxCategory);
    map['line_total_centavos'] = Variable<int>(lineTotalCentavos);
    return map;
  }

  InvoiceLinesCompanion toCompanion(bool nullToAbsent) {
    return InvoiceLinesCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: Value(productId),
      description: Value(description),
      quantity: Value(quantity),
      unitPriceCentavos: Value(unitPriceCentavos),
      discountCentavos: Value(discountCentavos),
      taxCategory: Value(taxCategory),
      lineTotalCentavos: Value(lineTotalCentavos),
    );
  }

  factory InvoiceLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceLine(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      productId: serializer.fromJson<String>(json['productId']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceCentavos: serializer.fromJson<int>(json['unitPriceCentavos']),
      discountCentavos: serializer.fromJson<int>(json['discountCentavos']),
      taxCategory: serializer.fromJson<String>(json['taxCategory']),
      lineTotalCentavos: serializer.fromJson<int>(json['lineTotalCentavos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'productId': serializer.toJson<String>(productId),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceCentavos': serializer.toJson<int>(unitPriceCentavos),
      'discountCentavos': serializer.toJson<int>(discountCentavos),
      'taxCategory': serializer.toJson<String>(taxCategory),
      'lineTotalCentavos': serializer.toJson<int>(lineTotalCentavos),
    };
  }

  InvoiceLine copyWith(
          {String? id,
          String? invoiceId,
          String? productId,
          String? description,
          int? quantity,
          int? unitPriceCentavos,
          int? discountCentavos,
          String? taxCategory,
          int? lineTotalCentavos}) =>
      InvoiceLine(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        productId: productId ?? this.productId,
        description: description ?? this.description,
        quantity: quantity ?? this.quantity,
        unitPriceCentavos: unitPriceCentavos ?? this.unitPriceCentavos,
        discountCentavos: discountCentavos ?? this.discountCentavos,
        taxCategory: taxCategory ?? this.taxCategory,
        lineTotalCentavos: lineTotalCentavos ?? this.lineTotalCentavos,
      );
  InvoiceLine copyWithCompanion(InvoiceLinesCompanion data) {
    return InvoiceLine(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      description:
          data.description.present ? data.description.value : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceCentavos: data.unitPriceCentavos.present
          ? data.unitPriceCentavos.value
          : this.unitPriceCentavos,
      discountCentavos: data.discountCentavos.present
          ? data.discountCentavos.value
          : this.discountCentavos,
      taxCategory:
          data.taxCategory.present ? data.taxCategory.value : this.taxCategory,
      lineTotalCentavos: data.lineTotalCentavos.present
          ? data.lineTotalCentavos.value
          : this.lineTotalCentavos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLine(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCentavos: $unitPriceCentavos, ')
          ..write('discountCentavos: $discountCentavos, ')
          ..write('taxCategory: $taxCategory, ')
          ..write('lineTotalCentavos: $lineTotalCentavos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      invoiceId,
      productId,
      description,
      quantity,
      unitPriceCentavos,
      discountCentavos,
      taxCategory,
      lineTotalCentavos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceLine &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unitPriceCentavos == this.unitPriceCentavos &&
          other.discountCentavos == this.discountCentavos &&
          other.taxCategory == this.taxCategory &&
          other.lineTotalCentavos == this.lineTotalCentavos);
}

class InvoiceLinesCompanion extends UpdateCompanion<InvoiceLine> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> productId;
  final Value<String> description;
  final Value<int> quantity;
  final Value<int> unitPriceCentavos;
  final Value<int> discountCentavos;
  final Value<String> taxCategory;
  final Value<int> lineTotalCentavos;
  final Value<int> rowid;
  const InvoiceLinesCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceCentavos = const Value.absent(),
    this.discountCentavos = const Value.absent(),
    this.taxCategory = const Value.absent(),
    this.lineTotalCentavos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceLinesCompanion.insert({
    required String id,
    required String invoiceId,
    required String productId,
    required String description,
    required int quantity,
    required int unitPriceCentavos,
    required int discountCentavos,
    required String taxCategory,
    required int lineTotalCentavos,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        productId = Value(productId),
        description = Value(description),
        quantity = Value(quantity),
        unitPriceCentavos = Value(unitPriceCentavos),
        discountCentavos = Value(discountCentavos),
        taxCategory = Value(taxCategory),
        lineTotalCentavos = Value(lineTotalCentavos);
  static Insertable<InvoiceLine> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? productId,
    Expression<String>? description,
    Expression<int>? quantity,
    Expression<int>? unitPriceCentavos,
    Expression<int>? discountCentavos,
    Expression<String>? taxCategory,
    Expression<int>? lineTotalCentavos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceCentavos != null) 'unit_price_centavos': unitPriceCentavos,
      if (discountCentavos != null) 'discount_centavos': discountCentavos,
      if (taxCategory != null) 'tax_category': taxCategory,
      if (lineTotalCentavos != null) 'line_total_centavos': lineTotalCentavos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceLinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<String>? productId,
      Value<String>? description,
      Value<int>? quantity,
      Value<int>? unitPriceCentavos,
      Value<int>? discountCentavos,
      Value<String>? taxCategory,
      Value<int>? lineTotalCentavos,
      Value<int>? rowid}) {
    return InvoiceLinesCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPriceCentavos: unitPriceCentavos ?? this.unitPriceCentavos,
      discountCentavos: discountCentavos ?? this.discountCentavos,
      taxCategory: taxCategory ?? this.taxCategory,
      lineTotalCentavos: lineTotalCentavos ?? this.lineTotalCentavos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceCentavos.present) {
      map['unit_price_centavos'] = Variable<int>(unitPriceCentavos.value);
    }
    if (discountCentavos.present) {
      map['discount_centavos'] = Variable<int>(discountCentavos.value);
    }
    if (taxCategory.present) {
      map['tax_category'] = Variable<String>(taxCategory.value);
    }
    if (lineTotalCentavos.present) {
      map['line_total_centavos'] = Variable<int>(lineTotalCentavos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLinesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCentavos: $unitPriceCentavos, ')
          ..write('discountCentavos: $discountCentavos, ')
          ..write('taxCategory: $taxCategory, ')
          ..write('lineTotalCentavos: $lineTotalCentavos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'UNIQUE REFERENCES invoices (id)'));
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountCentavosMeta =
      const VerificationMeta('amountCentavos');
  @override
  late final GeneratedColumn<int> amountCentavos = GeneratedColumn<int>(
      'amount_centavos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorizedAtMeta =
      const VerificationMeta('authorizedAt');
  @override
  late final GeneratedColumn<DateTime> authorizedAt = GeneratedColumn<DateTime>(
      'authorized_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isOfflineMeta =
      const VerificationMeta('isOffline');
  @override
  late final GeneratedColumn<bool> isOffline = GeneratedColumn<bool>(
      'is_offline', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_offline" IN (0, 1))'));
  static const VerificationMeta _cashTenderedCentavosMeta =
      const VerificationMeta('cashTenderedCentavos');
  @override
  late final GeneratedColumn<int> cashTenderedCentavos = GeneratedColumn<int>(
      'cash_tendered_centavos', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _changeCentavosMeta =
      const VerificationMeta('changeCentavos');
  @override
  late final GeneratedColumn<int> changeCentavos = GeneratedColumn<int>(
      'change_centavos', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        provider,
        status,
        amountCentavos,
        reference,
        authorizedAt,
        isOffline,
        cashTenderedCentavos,
        changeCentavos
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('amount_centavos')) {
      context.handle(
          _amountCentavosMeta,
          amountCentavos.isAcceptableOrUnknown(
              data['amount_centavos']!, _amountCentavosMeta));
    } else if (isInserting) {
      context.missing(_amountCentavosMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('authorized_at')) {
      context.handle(
          _authorizedAtMeta,
          authorizedAt.isAcceptableOrUnknown(
              data['authorized_at']!, _authorizedAtMeta));
    } else if (isInserting) {
      context.missing(_authorizedAtMeta);
    }
    if (data.containsKey('is_offline')) {
      context.handle(_isOfflineMeta,
          isOffline.isAcceptableOrUnknown(data['is_offline']!, _isOfflineMeta));
    } else if (isInserting) {
      context.missing(_isOfflineMeta);
    }
    if (data.containsKey('cash_tendered_centavos')) {
      context.handle(
          _cashTenderedCentavosMeta,
          cashTenderedCentavos.isAcceptableOrUnknown(
              data['cash_tendered_centavos']!, _cashTenderedCentavosMeta));
    }
    if (data.containsKey('change_centavos')) {
      context.handle(
          _changeCentavosMeta,
          changeCentavos.isAcceptableOrUnknown(
              data['change_centavos']!, _changeCentavosMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      amountCentavos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_centavos'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference'])!,
      authorizedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}authorized_at'])!,
      isOffline: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_offline'])!,
      cashTenderedCentavos: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}cash_tendered_centavos']),
      changeCentavos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}change_centavos']),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String invoiceId;
  final String provider;
  final String status;
  final int amountCentavos;
  final String reference;
  final DateTime authorizedAt;
  final bool isOffline;
  final int? cashTenderedCentavos;
  final int? changeCentavos;
  const Payment(
      {required this.id,
      required this.invoiceId,
      required this.provider,
      required this.status,
      required this.amountCentavos,
      required this.reference,
      required this.authorizedAt,
      required this.isOffline,
      this.cashTenderedCentavos,
      this.changeCentavos});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['provider'] = Variable<String>(provider);
    map['status'] = Variable<String>(status);
    map['amount_centavos'] = Variable<int>(amountCentavos);
    map['reference'] = Variable<String>(reference);
    map['authorized_at'] = Variable<DateTime>(authorizedAt);
    map['is_offline'] = Variable<bool>(isOffline);
    if (!nullToAbsent || cashTenderedCentavos != null) {
      map['cash_tendered_centavos'] = Variable<int>(cashTenderedCentavos);
    }
    if (!nullToAbsent || changeCentavos != null) {
      map['change_centavos'] = Variable<int>(changeCentavos);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      provider: Value(provider),
      status: Value(status),
      amountCentavos: Value(amountCentavos),
      reference: Value(reference),
      authorizedAt: Value(authorizedAt),
      isOffline: Value(isOffline),
      cashTenderedCentavos: cashTenderedCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(cashTenderedCentavos),
      changeCentavos: changeCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(changeCentavos),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      provider: serializer.fromJson<String>(json['provider']),
      status: serializer.fromJson<String>(json['status']),
      amountCentavos: serializer.fromJson<int>(json['amountCentavos']),
      reference: serializer.fromJson<String>(json['reference']),
      authorizedAt: serializer.fromJson<DateTime>(json['authorizedAt']),
      isOffline: serializer.fromJson<bool>(json['isOffline']),
      cashTenderedCentavos:
          serializer.fromJson<int?>(json['cashTenderedCentavos']),
      changeCentavos: serializer.fromJson<int?>(json['changeCentavos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'provider': serializer.toJson<String>(provider),
      'status': serializer.toJson<String>(status),
      'amountCentavos': serializer.toJson<int>(amountCentavos),
      'reference': serializer.toJson<String>(reference),
      'authorizedAt': serializer.toJson<DateTime>(authorizedAt),
      'isOffline': serializer.toJson<bool>(isOffline),
      'cashTenderedCentavos': serializer.toJson<int?>(cashTenderedCentavos),
      'changeCentavos': serializer.toJson<int?>(changeCentavos),
    };
  }

  Payment copyWith(
          {String? id,
          String? invoiceId,
          String? provider,
          String? status,
          int? amountCentavos,
          String? reference,
          DateTime? authorizedAt,
          bool? isOffline,
          Value<int?> cashTenderedCentavos = const Value.absent(),
          Value<int?> changeCentavos = const Value.absent()}) =>
      Payment(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        provider: provider ?? this.provider,
        status: status ?? this.status,
        amountCentavos: amountCentavos ?? this.amountCentavos,
        reference: reference ?? this.reference,
        authorizedAt: authorizedAt ?? this.authorizedAt,
        isOffline: isOffline ?? this.isOffline,
        cashTenderedCentavos: cashTenderedCentavos.present
            ? cashTenderedCentavos.value
            : this.cashTenderedCentavos,
        changeCentavos:
            changeCentavos.present ? changeCentavos.value : this.changeCentavos,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      provider: data.provider.present ? data.provider.value : this.provider,
      status: data.status.present ? data.status.value : this.status,
      amountCentavos: data.amountCentavos.present
          ? data.amountCentavos.value
          : this.amountCentavos,
      reference: data.reference.present ? data.reference.value : this.reference,
      authorizedAt: data.authorizedAt.present
          ? data.authorizedAt.value
          : this.authorizedAt,
      isOffline: data.isOffline.present ? data.isOffline.value : this.isOffline,
      cashTenderedCentavos: data.cashTenderedCentavos.present
          ? data.cashTenderedCentavos.value
          : this.cashTenderedCentavos,
      changeCentavos: data.changeCentavos.present
          ? data.changeCentavos.value
          : this.changeCentavos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('provider: $provider, ')
          ..write('status: $status, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('reference: $reference, ')
          ..write('authorizedAt: $authorizedAt, ')
          ..write('isOffline: $isOffline, ')
          ..write('cashTenderedCentavos: $cashTenderedCentavos, ')
          ..write('changeCentavos: $changeCentavos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      invoiceId,
      provider,
      status,
      amountCentavos,
      reference,
      authorizedAt,
      isOffline,
      cashTenderedCentavos,
      changeCentavos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.provider == this.provider &&
          other.status == this.status &&
          other.amountCentavos == this.amountCentavos &&
          other.reference == this.reference &&
          other.authorizedAt == this.authorizedAt &&
          other.isOffline == this.isOffline &&
          other.cashTenderedCentavos == this.cashTenderedCentavos &&
          other.changeCentavos == this.changeCentavos);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> provider;
  final Value<String> status;
  final Value<int> amountCentavos;
  final Value<String> reference;
  final Value<DateTime> authorizedAt;
  final Value<bool> isOffline;
  final Value<int?> cashTenderedCentavos;
  final Value<int?> changeCentavos;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.provider = const Value.absent(),
    this.status = const Value.absent(),
    this.amountCentavos = const Value.absent(),
    this.reference = const Value.absent(),
    this.authorizedAt = const Value.absent(),
    this.isOffline = const Value.absent(),
    this.cashTenderedCentavos = const Value.absent(),
    this.changeCentavos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String invoiceId,
    required String provider,
    required String status,
    required int amountCentavos,
    required String reference,
    required DateTime authorizedAt,
    required bool isOffline,
    this.cashTenderedCentavos = const Value.absent(),
    this.changeCentavos = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        provider = Value(provider),
        status = Value(status),
        amountCentavos = Value(amountCentavos),
        reference = Value(reference),
        authorizedAt = Value(authorizedAt),
        isOffline = Value(isOffline);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? provider,
    Expression<String>? status,
    Expression<int>? amountCentavos,
    Expression<String>? reference,
    Expression<DateTime>? authorizedAt,
    Expression<bool>? isOffline,
    Expression<int>? cashTenderedCentavos,
    Expression<int>? changeCentavos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (provider != null) 'provider': provider,
      if (status != null) 'status': status,
      if (amountCentavos != null) 'amount_centavos': amountCentavos,
      if (reference != null) 'reference': reference,
      if (authorizedAt != null) 'authorized_at': authorizedAt,
      if (isOffline != null) 'is_offline': isOffline,
      if (cashTenderedCentavos != null)
        'cash_tendered_centavos': cashTenderedCentavos,
      if (changeCentavos != null) 'change_centavos': changeCentavos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<String>? provider,
      Value<String>? status,
      Value<int>? amountCentavos,
      Value<String>? reference,
      Value<DateTime>? authorizedAt,
      Value<bool>? isOffline,
      Value<int?>? cashTenderedCentavos,
      Value<int?>? changeCentavos,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      amountCentavos: amountCentavos ?? this.amountCentavos,
      reference: reference ?? this.reference,
      authorizedAt: authorizedAt ?? this.authorizedAt,
      isOffline: isOffline ?? this.isOffline,
      cashTenderedCentavos: cashTenderedCentavos ?? this.cashTenderedCentavos,
      changeCentavos: changeCentavos ?? this.changeCentavos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (amountCentavos.present) {
      map['amount_centavos'] = Variable<int>(amountCentavos.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (authorizedAt.present) {
      map['authorized_at'] = Variable<DateTime>(authorizedAt.value);
    }
    if (isOffline.present) {
      map['is_offline'] = Variable<bool>(isOffline.value);
    }
    if (cashTenderedCentavos.present) {
      map['cash_tendered_centavos'] = Variable<int>(cashTenderedCentavos.value);
    }
    if (changeCentavos.present) {
      map['change_centavos'] = Variable<int>(changeCentavos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('provider: $provider, ')
          ..write('status: $status, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('reference: $reference, ')
          ..write('authorizedAt: $authorizedAt, ')
          ..write('isOffline: $isOffline, ')
          ..write('cashTenderedCentavos: $cashTenderedCentavos, ')
          ..write('changeCentavos: $changeCentavos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryMovementsTable extends InventoryMovements
    with TableInfo<$InventoryMovementsTable, InventoryMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityDeltaMeta =
      const VerificationMeta('quantityDelta');
  @override
  late final GeneratedColumn<int> quantityDelta = GeneratedColumn<int>(
      'quantity_delta', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _balanceAfterMeta =
      const VerificationMeta('balanceAfter');
  @override
  late final GeneratedColumn<int> balanceAfter = GeneratedColumn<int>(
      'balance_after', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _referenceTypeMeta =
      const VerificationMeta('referenceType');
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
      'reference_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        branchId,
        productId,
        type,
        quantityDelta,
        balanceAfter,
        referenceType,
        referenceId,
        occurredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_movements';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity_delta')) {
      context.handle(
          _quantityDeltaMeta,
          quantityDelta.isAcceptableOrUnknown(
              data['quantity_delta']!, _quantityDeltaMeta));
    } else if (isInserting) {
      context.missing(_quantityDeltaMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
          _balanceAfterMeta,
          balanceAfter.isAcceptableOrUnknown(
              data['balance_after']!, _balanceAfterMeta));
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('reference_type')) {
      context.handle(
          _referenceTypeMeta,
          referenceType.isAcceptableOrUnknown(
              data['reference_type']!, _referenceTypeMeta));
    } else if (isInserting) {
      context.missing(_referenceTypeMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    } else if (isInserting) {
      context.missing(_referenceIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantityDelta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_delta'])!,
      balanceAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balance_after'])!,
      referenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_type'])!,
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $InventoryMovementsTable createAlias(String alias) {
    return $InventoryMovementsTable(attachedDatabase, alias);
  }
}

class InventoryMovement extends DataClass
    implements Insertable<InventoryMovement> {
  final String id;
  final String branchId;
  final String productId;
  final String type;
  final int quantityDelta;
  final int balanceAfter;
  final String referenceType;
  final String referenceId;
  final DateTime occurredAt;
  const InventoryMovement(
      {required this.id,
      required this.branchId,
      required this.productId,
      required this.type,
      required this.quantityDelta,
      required this.balanceAfter,
      required this.referenceType,
      required this.referenceId,
      required this.occurredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['branch_id'] = Variable<String>(branchId);
    map['product_id'] = Variable<String>(productId);
    map['type'] = Variable<String>(type);
    map['quantity_delta'] = Variable<int>(quantityDelta);
    map['balance_after'] = Variable<int>(balanceAfter);
    map['reference_type'] = Variable<String>(referenceType);
    map['reference_id'] = Variable<String>(referenceId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  InventoryMovementsCompanion toCompanion(bool nullToAbsent) {
    return InventoryMovementsCompanion(
      id: Value(id),
      branchId: Value(branchId),
      productId: Value(productId),
      type: Value(type),
      quantityDelta: Value(quantityDelta),
      balanceAfter: Value(balanceAfter),
      referenceType: Value(referenceType),
      referenceId: Value(referenceId),
      occurredAt: Value(occurredAt),
    );
  }

  factory InventoryMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryMovement(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String>(json['branchId']),
      productId: serializer.fromJson<String>(json['productId']),
      type: serializer.fromJson<String>(json['type']),
      quantityDelta: serializer.fromJson<int>(json['quantityDelta']),
      balanceAfter: serializer.fromJson<int>(json['balanceAfter']),
      referenceType: serializer.fromJson<String>(json['referenceType']),
      referenceId: serializer.fromJson<String>(json['referenceId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String>(branchId),
      'productId': serializer.toJson<String>(productId),
      'type': serializer.toJson<String>(type),
      'quantityDelta': serializer.toJson<int>(quantityDelta),
      'balanceAfter': serializer.toJson<int>(balanceAfter),
      'referenceType': serializer.toJson<String>(referenceType),
      'referenceId': serializer.toJson<String>(referenceId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  InventoryMovement copyWith(
          {String? id,
          String? branchId,
          String? productId,
          String? type,
          int? quantityDelta,
          int? balanceAfter,
          String? referenceType,
          String? referenceId,
          DateTime? occurredAt}) =>
      InventoryMovement(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        productId: productId ?? this.productId,
        type: type ?? this.type,
        quantityDelta: quantityDelta ?? this.quantityDelta,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        referenceType: referenceType ?? this.referenceType,
        referenceId: referenceId ?? this.referenceId,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  InventoryMovement copyWithCompanion(InventoryMovementsCompanion data) {
    return InventoryMovement(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      productId: data.productId.present ? data.productId.value : this.productId,
      type: data.type.present ? data.type.value : this.type,
      quantityDelta: data.quantityDelta.present
          ? data.quantityDelta.value
          : this.quantityDelta,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovement(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantityDelta: $quantityDelta, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, branchId, productId, type, quantityDelta,
      balanceAfter, referenceType, referenceId, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryMovement &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.productId == this.productId &&
          other.type == this.type &&
          other.quantityDelta == this.quantityDelta &&
          other.balanceAfter == this.balanceAfter &&
          other.referenceType == this.referenceType &&
          other.referenceId == this.referenceId &&
          other.occurredAt == this.occurredAt);
}

class InventoryMovementsCompanion extends UpdateCompanion<InventoryMovement> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<String> productId;
  final Value<String> type;
  final Value<int> quantityDelta;
  final Value<int> balanceAfter;
  final Value<String> referenceType;
  final Value<String> referenceId;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const InventoryMovementsCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.productId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantityDelta = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryMovementsCompanion.insert({
    required String id,
    required String branchId,
    required String productId,
    required String type,
    required int quantityDelta,
    required int balanceAfter,
    required String referenceType,
    required String referenceId,
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        branchId = Value(branchId),
        productId = Value(productId),
        type = Value(type),
        quantityDelta = Value(quantityDelta),
        balanceAfter = Value(balanceAfter),
        referenceType = Value(referenceType),
        referenceId = Value(referenceId),
        occurredAt = Value(occurredAt);
  static Insertable<InventoryMovement> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? productId,
    Expression<String>? type,
    Expression<int>? quantityDelta,
    Expression<int>? balanceAfter,
    Expression<String>? referenceType,
    Expression<String>? referenceId,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (productId != null) 'product_id': productId,
      if (type != null) 'type': type,
      if (quantityDelta != null) 'quantity_delta': quantityDelta,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? branchId,
      Value<String>? productId,
      Value<String>? type,
      Value<int>? quantityDelta,
      Value<int>? balanceAfter,
      Value<String>? referenceType,
      Value<String>? referenceId,
      Value<DateTime>? occurredAt,
      Value<int>? rowid}) {
    return InventoryMovementsCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantityDelta: quantityDelta ?? this.quantityDelta,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantityDelta.present) {
      map['quantity_delta'] = Variable<int>(quantityDelta.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<int>(balanceAfter.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovementsCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantityDelta: $quantityDelta, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTransfersTable extends InventoryTransfers
    with TableInfo<$InventoryTransfersTable, InventoryTransfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _sourceBranchIdMeta =
      const VerificationMeta('sourceBranchId');
  @override
  late final GeneratedColumn<String> sourceBranchId = GeneratedColumn<String>(
      'source_branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _destinationBranchIdMeta =
      const VerificationMeta('destinationBranchId');
  @override
  late final GeneratedColumn<String> destinationBranchId =
      GeneratedColumn<String>('destination_branch_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints:
              GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dispatchedAtMeta =
      const VerificationMeta('dispatchedAt');
  @override
  late final GeneratedColumn<DateTime> dispatchedAt = GeneratedColumn<DateTime>(
      'dispatched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _receivedByMeta =
      const VerificationMeta('receivedBy');
  @override
  late final GeneratedColumn<String> receivedBy = GeneratedColumn<String>(
      'received_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receivedAtMeta =
      const VerificationMeta('receivedAt');
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
      'received_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cancelledByMeta =
      const VerificationMeta('cancelledBy');
  @override
  late final GeneratedColumn<String> cancelledBy = GeneratedColumn<String>(
      'cancelled_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cancelledAtMeta =
      const VerificationMeta('cancelledAt');
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
      'cancelled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cancellationReasonMeta =
      const VerificationMeta('cancellationReason');
  @override
  late final GeneratedColumn<String> cancellationReason =
      GeneratedColumn<String>('cancellation_reason', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        productId,
        sourceBranchId,
        destinationBranchId,
        quantity,
        status,
        createdBy,
        createdAt,
        dispatchedAt,
        receivedBy,
        receivedAt,
        cancelledBy,
        cancelledAt,
        cancellationReason,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_transfers';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryTransfer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('source_branch_id')) {
      context.handle(
          _sourceBranchIdMeta,
          sourceBranchId.isAcceptableOrUnknown(
              data['source_branch_id']!, _sourceBranchIdMeta));
    } else if (isInserting) {
      context.missing(_sourceBranchIdMeta);
    }
    if (data.containsKey('destination_branch_id')) {
      context.handle(
          _destinationBranchIdMeta,
          destinationBranchId.isAcceptableOrUnknown(
              data['destination_branch_id']!, _destinationBranchIdMeta));
    } else if (isInserting) {
      context.missing(_destinationBranchIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('dispatched_at')) {
      context.handle(
          _dispatchedAtMeta,
          dispatchedAt.isAcceptableOrUnknown(
              data['dispatched_at']!, _dispatchedAtMeta));
    } else if (isInserting) {
      context.missing(_dispatchedAtMeta);
    }
    if (data.containsKey('received_by')) {
      context.handle(
          _receivedByMeta,
          receivedBy.isAcceptableOrUnknown(
              data['received_by']!, _receivedByMeta));
    }
    if (data.containsKey('received_at')) {
      context.handle(
          _receivedAtMeta,
          receivedAt.isAcceptableOrUnknown(
              data['received_at']!, _receivedAtMeta));
    }
    if (data.containsKey('cancelled_by')) {
      context.handle(
          _cancelledByMeta,
          cancelledBy.isAcceptableOrUnknown(
              data['cancelled_by']!, _cancelledByMeta));
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
          _cancelledAtMeta,
          cancelledAt.isAcceptableOrUnknown(
              data['cancelled_at']!, _cancelledAtMeta));
    }
    if (data.containsKey('cancellation_reason')) {
      context.handle(
          _cancellationReasonMeta,
          cancellationReason.isAcceptableOrUnknown(
              data['cancellation_reason']!, _cancellationReasonMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryTransfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryTransfer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      sourceBranchId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_branch_id'])!,
      destinationBranchId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}destination_branch_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      dispatchedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}dispatched_at'])!,
      receivedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}received_by']),
      receivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}received_at']),
      cancelledBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cancelled_by']),
      cancelledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cancelled_at']),
      cancellationReason: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cancellation_reason']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $InventoryTransfersTable createAlias(String alias) {
    return $InventoryTransfersTable(attachedDatabase, alias);
  }
}

class InventoryTransfer extends DataClass
    implements Insertable<InventoryTransfer> {
  final String id;
  final String productId;
  final String sourceBranchId;
  final String destinationBranchId;
  final int quantity;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime dispatchedAt;
  final String? receivedBy;
  final DateTime? receivedAt;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final int version;
  const InventoryTransfer(
      {required this.id,
      required this.productId,
      required this.sourceBranchId,
      required this.destinationBranchId,
      required this.quantity,
      required this.status,
      required this.createdBy,
      required this.createdAt,
      required this.dispatchedAt,
      this.receivedBy,
      this.receivedAt,
      this.cancelledBy,
      this.cancelledAt,
      this.cancellationReason,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['source_branch_id'] = Variable<String>(sourceBranchId);
    map['destination_branch_id'] = Variable<String>(destinationBranchId);
    map['quantity'] = Variable<int>(quantity);
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['dispatched_at'] = Variable<DateTime>(dispatchedAt);
    if (!nullToAbsent || receivedBy != null) {
      map['received_by'] = Variable<String>(receivedBy);
    }
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    if (!nullToAbsent || cancelledBy != null) {
      map['cancelled_by'] = Variable<String>(cancelledBy);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || cancellationReason != null) {
      map['cancellation_reason'] = Variable<String>(cancellationReason);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  InventoryTransfersCompanion toCompanion(bool nullToAbsent) {
    return InventoryTransfersCompanion(
      id: Value(id),
      productId: Value(productId),
      sourceBranchId: Value(sourceBranchId),
      destinationBranchId: Value(destinationBranchId),
      quantity: Value(quantity),
      status: Value(status),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      dispatchedAt: Value(dispatchedAt),
      receivedBy: receivedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedBy),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      cancelledBy: cancelledBy == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledBy),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      cancellationReason: cancellationReason == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellationReason),
      version: Value(version),
    );
  }

  factory InventoryTransfer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryTransfer(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      sourceBranchId: serializer.fromJson<String>(json['sourceBranchId']),
      destinationBranchId:
          serializer.fromJson<String>(json['destinationBranchId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      dispatchedAt: serializer.fromJson<DateTime>(json['dispatchedAt']),
      receivedBy: serializer.fromJson<String?>(json['receivedBy']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
      cancelledBy: serializer.fromJson<String?>(json['cancelledBy']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      cancellationReason:
          serializer.fromJson<String?>(json['cancellationReason']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'sourceBranchId': serializer.toJson<String>(sourceBranchId),
      'destinationBranchId': serializer.toJson<String>(destinationBranchId),
      'quantity': serializer.toJson<int>(quantity),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'dispatchedAt': serializer.toJson<DateTime>(dispatchedAt),
      'receivedBy': serializer.toJson<String?>(receivedBy),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
      'cancelledBy': serializer.toJson<String?>(cancelledBy),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'cancellationReason': serializer.toJson<String?>(cancellationReason),
      'version': serializer.toJson<int>(version),
    };
  }

  InventoryTransfer copyWith(
          {String? id,
          String? productId,
          String? sourceBranchId,
          String? destinationBranchId,
          int? quantity,
          String? status,
          String? createdBy,
          DateTime? createdAt,
          DateTime? dispatchedAt,
          Value<String?> receivedBy = const Value.absent(),
          Value<DateTime?> receivedAt = const Value.absent(),
          Value<String?> cancelledBy = const Value.absent(),
          Value<DateTime?> cancelledAt = const Value.absent(),
          Value<String?> cancellationReason = const Value.absent(),
          int? version}) =>
      InventoryTransfer(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        sourceBranchId: sourceBranchId ?? this.sourceBranchId,
        destinationBranchId: destinationBranchId ?? this.destinationBranchId,
        quantity: quantity ?? this.quantity,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        dispatchedAt: dispatchedAt ?? this.dispatchedAt,
        receivedBy: receivedBy.present ? receivedBy.value : this.receivedBy,
        receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
        cancelledBy: cancelledBy.present ? cancelledBy.value : this.cancelledBy,
        cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
        cancellationReason: cancellationReason.present
            ? cancellationReason.value
            : this.cancellationReason,
        version: version ?? this.version,
      );
  InventoryTransfer copyWithCompanion(InventoryTransfersCompanion data) {
    return InventoryTransfer(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      sourceBranchId: data.sourceBranchId.present
          ? data.sourceBranchId.value
          : this.sourceBranchId,
      destinationBranchId: data.destinationBranchId.present
          ? data.destinationBranchId.value
          : this.destinationBranchId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dispatchedAt: data.dispatchedAt.present
          ? data.dispatchedAt.value
          : this.dispatchedAt,
      receivedBy:
          data.receivedBy.present ? data.receivedBy.value : this.receivedBy,
      receivedAt:
          data.receivedAt.present ? data.receivedAt.value : this.receivedAt,
      cancelledBy:
          data.cancelledBy.present ? data.cancelledBy.value : this.cancelledBy,
      cancelledAt:
          data.cancelledAt.present ? data.cancelledAt.value : this.cancelledAt,
      cancellationReason: data.cancellationReason.present
          ? data.cancellationReason.value
          : this.cancellationReason,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryTransfer(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('sourceBranchId: $sourceBranchId, ')
          ..write('destinationBranchId: $destinationBranchId, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('dispatchedAt: $dispatchedAt, ')
          ..write('receivedBy: $receivedBy, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('cancelledBy: $cancelledBy, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancellationReason: $cancellationReason, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      productId,
      sourceBranchId,
      destinationBranchId,
      quantity,
      status,
      createdBy,
      createdAt,
      dispatchedAt,
      receivedBy,
      receivedAt,
      cancelledBy,
      cancelledAt,
      cancellationReason,
      version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryTransfer &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.sourceBranchId == this.sourceBranchId &&
          other.destinationBranchId == this.destinationBranchId &&
          other.quantity == this.quantity &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.dispatchedAt == this.dispatchedAt &&
          other.receivedBy == this.receivedBy &&
          other.receivedAt == this.receivedAt &&
          other.cancelledBy == this.cancelledBy &&
          other.cancelledAt == this.cancelledAt &&
          other.cancellationReason == this.cancellationReason &&
          other.version == this.version);
}

class InventoryTransfersCompanion extends UpdateCompanion<InventoryTransfer> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> sourceBranchId;
  final Value<String> destinationBranchId;
  final Value<int> quantity;
  final Value<String> status;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> dispatchedAt;
  final Value<String?> receivedBy;
  final Value<DateTime?> receivedAt;
  final Value<String?> cancelledBy;
  final Value<DateTime?> cancelledAt;
  final Value<String?> cancellationReason;
  final Value<int> version;
  final Value<int> rowid;
  const InventoryTransfersCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.sourceBranchId = const Value.absent(),
    this.destinationBranchId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dispatchedAt = const Value.absent(),
    this.receivedBy = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.cancelledBy = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancellationReason = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryTransfersCompanion.insert({
    required String id,
    required String productId,
    required String sourceBranchId,
    required String destinationBranchId,
    required int quantity,
    required String status,
    required String createdBy,
    required DateTime createdAt,
    required DateTime dispatchedAt,
    this.receivedBy = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.cancelledBy = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancellationReason = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        sourceBranchId = Value(sourceBranchId),
        destinationBranchId = Value(destinationBranchId),
        quantity = Value(quantity),
        status = Value(status),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        dispatchedAt = Value(dispatchedAt);
  static Insertable<InventoryTransfer> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? sourceBranchId,
    Expression<String>? destinationBranchId,
    Expression<int>? quantity,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? dispatchedAt,
    Expression<String>? receivedBy,
    Expression<DateTime>? receivedAt,
    Expression<String>? cancelledBy,
    Expression<DateTime>? cancelledAt,
    Expression<String>? cancellationReason,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (sourceBranchId != null) 'source_branch_id': sourceBranchId,
      if (destinationBranchId != null)
        'destination_branch_id': destinationBranchId,
      if (quantity != null) 'quantity': quantity,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (dispatchedAt != null) 'dispatched_at': dispatchedAt,
      if (receivedBy != null) 'received_by': receivedBy,
      if (receivedAt != null) 'received_at': receivedAt,
      if (cancelledBy != null) 'cancelled_by': cancelledBy,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryTransfersCompanion copyWith(
      {Value<String>? id,
      Value<String>? productId,
      Value<String>? sourceBranchId,
      Value<String>? destinationBranchId,
      Value<int>? quantity,
      Value<String>? status,
      Value<String>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime>? dispatchedAt,
      Value<String?>? receivedBy,
      Value<DateTime?>? receivedAt,
      Value<String?>? cancelledBy,
      Value<DateTime?>? cancelledAt,
      Value<String?>? cancellationReason,
      Value<int>? version,
      Value<int>? rowid}) {
    return InventoryTransfersCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sourceBranchId: sourceBranchId ?? this.sourceBranchId,
      destinationBranchId: destinationBranchId ?? this.destinationBranchId,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      receivedBy: receivedBy ?? this.receivedBy,
      receivedAt: receivedAt ?? this.receivedAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (sourceBranchId.present) {
      map['source_branch_id'] = Variable<String>(sourceBranchId.value);
    }
    if (destinationBranchId.present) {
      map['destination_branch_id'] =
          Variable<String>(destinationBranchId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dispatchedAt.present) {
      map['dispatched_at'] = Variable<DateTime>(dispatchedAt.value);
    }
    if (receivedBy.present) {
      map['received_by'] = Variable<String>(receivedBy.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (cancelledBy.present) {
      map['cancelled_by'] = Variable<String>(cancelledBy.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (cancellationReason.present) {
      map['cancellation_reason'] = Variable<String>(cancellationReason.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryTransfersCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('sourceBranchId: $sourceBranchId, ')
          ..write('destinationBranchId: $destinationBranchId, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('dispatchedAt: $dispatchedAt, ')
          ..write('receivedBy: $receivedBy, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('cancelledBy: $cancelledBy, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancellationReason: $cancellationReason, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditEventsTable extends AuditEvents
    with TableInfo<$AuditEventsTable, AuditEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _sequenceMeta =
      const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
      'sequence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _previousHashMeta =
      const VerificationMeta('previousHash');
  @override
  late final GeneratedColumn<String> previousHash = GeneratedColumn<String>(
      'previous_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventHashMeta =
      const VerificationMeta('eventHash');
  @override
  late final GeneratedColumn<String> eventHash = GeneratedColumn<String>(
      'event_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _terminalIdMeta =
      const VerificationMeta('terminalId');
  @override
  late final GeneratedColumn<String> terminalId = GeneratedColumn<String>(
      'terminal_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actorIdMeta =
      const VerificationMeta('actorId');
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
      'actor_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        branchId,
        sequence,
        previousHash,
        eventHash,
        terminalId,
        actorId,
        eventType,
        entityType,
        entityId,
        payloadJson,
        occurredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_events';
  @override
  VerificationContext validateIntegrity(Insertable<AuditEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('previous_hash')) {
      context.handle(
          _previousHashMeta,
          previousHash.isAcceptableOrUnknown(
              data['previous_hash']!, _previousHashMeta));
    } else if (isInserting) {
      context.missing(_previousHashMeta);
    }
    if (data.containsKey('event_hash')) {
      context.handle(_eventHashMeta,
          eventHash.isAcceptableOrUnknown(data['event_hash']!, _eventHashMeta));
    } else if (isInserting) {
      context.missing(_eventHashMeta);
    }
    if (data.containsKey('terminal_id')) {
      context.handle(
          _terminalIdMeta,
          terminalId.isAcceptableOrUnknown(
              data['terminal_id']!, _terminalIdMeta));
    }
    if (data.containsKey('actor_id')) {
      context.handle(_actorIdMeta,
          actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta));
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {branchId, sequence},
      ];
  @override
  AuditEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      sequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
      previousHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}previous_hash'])!,
      eventHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_hash'])!,
      terminalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}terminal_id']),
      actorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actor_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $AuditEventsTable createAlias(String alias) {
    return $AuditEventsTable(attachedDatabase, alias);
  }
}

class AuditEvent extends DataClass implements Insertable<AuditEvent> {
  final String id;
  final String branchId;
  final int sequence;
  final String previousHash;
  final String eventHash;
  final String? terminalId;
  final String actorId;
  final String eventType;
  final String entityType;
  final String entityId;
  final String payloadJson;
  final DateTime occurredAt;
  const AuditEvent(
      {required this.id,
      required this.branchId,
      required this.sequence,
      required this.previousHash,
      required this.eventHash,
      this.terminalId,
      required this.actorId,
      required this.eventType,
      required this.entityType,
      required this.entityId,
      required this.payloadJson,
      required this.occurredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['branch_id'] = Variable<String>(branchId);
    map['sequence'] = Variable<int>(sequence);
    map['previous_hash'] = Variable<String>(previousHash);
    map['event_hash'] = Variable<String>(eventHash);
    if (!nullToAbsent || terminalId != null) {
      map['terminal_id'] = Variable<String>(terminalId);
    }
    map['actor_id'] = Variable<String>(actorId);
    map['event_type'] = Variable<String>(eventType);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  AuditEventsCompanion toCompanion(bool nullToAbsent) {
    return AuditEventsCompanion(
      id: Value(id),
      branchId: Value(branchId),
      sequence: Value(sequence),
      previousHash: Value(previousHash),
      eventHash: Value(eventHash),
      terminalId: terminalId == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalId),
      actorId: Value(actorId),
      eventType: Value(eventType),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payloadJson: Value(payloadJson),
      occurredAt: Value(occurredAt),
    );
  }

  factory AuditEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditEvent(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String>(json['branchId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      previousHash: serializer.fromJson<String>(json['previousHash']),
      eventHash: serializer.fromJson<String>(json['eventHash']),
      terminalId: serializer.fromJson<String?>(json['terminalId']),
      actorId: serializer.fromJson<String>(json['actorId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String>(branchId),
      'sequence': serializer.toJson<int>(sequence),
      'previousHash': serializer.toJson<String>(previousHash),
      'eventHash': serializer.toJson<String>(eventHash),
      'terminalId': serializer.toJson<String?>(terminalId),
      'actorId': serializer.toJson<String>(actorId),
      'eventType': serializer.toJson<String>(eventType),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  AuditEvent copyWith(
          {String? id,
          String? branchId,
          int? sequence,
          String? previousHash,
          String? eventHash,
          Value<String?> terminalId = const Value.absent(),
          String? actorId,
          String? eventType,
          String? entityType,
          String? entityId,
          String? payloadJson,
          DateTime? occurredAt}) =>
      AuditEvent(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        sequence: sequence ?? this.sequence,
        previousHash: previousHash ?? this.previousHash,
        eventHash: eventHash ?? this.eventHash,
        terminalId: terminalId.present ? terminalId.value : this.terminalId,
        actorId: actorId ?? this.actorId,
        eventType: eventType ?? this.eventType,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        payloadJson: payloadJson ?? this.payloadJson,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  AuditEvent copyWithCompanion(AuditEventsCompanion data) {
    return AuditEvent(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      previousHash: data.previousHash.present
          ? data.previousHash.value
          : this.previousHash,
      eventHash: data.eventHash.present ? data.eventHash.value : this.eventHash,
      terminalId:
          data.terminalId.present ? data.terminalId.value : this.terminalId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditEvent(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('sequence: $sequence, ')
          ..write('previousHash: $previousHash, ')
          ..write('eventHash: $eventHash, ')
          ..write('terminalId: $terminalId, ')
          ..write('actorId: $actorId, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      branchId,
      sequence,
      previousHash,
      eventHash,
      terminalId,
      actorId,
      eventType,
      entityType,
      entityId,
      payloadJson,
      occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditEvent &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.sequence == this.sequence &&
          other.previousHash == this.previousHash &&
          other.eventHash == this.eventHash &&
          other.terminalId == this.terminalId &&
          other.actorId == this.actorId &&
          other.eventType == this.eventType &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson &&
          other.occurredAt == this.occurredAt);
}

class AuditEventsCompanion extends UpdateCompanion<AuditEvent> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<int> sequence;
  final Value<String> previousHash;
  final Value<String> eventHash;
  final Value<String?> terminalId;
  final Value<String> actorId;
  final Value<String> eventType;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payloadJson;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const AuditEventsCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.previousHash = const Value.absent(),
    this.eventHash = const Value.absent(),
    this.terminalId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditEventsCompanion.insert({
    required String id,
    required String branchId,
    required int sequence,
    required String previousHash,
    required String eventHash,
    this.terminalId = const Value.absent(),
    required String actorId,
    required String eventType,
    required String entityType,
    required String entityId,
    required String payloadJson,
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        branchId = Value(branchId),
        sequence = Value(sequence),
        previousHash = Value(previousHash),
        eventHash = Value(eventHash),
        actorId = Value(actorId),
        eventType = Value(eventType),
        entityType = Value(entityType),
        entityId = Value(entityId),
        payloadJson = Value(payloadJson),
        occurredAt = Value(occurredAt);
  static Insertable<AuditEvent> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<int>? sequence,
    Expression<String>? previousHash,
    Expression<String>? eventHash,
    Expression<String>? terminalId,
    Expression<String>? actorId,
    Expression<String>? eventType,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (sequence != null) 'sequence': sequence,
      if (previousHash != null) 'previous_hash': previousHash,
      if (eventHash != null) 'event_hash': eventHash,
      if (terminalId != null) 'terminal_id': terminalId,
      if (actorId != null) 'actor_id': actorId,
      if (eventType != null) 'event_type': eventType,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? branchId,
      Value<int>? sequence,
      Value<String>? previousHash,
      Value<String>? eventHash,
      Value<String?>? terminalId,
      Value<String>? actorId,
      Value<String>? eventType,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? payloadJson,
      Value<DateTime>? occurredAt,
      Value<int>? rowid}) {
    return AuditEventsCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      sequence: sequence ?? this.sequence,
      previousHash: previousHash ?? this.previousHash,
      eventHash: eventHash ?? this.eventHash,
      terminalId: terminalId ?? this.terminalId,
      actorId: actorId ?? this.actorId,
      eventType: eventType ?? this.eventType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (previousHash.present) {
      map['previous_hash'] = Variable<String>(previousHash.value);
    }
    if (eventHash.present) {
      map['event_hash'] = Variable<String>(eventHash.value);
    }
    if (terminalId.present) {
      map['terminal_id'] = Variable<String>(terminalId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditEventsCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('sequence: $sequence, ')
          ..write('previousHash: $previousHash, ')
          ..write('eventHash: $eventHash, ')
          ..write('terminalId: $terminalId, ')
          ..write('actorId: $actorId, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxEventsTable extends SyncOutboxEvents
    with TableInfo<$SyncOutboxEventsTable, SyncOutboxEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _aggregateTypeMeta =
      const VerificationMeta('aggregateType');
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
      'aggregate_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aggregateIdMeta =
      const VerificationMeta('aggregateId');
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
      'aggregate_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _leaseIdMeta =
      const VerificationMeta('leaseId');
  @override
  late final GeneratedColumn<String> leaseId = GeneratedColumn<String>(
      'lease_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _leaseExpiresAtMeta =
      const VerificationMeta('leaseExpiresAt');
  @override
  late final GeneratedColumn<DateTime> leaseExpiresAt =
      GeneratedColumn<DateTime>('lease_expires_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serverEventIdMeta =
      const VerificationMeta('serverEventId');
  @override
  late final GeneratedColumn<String> serverEventId = GeneratedColumn<String>(
      'server_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        branchId,
        aggregateType,
        aggregateId,
        eventType,
        idempotencyKey,
        payloadJson,
        createdAt,
        attemptCount,
        nextAttemptAt,
        leaseId,
        leaseExpiresAt,
        lastError,
        serverEventId,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox_events';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOutboxEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
          _aggregateTypeMeta,
          aggregateType.isAcceptableOrUnknown(
              data['aggregate_type']!, _aggregateTypeMeta));
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
          _aggregateIdMeta,
          aggregateId.isAcceptableOrUnknown(
              data['aggregate_id']!, _aggregateIdMeta));
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    if (data.containsKey('lease_id')) {
      context.handle(_leaseIdMeta,
          leaseId.isAcceptableOrUnknown(data['lease_id']!, _leaseIdMeta));
    }
    if (data.containsKey('lease_expires_at')) {
      context.handle(
          _leaseExpiresAtMeta,
          leaseExpiresAt.isAcceptableOrUnknown(
              data['lease_expires_at']!, _leaseExpiresAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('server_event_id')) {
      context.handle(
          _serverEventIdMeta,
          serverEventId.isAcceptableOrUnknown(
              data['server_event_id']!, _serverEventIdMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      aggregateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aggregate_type'])!,
      aggregateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aggregate_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
      leaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lease_id']),
      leaseExpiresAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}lease_expires_at']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      serverEventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_event_id']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $SyncOutboxEventsTable createAlias(String alias) {
    return $SyncOutboxEventsTable(attachedDatabase, alias);
  }
}

class SyncOutboxEvent extends DataClass implements Insertable<SyncOutboxEvent> {
  final String id;
  final String branchId;
  final String aggregateType;
  final String aggregateId;
  final String eventType;
  final String idempotencyKey;
  final String payloadJson;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? leaseId;
  final DateTime? leaseExpiresAt;
  final String? lastError;
  final String? serverEventId;
  final DateTime? syncedAt;
  const SyncOutboxEvent(
      {required this.id,
      required this.branchId,
      required this.aggregateType,
      required this.aggregateId,
      required this.eventType,
      required this.idempotencyKey,
      required this.payloadJson,
      required this.createdAt,
      required this.attemptCount,
      this.nextAttemptAt,
      this.leaseId,
      this.leaseExpiresAt,
      this.lastError,
      this.serverEventId,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['branch_id'] = Variable<String>(branchId);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['event_type'] = Variable<String>(eventType);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || leaseId != null) {
      map['lease_id'] = Variable<String>(leaseId);
    }
    if (!nullToAbsent || leaseExpiresAt != null) {
      map['lease_expires_at'] = Variable<DateTime>(leaseExpiresAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || serverEventId != null) {
      map['server_event_id'] = Variable<String>(serverEventId);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SyncOutboxEventsCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxEventsCompanion(
      id: Value(id),
      branchId: Value(branchId),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      eventType: Value(eventType),
      idempotencyKey: Value(idempotencyKey),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      leaseId: leaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseId),
      leaseExpiresAt: leaseExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseExpiresAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      serverEventId: serverEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverEventId),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SyncOutboxEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxEvent(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String>(json['branchId']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      leaseId: serializer.fromJson<String?>(json['leaseId']),
      leaseExpiresAt: serializer.fromJson<DateTime?>(json['leaseExpiresAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      serverEventId: serializer.fromJson<String?>(json['serverEventId']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String>(branchId),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'eventType': serializer.toJson<String>(eventType),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'leaseId': serializer.toJson<String?>(leaseId),
      'leaseExpiresAt': serializer.toJson<DateTime?>(leaseExpiresAt),
      'lastError': serializer.toJson<String?>(lastError),
      'serverEventId': serializer.toJson<String?>(serverEventId),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SyncOutboxEvent copyWith(
          {String? id,
          String? branchId,
          String? aggregateType,
          String? aggregateId,
          String? eventType,
          String? idempotencyKey,
          String? payloadJson,
          DateTime? createdAt,
          int? attemptCount,
          Value<DateTime?> nextAttemptAt = const Value.absent(),
          Value<String?> leaseId = const Value.absent(),
          Value<DateTime?> leaseExpiresAt = const Value.absent(),
          Value<String?> lastError = const Value.absent(),
          Value<String?> serverEventId = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      SyncOutboxEvent(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        aggregateType: aggregateType ?? this.aggregateType,
        aggregateId: aggregateId ?? this.aggregateId,
        eventType: eventType ?? this.eventType,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        attemptCount: attemptCount ?? this.attemptCount,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
        leaseId: leaseId.present ? leaseId.value : this.leaseId,
        leaseExpiresAt:
            leaseExpiresAt.present ? leaseExpiresAt.value : this.leaseExpiresAt,
        lastError: lastError.present ? lastError.value : this.lastError,
        serverEventId:
            serverEventId.present ? serverEventId.value : this.serverEventId,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  SyncOutboxEvent copyWithCompanion(SyncOutboxEventsCompanion data) {
    return SyncOutboxEvent(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId:
          data.aggregateId.present ? data.aggregateId.value : this.aggregateId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      leaseId: data.leaseId.present ? data.leaseId.value : this.leaseId,
      leaseExpiresAt: data.leaseExpiresAt.present
          ? data.leaseExpiresAt.value
          : this.leaseExpiresAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      serverEventId: data.serverEventId.present
          ? data.serverEventId.value
          : this.serverEventId,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEvent(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('eventType: $eventType, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('leaseId: $leaseId, ')
          ..write('leaseExpiresAt: $leaseExpiresAt, ')
          ..write('lastError: $lastError, ')
          ..write('serverEventId: $serverEventId, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      branchId,
      aggregateType,
      aggregateId,
      eventType,
      idempotencyKey,
      payloadJson,
      createdAt,
      attemptCount,
      nextAttemptAt,
      leaseId,
      leaseExpiresAt,
      lastError,
      serverEventId,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxEvent &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.eventType == this.eventType &&
          other.idempotencyKey == this.idempotencyKey &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.leaseId == this.leaseId &&
          other.leaseExpiresAt == this.leaseExpiresAt &&
          other.lastError == this.lastError &&
          other.serverEventId == this.serverEventId &&
          other.syncedAt == this.syncedAt);
}

class SyncOutboxEventsCompanion extends UpdateCompanion<SyncOutboxEvent> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> eventType;
  final Value<String> idempotencyKey;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> leaseId;
  final Value<DateTime?> leaseExpiresAt;
  final Value<String?> lastError;
  final Value<String?> serverEventId;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const SyncOutboxEventsCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.leaseId = const Value.absent(),
    this.leaseExpiresAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.serverEventId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxEventsCompanion.insert({
    required String id,
    required String branchId,
    required String aggregateType,
    required String aggregateId,
    required String eventType,
    required String idempotencyKey,
    required String payloadJson,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.leaseId = const Value.absent(),
    this.leaseExpiresAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.serverEventId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        branchId = Value(branchId),
        aggregateType = Value(aggregateType),
        aggregateId = Value(aggregateId),
        eventType = Value(eventType),
        idempotencyKey = Value(idempotencyKey),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<SyncOutboxEvent> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? eventType,
    Expression<String>? idempotencyKey,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? leaseId,
    Expression<DateTime>? leaseExpiresAt,
    Expression<String>? lastError,
    Expression<String>? serverEventId,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (eventType != null) 'event_type': eventType,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (leaseId != null) 'lease_id': leaseId,
      if (leaseExpiresAt != null) 'lease_expires_at': leaseExpiresAt,
      if (lastError != null) 'last_error': lastError,
      if (serverEventId != null) 'server_event_id': serverEventId,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? branchId,
      Value<String>? aggregateType,
      Value<String>? aggregateId,
      Value<String>? eventType,
      Value<String>? idempotencyKey,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? attemptCount,
      Value<DateTime?>? nextAttemptAt,
      Value<String?>? leaseId,
      Value<DateTime?>? leaseExpiresAt,
      Value<String?>? lastError,
      Value<String?>? serverEventId,
      Value<DateTime?>? syncedAt,
      Value<int>? rowid}) {
    return SyncOutboxEventsCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      eventType: eventType ?? this.eventType,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      leaseId: leaseId ?? this.leaseId,
      leaseExpiresAt: leaseExpiresAt ?? this.leaseExpiresAt,
      lastError: lastError ?? this.lastError,
      serverEventId: serverEventId ?? this.serverEventId,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (leaseId.present) {
      map['lease_id'] = Variable<String>(leaseId.value);
    }
    if (leaseExpiresAt.present) {
      map['lease_expires_at'] = Variable<DateTime>(leaseExpiresAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (serverEventId.present) {
      map['server_event_id'] = Variable<String>(serverEventId.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEventsCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('eventType: $eventType, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('leaseId: $leaseId, ')
          ..write('leaseExpiresAt: $leaseExpiresAt, ')
          ..write('lastError: $lastError, ')
          ..write('serverEventId: $serverEventId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HardwareJobsTable extends HardwareJobs
    with TableInfo<$HardwareJobsTable, HardwareJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HardwareJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES invoices (id)'));
  static const VerificationMeta _jobTypeMeta =
      const VerificationMeta('jobType');
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
      'job_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _processingStartedAtMeta =
      const VerificationMeta('processingStartedAt');
  @override
  late final GeneratedColumn<DateTime> processingStartedAt =
      GeneratedColumn<DateTime>('processing_started_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        jobType,
        status,
        payloadJson,
        idempotencyKey,
        createdAt,
        attemptCount,
        processingStartedAt,
        nextAttemptAt,
        completedAt,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hardware_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<HardwareJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('job_type')) {
      context.handle(_jobTypeMeta,
          jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta));
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('processing_started_at')) {
      context.handle(
          _processingStartedAtMeta,
          processingStartedAt.isAcceptableOrUnknown(
              data['processing_started_at']!, _processingStartedAtMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HardwareJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HardwareJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      jobType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}job_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      processingStartedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}processing_started_at']),
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $HardwareJobsTable createAlias(String alias) {
    return $HardwareJobsTable(attachedDatabase, alias);
  }
}

class HardwareJob extends DataClass implements Insertable<HardwareJob> {
  final String id;
  final String invoiceId;
  final String jobType;
  final String status;
  final String payloadJson;
  final String idempotencyKey;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? processingStartedAt;
  final DateTime? nextAttemptAt;
  final DateTime? completedAt;
  final String? lastError;
  const HardwareJob(
      {required this.id,
      required this.invoiceId,
      required this.jobType,
      required this.status,
      required this.payloadJson,
      required this.idempotencyKey,
      required this.createdAt,
      required this.attemptCount,
      this.processingStartedAt,
      this.nextAttemptAt,
      this.completedAt,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['job_type'] = Variable<String>(jobType);
    map['status'] = Variable<String>(status);
    map['payload_json'] = Variable<String>(payloadJson);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || processingStartedAt != null) {
      map['processing_started_at'] = Variable<DateTime>(processingStartedAt);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  HardwareJobsCompanion toCompanion(bool nullToAbsent) {
    return HardwareJobsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      jobType: Value(jobType),
      status: Value(status),
      payloadJson: Value(payloadJson),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      processingStartedAt: processingStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processingStartedAt),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory HardwareJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HardwareJob(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      jobType: serializer.fromJson<String>(json['jobType']),
      status: serializer.fromJson<String>(json['status']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      processingStartedAt:
          serializer.fromJson<DateTime?>(json['processingStartedAt']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'jobType': serializer.toJson<String>(jobType),
      'status': serializer.toJson<String>(status),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'processingStartedAt': serializer.toJson<DateTime?>(processingStartedAt),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  HardwareJob copyWith(
          {String? id,
          String? invoiceId,
          String? jobType,
          String? status,
          String? payloadJson,
          String? idempotencyKey,
          DateTime? createdAt,
          int? attemptCount,
          Value<DateTime?> processingStartedAt = const Value.absent(),
          Value<DateTime?> nextAttemptAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> lastError = const Value.absent()}) =>
      HardwareJob(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        jobType: jobType ?? this.jobType,
        status: status ?? this.status,
        payloadJson: payloadJson ?? this.payloadJson,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        createdAt: createdAt ?? this.createdAt,
        attemptCount: attemptCount ?? this.attemptCount,
        processingStartedAt: processingStartedAt.present
            ? processingStartedAt.value
            : this.processingStartedAt,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  HardwareJob copyWithCompanion(HardwareJobsCompanion data) {
    return HardwareJob(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      status: data.status.present ? data.status.value : this.status,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      processingStartedAt: data.processingStartedAt.present
          ? data.processingStartedAt.value
          : this.processingStartedAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HardwareJob(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('processingStartedAt: $processingStartedAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      invoiceId,
      jobType,
      status,
      payloadJson,
      idempotencyKey,
      createdAt,
      attemptCount,
      processingStartedAt,
      nextAttemptAt,
      completedAt,
      lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HardwareJob &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.jobType == this.jobType &&
          other.status == this.status &&
          other.payloadJson == this.payloadJson &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.processingStartedAt == this.processingStartedAt &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.completedAt == this.completedAt &&
          other.lastError == this.lastError);
}

class HardwareJobsCompanion extends UpdateCompanion<HardwareJob> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> jobType;
  final Value<String> status;
  final Value<String> payloadJson;
  final Value<String> idempotencyKey;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<DateTime?> processingStartedAt;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime?> completedAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const HardwareJobsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.jobType = const Value.absent(),
    this.status = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.processingStartedAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HardwareJobsCompanion.insert({
    required String id,
    required String invoiceId,
    required String jobType,
    required String status,
    required String payloadJson,
    required String idempotencyKey,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.processingStartedAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        jobType = Value(jobType),
        status = Value(status),
        payloadJson = Value(payloadJson),
        idempotencyKey = Value(idempotencyKey),
        createdAt = Value(createdAt);
  static Insertable<HardwareJob> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? jobType,
    Expression<String>? status,
    Expression<String>? payloadJson,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<DateTime>? processingStartedAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? completedAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (jobType != null) 'job_type': jobType,
      if (status != null) 'status': status,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (processingStartedAt != null)
        'processing_started_at': processingStartedAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HardwareJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<String>? jobType,
      Value<String>? status,
      Value<String>? payloadJson,
      Value<String>? idempotencyKey,
      Value<DateTime>? createdAt,
      Value<int>? attemptCount,
      Value<DateTime?>? processingStartedAt,
      Value<DateTime?>? nextAttemptAt,
      Value<DateTime?>? completedAt,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return HardwareJobsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      jobType: jobType ?? this.jobType,
      status: status ?? this.status,
      payloadJson: payloadJson ?? this.payloadJson,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      processingStartedAt: processingStartedAt ?? this.processingStartedAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      completedAt: completedAt ?? this.completedAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (processingStartedAt.present) {
      map['processing_started_at'] =
          Variable<DateTime>(processingStartedAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HardwareJobsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('processingStartedAt: $processingStartedAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierConnectorsTable extends SupplierConnectors
    with TableInfo<$SupplierConnectorsTable, SupplierConnector> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierConnectorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _connectorTypeMeta =
      const VerificationMeta('connectorType');
  @override
  late final GeneratedColumn<String> connectorType = GeneratedColumn<String>(
      'connector_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _secretReferenceMeta =
      const VerificationMeta('secretReference');
  @override
  late final GeneratedColumn<String> secretReference = GeneratedColumn<String>(
      'secret_reference', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _approvedByMeta =
      const VerificationMeta('approvedBy');
  @override
  late final GeneratedColumn<String> approvedBy = GeneratedColumn<String>(
      'approved_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _approvedAtMeta =
      const VerificationMeta('approvedAt');
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
      'approved_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        branchId,
        name,
        connectorType,
        secretReference,
        isEnabled,
        approvedBy,
        approvedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_connectors';
  @override
  VerificationContext validateIntegrity(Insertable<SupplierConnector> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('connector_type')) {
      context.handle(
          _connectorTypeMeta,
          connectorType.isAcceptableOrUnknown(
              data['connector_type']!, _connectorTypeMeta));
    } else if (isInserting) {
      context.missing(_connectorTypeMeta);
    }
    if (data.containsKey('secret_reference')) {
      context.handle(
          _secretReferenceMeta,
          secretReference.isAcceptableOrUnknown(
              data['secret_reference']!, _secretReferenceMeta));
    } else if (isInserting) {
      context.missing(_secretReferenceMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('approved_by')) {
      context.handle(
          _approvedByMeta,
          approvedBy.isAcceptableOrUnknown(
              data['approved_by']!, _approvedByMeta));
    } else if (isInserting) {
      context.missing(_approvedByMeta);
    }
    if (data.containsKey('approved_at')) {
      context.handle(
          _approvedAtMeta,
          approvedAt.isAcceptableOrUnknown(
              data['approved_at']!, _approvedAtMeta));
    } else if (isInserting) {
      context.missing(_approvedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierConnector map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierConnector(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      connectorType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}connector_type'])!,
      secretReference: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}secret_reference'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      approvedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}approved_by'])!,
      approvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}approved_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SupplierConnectorsTable createAlias(String alias) {
    return $SupplierConnectorsTable(attachedDatabase, alias);
  }
}

class SupplierConnector extends DataClass
    implements Insertable<SupplierConnector> {
  final String id;
  final String branchId;
  final String name;
  final String connectorType;
  final String secretReference;
  final bool isEnabled;
  final String approvedBy;
  final DateTime approvedAt;
  final DateTime createdAt;
  const SupplierConnector(
      {required this.id,
      required this.branchId,
      required this.name,
      required this.connectorType,
      required this.secretReference,
      required this.isEnabled,
      required this.approvedBy,
      required this.approvedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['branch_id'] = Variable<String>(branchId);
    map['name'] = Variable<String>(name);
    map['connector_type'] = Variable<String>(connectorType);
    map['secret_reference'] = Variable<String>(secretReference);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['approved_by'] = Variable<String>(approvedBy);
    map['approved_at'] = Variable<DateTime>(approvedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SupplierConnectorsCompanion toCompanion(bool nullToAbsent) {
    return SupplierConnectorsCompanion(
      id: Value(id),
      branchId: Value(branchId),
      name: Value(name),
      connectorType: Value(connectorType),
      secretReference: Value(secretReference),
      isEnabled: Value(isEnabled),
      approvedBy: Value(approvedBy),
      approvedAt: Value(approvedAt),
      createdAt: Value(createdAt),
    );
  }

  factory SupplierConnector.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierConnector(
      id: serializer.fromJson<String>(json['id']),
      branchId: serializer.fromJson<String>(json['branchId']),
      name: serializer.fromJson<String>(json['name']),
      connectorType: serializer.fromJson<String>(json['connectorType']),
      secretReference: serializer.fromJson<String>(json['secretReference']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      approvedBy: serializer.fromJson<String>(json['approvedBy']),
      approvedAt: serializer.fromJson<DateTime>(json['approvedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'branchId': serializer.toJson<String>(branchId),
      'name': serializer.toJson<String>(name),
      'connectorType': serializer.toJson<String>(connectorType),
      'secretReference': serializer.toJson<String>(secretReference),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'approvedBy': serializer.toJson<String>(approvedBy),
      'approvedAt': serializer.toJson<DateTime>(approvedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupplierConnector copyWith(
          {String? id,
          String? branchId,
          String? name,
          String? connectorType,
          String? secretReference,
          bool? isEnabled,
          String? approvedBy,
          DateTime? approvedAt,
          DateTime? createdAt}) =>
      SupplierConnector(
        id: id ?? this.id,
        branchId: branchId ?? this.branchId,
        name: name ?? this.name,
        connectorType: connectorType ?? this.connectorType,
        secretReference: secretReference ?? this.secretReference,
        isEnabled: isEnabled ?? this.isEnabled,
        approvedBy: approvedBy ?? this.approvedBy,
        approvedAt: approvedAt ?? this.approvedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  SupplierConnector copyWithCompanion(SupplierConnectorsCompanion data) {
    return SupplierConnector(
      id: data.id.present ? data.id.value : this.id,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      name: data.name.present ? data.name.value : this.name,
      connectorType: data.connectorType.present
          ? data.connectorType.value
          : this.connectorType,
      secretReference: data.secretReference.present
          ? data.secretReference.value
          : this.secretReference,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      approvedBy:
          data.approvedBy.present ? data.approvedBy.value : this.approvedBy,
      approvedAt:
          data.approvedAt.present ? data.approvedAt.value : this.approvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierConnector(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('connectorType: $connectorType, ')
          ..write('secretReference: $secretReference, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, branchId, name, connectorType,
      secretReference, isEnabled, approvedBy, approvedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierConnector &&
          other.id == this.id &&
          other.branchId == this.branchId &&
          other.name == this.name &&
          other.connectorType == this.connectorType &&
          other.secretReference == this.secretReference &&
          other.isEnabled == this.isEnabled &&
          other.approvedBy == this.approvedBy &&
          other.approvedAt == this.approvedAt &&
          other.createdAt == this.createdAt);
}

class SupplierConnectorsCompanion extends UpdateCompanion<SupplierConnector> {
  final Value<String> id;
  final Value<String> branchId;
  final Value<String> name;
  final Value<String> connectorType;
  final Value<String> secretReference;
  final Value<bool> isEnabled;
  final Value<String> approvedBy;
  final Value<DateTime> approvedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SupplierConnectorsCompanion({
    this.id = const Value.absent(),
    this.branchId = const Value.absent(),
    this.name = const Value.absent(),
    this.connectorType = const Value.absent(),
    this.secretReference = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierConnectorsCompanion.insert({
    required String id,
    required String branchId,
    required String name,
    required String connectorType,
    required String secretReference,
    this.isEnabled = const Value.absent(),
    required String approvedBy,
    required DateTime approvedAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        branchId = Value(branchId),
        name = Value(name),
        connectorType = Value(connectorType),
        secretReference = Value(secretReference),
        approvedBy = Value(approvedBy),
        approvedAt = Value(approvedAt),
        createdAt = Value(createdAt);
  static Insertable<SupplierConnector> custom({
    Expression<String>? id,
    Expression<String>? branchId,
    Expression<String>? name,
    Expression<String>? connectorType,
    Expression<String>? secretReference,
    Expression<bool>? isEnabled,
    Expression<String>? approvedBy,
    Expression<DateTime>? approvedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (branchId != null) 'branch_id': branchId,
      if (name != null) 'name': name,
      if (connectorType != null) 'connector_type': connectorType,
      if (secretReference != null) 'secret_reference': secretReference,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierConnectorsCompanion copyWith(
      {Value<String>? id,
      Value<String>? branchId,
      Value<String>? name,
      Value<String>? connectorType,
      Value<String>? secretReference,
      Value<bool>? isEnabled,
      Value<String>? approvedBy,
      Value<DateTime>? approvedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SupplierConnectorsCompanion(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      connectorType: connectorType ?? this.connectorType,
      secretReference: secretReference ?? this.secretReference,
      isEnabled: isEnabled ?? this.isEnabled,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (connectorType.present) {
      map['connector_type'] = Variable<String>(connectorType.value);
    }
    if (secretReference.present) {
      map['secret_reference'] = Variable<String>(secretReference.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (approvedBy.present) {
      map['approved_by'] = Variable<String>(approvedBy.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierConnectorsCompanion(')
          ..write('id: $id, ')
          ..write('branchId: $branchId, ')
          ..write('name: $name, ')
          ..write('connectorType: $connectorType, ')
          ..write('secretReference: $secretReference, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierProductSubscriptionsTable extends SupplierProductSubscriptions
    with
        TableInfo<$SupplierProductSubscriptionsTable,
            SupplierProductSubscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierProductSubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _connectorIdMeta =
      const VerificationMeta('connectorId');
  @override
  late final GeneratedColumn<String> connectorId = GeneratedColumn<String>(
      'connector_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES supplier_connectors (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _allowedFieldsJsonMeta =
      const VerificationMeta('allowedFieldsJson');
  @override
  late final GeneratedColumn<String> allowedFieldsJson =
      GeneratedColumn<String>('allowed_fields_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _suggestedOrderQuantityMeta =
      const VerificationMeta('suggestedOrderQuantity');
  @override
  late final GeneratedColumn<int> suggestedOrderQuantity = GeneratedColumn<int>(
      'suggested_order_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _approvedByMeta =
      const VerificationMeta('approvedBy');
  @override
  late final GeneratedColumn<String> approvedBy = GeneratedColumn<String>(
      'approved_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _approvedAtMeta =
      const VerificationMeta('approvedAt');
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
      'approved_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        connectorId,
        productId,
        allowedFieldsJson,
        suggestedOrderQuantity,
        isEnabled,
        approvedBy,
        approvedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_product_subscriptions';
  @override
  VerificationContext validateIntegrity(
      Insertable<SupplierProductSubscription> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('connector_id')) {
      context.handle(
          _connectorIdMeta,
          connectorId.isAcceptableOrUnknown(
              data['connector_id']!, _connectorIdMeta));
    } else if (isInserting) {
      context.missing(_connectorIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('allowed_fields_json')) {
      context.handle(
          _allowedFieldsJsonMeta,
          allowedFieldsJson.isAcceptableOrUnknown(
              data['allowed_fields_json']!, _allowedFieldsJsonMeta));
    } else if (isInserting) {
      context.missing(_allowedFieldsJsonMeta);
    }
    if (data.containsKey('suggested_order_quantity')) {
      context.handle(
          _suggestedOrderQuantityMeta,
          suggestedOrderQuantity.isAcceptableOrUnknown(
              data['suggested_order_quantity']!, _suggestedOrderQuantityMeta));
    } else if (isInserting) {
      context.missing(_suggestedOrderQuantityMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('approved_by')) {
      context.handle(
          _approvedByMeta,
          approvedBy.isAcceptableOrUnknown(
              data['approved_by']!, _approvedByMeta));
    } else if (isInserting) {
      context.missing(_approvedByMeta);
    }
    if (data.containsKey('approved_at')) {
      context.handle(
          _approvedAtMeta,
          approvedAt.isAcceptableOrUnknown(
              data['approved_at']!, _approvedAtMeta));
    } else if (isInserting) {
      context.missing(_approvedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {connectorId, productId};
  @override
  SupplierProductSubscription map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierProductSubscription(
      connectorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}connector_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      allowedFieldsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}allowed_fields_json'])!,
      suggestedOrderQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}suggested_order_quantity'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      approvedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}approved_by'])!,
      approvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}approved_at'])!,
    );
  }

  @override
  $SupplierProductSubscriptionsTable createAlias(String alias) {
    return $SupplierProductSubscriptionsTable(attachedDatabase, alias);
  }
}

class SupplierProductSubscription extends DataClass
    implements Insertable<SupplierProductSubscription> {
  final String connectorId;
  final String productId;
  final String allowedFieldsJson;
  final int suggestedOrderQuantity;
  final bool isEnabled;
  final String approvedBy;
  final DateTime approvedAt;
  const SupplierProductSubscription(
      {required this.connectorId,
      required this.productId,
      required this.allowedFieldsJson,
      required this.suggestedOrderQuantity,
      required this.isEnabled,
      required this.approvedBy,
      required this.approvedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['connector_id'] = Variable<String>(connectorId);
    map['product_id'] = Variable<String>(productId);
    map['allowed_fields_json'] = Variable<String>(allowedFieldsJson);
    map['suggested_order_quantity'] = Variable<int>(suggestedOrderQuantity);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['approved_by'] = Variable<String>(approvedBy);
    map['approved_at'] = Variable<DateTime>(approvedAt);
    return map;
  }

  SupplierProductSubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SupplierProductSubscriptionsCompanion(
      connectorId: Value(connectorId),
      productId: Value(productId),
      allowedFieldsJson: Value(allowedFieldsJson),
      suggestedOrderQuantity: Value(suggestedOrderQuantity),
      isEnabled: Value(isEnabled),
      approvedBy: Value(approvedBy),
      approvedAt: Value(approvedAt),
    );
  }

  factory SupplierProductSubscription.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierProductSubscription(
      connectorId: serializer.fromJson<String>(json['connectorId']),
      productId: serializer.fromJson<String>(json['productId']),
      allowedFieldsJson: serializer.fromJson<String>(json['allowedFieldsJson']),
      suggestedOrderQuantity:
          serializer.fromJson<int>(json['suggestedOrderQuantity']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      approvedBy: serializer.fromJson<String>(json['approvedBy']),
      approvedAt: serializer.fromJson<DateTime>(json['approvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'connectorId': serializer.toJson<String>(connectorId),
      'productId': serializer.toJson<String>(productId),
      'allowedFieldsJson': serializer.toJson<String>(allowedFieldsJson),
      'suggestedOrderQuantity': serializer.toJson<int>(suggestedOrderQuantity),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'approvedBy': serializer.toJson<String>(approvedBy),
      'approvedAt': serializer.toJson<DateTime>(approvedAt),
    };
  }

  SupplierProductSubscription copyWith(
          {String? connectorId,
          String? productId,
          String? allowedFieldsJson,
          int? suggestedOrderQuantity,
          bool? isEnabled,
          String? approvedBy,
          DateTime? approvedAt}) =>
      SupplierProductSubscription(
        connectorId: connectorId ?? this.connectorId,
        productId: productId ?? this.productId,
        allowedFieldsJson: allowedFieldsJson ?? this.allowedFieldsJson,
        suggestedOrderQuantity:
            suggestedOrderQuantity ?? this.suggestedOrderQuantity,
        isEnabled: isEnabled ?? this.isEnabled,
        approvedBy: approvedBy ?? this.approvedBy,
        approvedAt: approvedAt ?? this.approvedAt,
      );
  SupplierProductSubscription copyWithCompanion(
      SupplierProductSubscriptionsCompanion data) {
    return SupplierProductSubscription(
      connectorId:
          data.connectorId.present ? data.connectorId.value : this.connectorId,
      productId: data.productId.present ? data.productId.value : this.productId,
      allowedFieldsJson: data.allowedFieldsJson.present
          ? data.allowedFieldsJson.value
          : this.allowedFieldsJson,
      suggestedOrderQuantity: data.suggestedOrderQuantity.present
          ? data.suggestedOrderQuantity.value
          : this.suggestedOrderQuantity,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      approvedBy:
          data.approvedBy.present ? data.approvedBy.value : this.approvedBy,
      approvedAt:
          data.approvedAt.present ? data.approvedAt.value : this.approvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierProductSubscription(')
          ..write('connectorId: $connectorId, ')
          ..write('productId: $productId, ')
          ..write('allowedFieldsJson: $allowedFieldsJson, ')
          ..write('suggestedOrderQuantity: $suggestedOrderQuantity, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('approvedAt: $approvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(connectorId, productId, allowedFieldsJson,
      suggestedOrderQuantity, isEnabled, approvedBy, approvedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierProductSubscription &&
          other.connectorId == this.connectorId &&
          other.productId == this.productId &&
          other.allowedFieldsJson == this.allowedFieldsJson &&
          other.suggestedOrderQuantity == this.suggestedOrderQuantity &&
          other.isEnabled == this.isEnabled &&
          other.approvedBy == this.approvedBy &&
          other.approvedAt == this.approvedAt);
}

class SupplierProductSubscriptionsCompanion
    extends UpdateCompanion<SupplierProductSubscription> {
  final Value<String> connectorId;
  final Value<String> productId;
  final Value<String> allowedFieldsJson;
  final Value<int> suggestedOrderQuantity;
  final Value<bool> isEnabled;
  final Value<String> approvedBy;
  final Value<DateTime> approvedAt;
  final Value<int> rowid;
  const SupplierProductSubscriptionsCompanion({
    this.connectorId = const Value.absent(),
    this.productId = const Value.absent(),
    this.allowedFieldsJson = const Value.absent(),
    this.suggestedOrderQuantity = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.approvedBy = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierProductSubscriptionsCompanion.insert({
    required String connectorId,
    required String productId,
    required String allowedFieldsJson,
    required int suggestedOrderQuantity,
    this.isEnabled = const Value.absent(),
    required String approvedBy,
    required DateTime approvedAt,
    this.rowid = const Value.absent(),
  })  : connectorId = Value(connectorId),
        productId = Value(productId),
        allowedFieldsJson = Value(allowedFieldsJson),
        suggestedOrderQuantity = Value(suggestedOrderQuantity),
        approvedBy = Value(approvedBy),
        approvedAt = Value(approvedAt);
  static Insertable<SupplierProductSubscription> custom({
    Expression<String>? connectorId,
    Expression<String>? productId,
    Expression<String>? allowedFieldsJson,
    Expression<int>? suggestedOrderQuantity,
    Expression<bool>? isEnabled,
    Expression<String>? approvedBy,
    Expression<DateTime>? approvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (connectorId != null) 'connector_id': connectorId,
      if (productId != null) 'product_id': productId,
      if (allowedFieldsJson != null) 'allowed_fields_json': allowedFieldsJson,
      if (suggestedOrderQuantity != null)
        'suggested_order_quantity': suggestedOrderQuantity,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierProductSubscriptionsCompanion copyWith(
      {Value<String>? connectorId,
      Value<String>? productId,
      Value<String>? allowedFieldsJson,
      Value<int>? suggestedOrderQuantity,
      Value<bool>? isEnabled,
      Value<String>? approvedBy,
      Value<DateTime>? approvedAt,
      Value<int>? rowid}) {
    return SupplierProductSubscriptionsCompanion(
      connectorId: connectorId ?? this.connectorId,
      productId: productId ?? this.productId,
      allowedFieldsJson: allowedFieldsJson ?? this.allowedFieldsJson,
      suggestedOrderQuantity:
          suggestedOrderQuantity ?? this.suggestedOrderQuantity,
      isEnabled: isEnabled ?? this.isEnabled,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (connectorId.present) {
      map['connector_id'] = Variable<String>(connectorId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (allowedFieldsJson.present) {
      map['allowed_fields_json'] = Variable<String>(allowedFieldsJson.value);
    }
    if (suggestedOrderQuantity.present) {
      map['suggested_order_quantity'] =
          Variable<int>(suggestedOrderQuantity.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (approvedBy.present) {
      map['approved_by'] = Variable<String>(approvedBy.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierProductSubscriptionsCompanion(')
          ..write('connectorId: $connectorId, ')
          ..write('productId: $productId, ')
          ..write('allowedFieldsJson: $allowedFieldsJson, ')
          ..write('suggestedOrderQuantity: $suggestedOrderQuantity, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('approvedBy: $approvedBy, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierDeliveryJobsTable extends SupplierDeliveryJobs
    with TableInfo<$SupplierDeliveryJobsTable, SupplierDeliveryJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierDeliveryJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _connectorIdMeta =
      const VerificationMeta('connectorId');
  @override
  late final GeneratedColumn<String> connectorId = GeneratedColumn<String>(
      'connector_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES supplier_connectors (id)'));
  static const VerificationMeta _sourceEventIdMeta =
      const VerificationMeta('sourceEventId');
  @override
  late final GeneratedColumn<String> sourceEventId = GeneratedColumn<String>(
      'source_event_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sync_outbox_events (id)'));
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES branches (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES products (id)'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _leaseIdMeta =
      const VerificationMeta('leaseId');
  @override
  late final GeneratedColumn<String> leaseId = GeneratedColumn<String>(
      'lease_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _leaseExpiresAtMeta =
      const VerificationMeta('leaseExpiresAt');
  @override
  late final GeneratedColumn<DateTime> leaseExpiresAt =
      GeneratedColumn<DateTime>('lease_expires_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _externalReferenceMeta =
      const VerificationMeta('externalReference');
  @override
  late final GeneratedColumn<String> externalReference =
      GeneratedColumn<String>('external_reference', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        connectorId,
        sourceEventId,
        branchId,
        productId,
        status,
        idempotencyKey,
        payloadJson,
        createdAt,
        attemptCount,
        leaseId,
        leaseExpiresAt,
        nextAttemptAt,
        completedAt,
        externalReference,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_delivery_jobs';
  @override
  VerificationContext validateIntegrity(
      Insertable<SupplierDeliveryJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('connector_id')) {
      context.handle(
          _connectorIdMeta,
          connectorId.isAcceptableOrUnknown(
              data['connector_id']!, _connectorIdMeta));
    } else if (isInserting) {
      context.missing(_connectorIdMeta);
    }
    if (data.containsKey('source_event_id')) {
      context.handle(
          _sourceEventIdMeta,
          sourceEventId.isAcceptableOrUnknown(
              data['source_event_id']!, _sourceEventIdMeta));
    } else if (isInserting) {
      context.missing(_sourceEventIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('lease_id')) {
      context.handle(_leaseIdMeta,
          leaseId.isAcceptableOrUnknown(data['lease_id']!, _leaseIdMeta));
    }
    if (data.containsKey('lease_expires_at')) {
      context.handle(
          _leaseExpiresAtMeta,
          leaseExpiresAt.isAcceptableOrUnknown(
              data['lease_expires_at']!, _leaseExpiresAtMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('external_reference')) {
      context.handle(
          _externalReferenceMeta,
          externalReference.isAcceptableOrUnknown(
              data['external_reference']!, _externalReferenceMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierDeliveryJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierDeliveryJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      connectorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}connector_id'])!,
      sourceEventId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_event_id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      leaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lease_id']),
      leaseExpiresAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}lease_expires_at']),
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      externalReference: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_reference']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SupplierDeliveryJobsTable createAlias(String alias) {
    return $SupplierDeliveryJobsTable(attachedDatabase, alias);
  }
}

class SupplierDeliveryJob extends DataClass
    implements Insertable<SupplierDeliveryJob> {
  final String id;
  final String connectorId;
  final String sourceEventId;
  final String branchId;
  final String productId;
  final String status;
  final String idempotencyKey;
  final String payloadJson;
  final DateTime createdAt;
  final int attemptCount;
  final String? leaseId;
  final DateTime? leaseExpiresAt;
  final DateTime? nextAttemptAt;
  final DateTime? completedAt;
  final String? externalReference;
  final String? lastError;
  const SupplierDeliveryJob(
      {required this.id,
      required this.connectorId,
      required this.sourceEventId,
      required this.branchId,
      required this.productId,
      required this.status,
      required this.idempotencyKey,
      required this.payloadJson,
      required this.createdAt,
      required this.attemptCount,
      this.leaseId,
      this.leaseExpiresAt,
      this.nextAttemptAt,
      this.completedAt,
      this.externalReference,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['connector_id'] = Variable<String>(connectorId);
    map['source_event_id'] = Variable<String>(sourceEventId);
    map['branch_id'] = Variable<String>(branchId);
    map['product_id'] = Variable<String>(productId);
    map['status'] = Variable<String>(status);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || leaseId != null) {
      map['lease_id'] = Variable<String>(leaseId);
    }
    if (!nullToAbsent || leaseExpiresAt != null) {
      map['lease_expires_at'] = Variable<DateTime>(leaseExpiresAt);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || externalReference != null) {
      map['external_reference'] = Variable<String>(externalReference);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SupplierDeliveryJobsCompanion toCompanion(bool nullToAbsent) {
    return SupplierDeliveryJobsCompanion(
      id: Value(id),
      connectorId: Value(connectorId),
      sourceEventId: Value(sourceEventId),
      branchId: Value(branchId),
      productId: Value(productId),
      status: Value(status),
      idempotencyKey: Value(idempotencyKey),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      leaseId: leaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseId),
      leaseExpiresAt: leaseExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseExpiresAt),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      externalReference: externalReference == null && nullToAbsent
          ? const Value.absent()
          : Value(externalReference),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SupplierDeliveryJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierDeliveryJob(
      id: serializer.fromJson<String>(json['id']),
      connectorId: serializer.fromJson<String>(json['connectorId']),
      sourceEventId: serializer.fromJson<String>(json['sourceEventId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      productId: serializer.fromJson<String>(json['productId']),
      status: serializer.fromJson<String>(json['status']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      leaseId: serializer.fromJson<String?>(json['leaseId']),
      leaseExpiresAt: serializer.fromJson<DateTime?>(json['leaseExpiresAt']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      externalReference:
          serializer.fromJson<String?>(json['externalReference']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'connectorId': serializer.toJson<String>(connectorId),
      'sourceEventId': serializer.toJson<String>(sourceEventId),
      'branchId': serializer.toJson<String>(branchId),
      'productId': serializer.toJson<String>(productId),
      'status': serializer.toJson<String>(status),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'leaseId': serializer.toJson<String?>(leaseId),
      'leaseExpiresAt': serializer.toJson<DateTime?>(leaseExpiresAt),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'externalReference': serializer.toJson<String?>(externalReference),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SupplierDeliveryJob copyWith(
          {String? id,
          String? connectorId,
          String? sourceEventId,
          String? branchId,
          String? productId,
          String? status,
          String? idempotencyKey,
          String? payloadJson,
          DateTime? createdAt,
          int? attemptCount,
          Value<String?> leaseId = const Value.absent(),
          Value<DateTime?> leaseExpiresAt = const Value.absent(),
          Value<DateTime?> nextAttemptAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> externalReference = const Value.absent(),
          Value<String?> lastError = const Value.absent()}) =>
      SupplierDeliveryJob(
        id: id ?? this.id,
        connectorId: connectorId ?? this.connectorId,
        sourceEventId: sourceEventId ?? this.sourceEventId,
        branchId: branchId ?? this.branchId,
        productId: productId ?? this.productId,
        status: status ?? this.status,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        attemptCount: attemptCount ?? this.attemptCount,
        leaseId: leaseId.present ? leaseId.value : this.leaseId,
        leaseExpiresAt:
            leaseExpiresAt.present ? leaseExpiresAt.value : this.leaseExpiresAt,
        nextAttemptAt:
            nextAttemptAt.present ? nextAttemptAt.value : this.nextAttemptAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        externalReference: externalReference.present
            ? externalReference.value
            : this.externalReference,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  SupplierDeliveryJob copyWithCompanion(SupplierDeliveryJobsCompanion data) {
    return SupplierDeliveryJob(
      id: data.id.present ? data.id.value : this.id,
      connectorId:
          data.connectorId.present ? data.connectorId.value : this.connectorId,
      sourceEventId: data.sourceEventId.present
          ? data.sourceEventId.value
          : this.sourceEventId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      productId: data.productId.present ? data.productId.value : this.productId,
      status: data.status.present ? data.status.value : this.status,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      leaseId: data.leaseId.present ? data.leaseId.value : this.leaseId,
      leaseExpiresAt: data.leaseExpiresAt.present
          ? data.leaseExpiresAt.value
          : this.leaseExpiresAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      externalReference: data.externalReference.present
          ? data.externalReference.value
          : this.externalReference,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierDeliveryJob(')
          ..write('id: $id, ')
          ..write('connectorId: $connectorId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('branchId: $branchId, ')
          ..write('productId: $productId, ')
          ..write('status: $status, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('leaseId: $leaseId, ')
          ..write('leaseExpiresAt: $leaseExpiresAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('externalReference: $externalReference, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      connectorId,
      sourceEventId,
      branchId,
      productId,
      status,
      idempotencyKey,
      payloadJson,
      createdAt,
      attemptCount,
      leaseId,
      leaseExpiresAt,
      nextAttemptAt,
      completedAt,
      externalReference,
      lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierDeliveryJob &&
          other.id == this.id &&
          other.connectorId == this.connectorId &&
          other.sourceEventId == this.sourceEventId &&
          other.branchId == this.branchId &&
          other.productId == this.productId &&
          other.status == this.status &&
          other.idempotencyKey == this.idempotencyKey &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.leaseId == this.leaseId &&
          other.leaseExpiresAt == this.leaseExpiresAt &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.completedAt == this.completedAt &&
          other.externalReference == this.externalReference &&
          other.lastError == this.lastError);
}

class SupplierDeliveryJobsCompanion
    extends UpdateCompanion<SupplierDeliveryJob> {
  final Value<String> id;
  final Value<String> connectorId;
  final Value<String> sourceEventId;
  final Value<String> branchId;
  final Value<String> productId;
  final Value<String> status;
  final Value<String> idempotencyKey;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<String?> leaseId;
  final Value<DateTime?> leaseExpiresAt;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime?> completedAt;
  final Value<String?> externalReference;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SupplierDeliveryJobsCompanion({
    this.id = const Value.absent(),
    this.connectorId = const Value.absent(),
    this.sourceEventId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.productId = const Value.absent(),
    this.status = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.leaseId = const Value.absent(),
    this.leaseExpiresAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.externalReference = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierDeliveryJobsCompanion.insert({
    required String id,
    required String connectorId,
    required String sourceEventId,
    required String branchId,
    required String productId,
    required String status,
    required String idempotencyKey,
    required String payloadJson,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.leaseId = const Value.absent(),
    this.leaseExpiresAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.externalReference = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        connectorId = Value(connectorId),
        sourceEventId = Value(sourceEventId),
        branchId = Value(branchId),
        productId = Value(productId),
        status = Value(status),
        idempotencyKey = Value(idempotencyKey),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<SupplierDeliveryJob> custom({
    Expression<String>? id,
    Expression<String>? connectorId,
    Expression<String>? sourceEventId,
    Expression<String>? branchId,
    Expression<String>? productId,
    Expression<String>? status,
    Expression<String>? idempotencyKey,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<String>? leaseId,
    Expression<DateTime>? leaseExpiresAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? completedAt,
    Expression<String>? externalReference,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (connectorId != null) 'connector_id': connectorId,
      if (sourceEventId != null) 'source_event_id': sourceEventId,
      if (branchId != null) 'branch_id': branchId,
      if (productId != null) 'product_id': productId,
      if (status != null) 'status': status,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (leaseId != null) 'lease_id': leaseId,
      if (leaseExpiresAt != null) 'lease_expires_at': leaseExpiresAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (externalReference != null) 'external_reference': externalReference,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierDeliveryJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? connectorId,
      Value<String>? sourceEventId,
      Value<String>? branchId,
      Value<String>? productId,
      Value<String>? status,
      Value<String>? idempotencyKey,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? attemptCount,
      Value<String?>? leaseId,
      Value<DateTime?>? leaseExpiresAt,
      Value<DateTime?>? nextAttemptAt,
      Value<DateTime?>? completedAt,
      Value<String?>? externalReference,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return SupplierDeliveryJobsCompanion(
      id: id ?? this.id,
      connectorId: connectorId ?? this.connectorId,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      branchId: branchId ?? this.branchId,
      productId: productId ?? this.productId,
      status: status ?? this.status,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      leaseId: leaseId ?? this.leaseId,
      leaseExpiresAt: leaseExpiresAt ?? this.leaseExpiresAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      completedAt: completedAt ?? this.completedAt,
      externalReference: externalReference ?? this.externalReference,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (connectorId.present) {
      map['connector_id'] = Variable<String>(connectorId.value);
    }
    if (sourceEventId.present) {
      map['source_event_id'] = Variable<String>(sourceEventId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (leaseId.present) {
      map['lease_id'] = Variable<String>(leaseId.value);
    }
    if (leaseExpiresAt.present) {
      map['lease_expires_at'] = Variable<DateTime>(leaseExpiresAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (externalReference.present) {
      map['external_reference'] = Variable<String>(externalReference.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierDeliveryJobsCompanion(')
          ..write('id: $id, ')
          ..write('connectorId: $connectorId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('branchId: $branchId, ')
          ..write('productId: $productId, ')
          ..write('status: $status, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('leaseId: $leaseId, ')
          ..write('leaseExpiresAt: $leaseExpiresAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('externalReference: $externalReference, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $TerminalsTable terminals = $TerminalsTable(this);
  late final $StaffUsersTable staffUsers = $StaffUsersTable(this);
  late final $StaffBranchAccessTable staffBranchAccess =
      $StaffBranchAccessTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $BranchInventoriesTable branchInventories =
      $BranchInventoriesTable(this);
  late final $InvoiceSequencesTable invoiceSequences =
      $InvoiceSequencesTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceLinesTable invoiceLines = $InvoiceLinesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $InventoryMovementsTable inventoryMovements =
      $InventoryMovementsTable(this);
  late final $InventoryTransfersTable inventoryTransfers =
      $InventoryTransfersTable(this);
  late final $AuditEventsTable auditEvents = $AuditEventsTable(this);
  late final $SyncOutboxEventsTable syncOutboxEvents =
      $SyncOutboxEventsTable(this);
  late final $HardwareJobsTable hardwareJobs = $HardwareJobsTable(this);
  late final $SupplierConnectorsTable supplierConnectors =
      $SupplierConnectorsTable(this);
  late final $SupplierProductSubscriptionsTable supplierProductSubscriptions =
      $SupplierProductSubscriptionsTable(this);
  late final $SupplierDeliveryJobsTable supplierDeliveryJobs =
      $SupplierDeliveryJobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        branches,
        terminals,
        staffUsers,
        staffBranchAccess,
        products,
        branchInventories,
        invoiceSequences,
        invoices,
        invoiceLines,
        payments,
        inventoryMovements,
        inventoryTransfers,
        auditEvents,
        syncOutboxEvents,
        hardwareJobs,
        supplierConnectors,
        supplierProductSubscriptions,
        supplierDeliveryJobs
      ];
}

typedef $$BranchesTableCreateCompanionBuilder = BranchesCompanion Function({
  required String id,
  required String code,
  required String name,
  Value<bool> isActive,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$BranchesTableUpdateCompanionBuilder = BranchesCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> name,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$BranchesTableReferences
    extends BaseReferences<_$AppDatabase, $BranchesTable, Branche> {
  $$BranchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TerminalsTable, List<Terminal>>
      _terminalsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.terminals,
              aliasName:
                  $_aliasNameGenerator(db.branches.id, db.terminals.branchId));

  $$TerminalsTableProcessedTableManager get terminalsRefs {
    final manager = $$TerminalsTableTableManager($_db, $_db.terminals)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_terminalsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StaffBranchAccessTable,
      List<StaffBranchAccessData>> _staffBranchAccessRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.staffBranchAccess,
          aliasName: $_aliasNameGenerator(
              db.branches.id, db.staffBranchAccess.branchId));

  $$StaffBranchAccessTableProcessedTableManager get staffBranchAccessRefs {
    final manager = $$StaffBranchAccessTableTableManager(
            $_db, $_db.staffBranchAccess)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_staffBranchAccessRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BranchInventoriesTable, List<BranchInventory>>
      _branchInventoriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.branchInventories,
              aliasName: $_aliasNameGenerator(
                  db.branches.id, db.branchInventories.branchId));

  $$BranchInventoriesTableProcessedTableManager get branchInventoriesRefs {
    final manager = $$BranchInventoriesTableTableManager(
            $_db, $_db.branchInventories)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_branchInventoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.invoices,
          aliasName:
              $_aliasNameGenerator(db.branches.id, db.invoices.branchId));

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryMovementsTable, List<InventoryMovement>>
      _inventoryMovementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryMovements,
              aliasName: $_aliasNameGenerator(
                  db.branches.id, db.inventoryMovements.branchId));

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager = $$InventoryMovementsTableTableManager(
            $_db, $_db.inventoryMovements)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_inventoryMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryTransfersTable, List<InventoryTransfer>>
      _sourceBranchTransfersTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryTransfers,
              aliasName: $_aliasNameGenerator(
                  db.branches.id, db.inventoryTransfers.sourceBranchId));

  $$InventoryTransfersTableProcessedTableManager get sourceBranchTransfers {
    final manager = $$InventoryTransfersTableTableManager(
            $_db, $_db.inventoryTransfers)
        .filter(
            (f) => f.sourceBranchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_sourceBranchTransfersTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryTransfersTable, List<InventoryTransfer>>
      _destinationBranchTransfersTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryTransfers,
              aliasName: $_aliasNameGenerator(
                  db.branches.id, db.inventoryTransfers.destinationBranchId));

  $$InventoryTransfersTableProcessedTableManager
      get destinationBranchTransfers {
    final manager = $$InventoryTransfersTableTableManager(
            $_db, $_db.inventoryTransfers)
        .filter((f) =>
            f.destinationBranchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_destinationBranchTransfersTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AuditEventsTable, List<AuditEvent>>
      _auditEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.auditEvents,
          aliasName:
              $_aliasNameGenerator(db.branches.id, db.auditEvents.branchId));

  $$AuditEventsTableProcessedTableManager get auditEventsRefs {
    final manager = $$AuditEventsTableTableManager($_db, $_db.auditEvents)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SyncOutboxEventsTable, List<SyncOutboxEvent>>
      _syncOutboxEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.syncOutboxEvents,
              aliasName: $_aliasNameGenerator(
                  db.branches.id, db.syncOutboxEvents.branchId));

  $$SyncOutboxEventsTableProcessedTableManager get syncOutboxEventsRefs {
    final manager = $$SyncOutboxEventsTableTableManager(
            $_db, $_db.syncOutboxEvents)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_syncOutboxEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SupplierConnectorsTable, List<SupplierConnector>>
      _supplierConnectorsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.supplierConnectors,
              aliasName: $_aliasNameGenerator(
                  db.branches.id, db.supplierConnectors.branchId));

  $$SupplierConnectorsTableProcessedTableManager get supplierConnectorsRefs {
    final manager = $$SupplierConnectorsTableTableManager(
            $_db, $_db.supplierConnectors)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_supplierConnectorsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SupplierDeliveryJobsTable,
      List<SupplierDeliveryJob>> _supplierDeliveryJobsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.supplierDeliveryJobs,
          aliasName: $_aliasNameGenerator(
              db.branches.id, db.supplierDeliveryJobs.branchId));

  $$SupplierDeliveryJobsTableProcessedTableManager
      get supplierDeliveryJobsRefs {
    final manager = $$SupplierDeliveryJobsTableTableManager(
            $_db, $_db.supplierDeliveryJobs)
        .filter((f) => f.branchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_supplierDeliveryJobsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BranchesTableFilterComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> terminalsRefs(
      Expression<bool> Function($$TerminalsTableFilterComposer f) f) {
    final $$TerminalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.terminals,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TerminalsTableFilterComposer(
              $db: $db,
              $table: $db.terminals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> staffBranchAccessRefs(
      Expression<bool> Function($$StaffBranchAccessTableFilterComposer f) f) {
    final $$StaffBranchAccessTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.staffBranchAccess,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffBranchAccessTableFilterComposer(
              $db: $db,
              $table: $db.staffBranchAccess,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> branchInventoriesRefs(
      Expression<bool> Function($$BranchInventoriesTableFilterComposer f) f) {
    final $$BranchInventoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.branchInventories,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchInventoriesTableFilterComposer(
              $db: $db,
              $table: $db.branchInventories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> invoicesRefs(
      Expression<bool> Function($$InvoicesTableFilterComposer f) f) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
      Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryMovements,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryMovementsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sourceBranchTransfers(
      Expression<bool> Function($$InventoryTransfersTableFilterComposer f) f) {
    final $$InventoryTransfersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryTransfers,
        getReferencedColumn: (t) => t.sourceBranchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryTransfersTableFilterComposer(
              $db: $db,
              $table: $db.inventoryTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> destinationBranchTransfers(
      Expression<bool> Function($$InventoryTransfersTableFilterComposer f) f) {
    final $$InventoryTransfersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryTransfers,
        getReferencedColumn: (t) => t.destinationBranchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryTransfersTableFilterComposer(
              $db: $db,
              $table: $db.inventoryTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> auditEventsRefs(
      Expression<bool> Function($$AuditEventsTableFilterComposer f) f) {
    final $$AuditEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.auditEvents,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuditEventsTableFilterComposer(
              $db: $db,
              $table: $db.auditEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> syncOutboxEventsRefs(
      Expression<bool> Function($$SyncOutboxEventsTableFilterComposer f) f) {
    final $$SyncOutboxEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.syncOutboxEvents,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncOutboxEventsTableFilterComposer(
              $db: $db,
              $table: $db.syncOutboxEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> supplierConnectorsRefs(
      Expression<bool> Function($$SupplierConnectorsTableFilterComposer f) f) {
    final $$SupplierConnectorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.supplierConnectors,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierConnectorsTableFilterComposer(
              $db: $db,
              $table: $db.supplierConnectors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> supplierDeliveryJobsRefs(
      Expression<bool> Function($$SupplierDeliveryJobsTableFilterComposer f)
          f) {
    final $$SupplierDeliveryJobsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.supplierDeliveryJobs,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierDeliveryJobsTableFilterComposer(
              $db: $db,
              $table: $db.supplierDeliveryJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BranchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BranchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchesTable> {
  $$BranchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> terminalsRefs<T extends Object>(
      Expression<T> Function($$TerminalsTableAnnotationComposer a) f) {
    final $$TerminalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.terminals,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TerminalsTableAnnotationComposer(
              $db: $db,
              $table: $db.terminals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> staffBranchAccessRefs<T extends Object>(
      Expression<T> Function($$StaffBranchAccessTableAnnotationComposer a) f) {
    final $$StaffBranchAccessTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.staffBranchAccess,
            getReferencedColumn: (t) => t.branchId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$StaffBranchAccessTableAnnotationComposer(
                  $db: $db,
                  $table: $db.staffBranchAccess,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> branchInventoriesRefs<T extends Object>(
      Expression<T> Function($$BranchInventoriesTableAnnotationComposer a) f) {
    final $$BranchInventoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.branchInventories,
            getReferencedColumn: (t) => t.branchId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BranchInventoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.branchInventories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> invoicesRefs<T extends Object>(
      Expression<T> Function($$InvoicesTableAnnotationComposer a) f) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
      Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryMovements,
            getReferencedColumn: (t) => t.branchId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryMovementsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryMovements,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> sourceBranchTransfers<T extends Object>(
      Expression<T> Function($$InventoryTransfersTableAnnotationComposer a) f) {
    final $$InventoryTransfersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryTransfers,
            getReferencedColumn: (t) => t.sourceBranchId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryTransfersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryTransfers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> destinationBranchTransfers<T extends Object>(
      Expression<T> Function($$InventoryTransfersTableAnnotationComposer a) f) {
    final $$InventoryTransfersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryTransfers,
            getReferencedColumn: (t) => t.destinationBranchId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryTransfersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryTransfers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> auditEventsRefs<T extends Object>(
      Expression<T> Function($$AuditEventsTableAnnotationComposer a) f) {
    final $$AuditEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.auditEvents,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuditEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.auditEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> syncOutboxEventsRefs<T extends Object>(
      Expression<T> Function($$SyncOutboxEventsTableAnnotationComposer a) f) {
    final $$SyncOutboxEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.syncOutboxEvents,
        getReferencedColumn: (t) => t.branchId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncOutboxEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.syncOutboxEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> supplierConnectorsRefs<T extends Object>(
      Expression<T> Function($$SupplierConnectorsTableAnnotationComposer a) f) {
    final $$SupplierConnectorsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierConnectors,
            getReferencedColumn: (t) => t.branchId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierConnectorsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierConnectors,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> supplierDeliveryJobsRefs<T extends Object>(
      Expression<T> Function($$SupplierDeliveryJobsTableAnnotationComposer a)
          f) {
    final $$SupplierDeliveryJobsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierDeliveryJobs,
            getReferencedColumn: (t) => t.branchId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierDeliveryJobsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierDeliveryJobs,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$BranchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BranchesTable,
    Branche,
    $$BranchesTableFilterComposer,
    $$BranchesTableOrderingComposer,
    $$BranchesTableAnnotationComposer,
    $$BranchesTableCreateCompanionBuilder,
    $$BranchesTableUpdateCompanionBuilder,
    (Branche, $$BranchesTableReferences),
    Branche,
    PrefetchHooks Function(
        {bool terminalsRefs,
        bool staffBranchAccessRefs,
        bool branchInventoriesRefs,
        bool invoicesRefs,
        bool inventoryMovementsRefs,
        bool sourceBranchTransfers,
        bool destinationBranchTransfers,
        bool auditEventsRefs,
        bool syncOutboxEventsRefs,
        bool supplierConnectorsRefs,
        bool supplierDeliveryJobsRefs})> {
  $$BranchesTableTableManager(_$AppDatabase db, $BranchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BranchesCompanion(
            id: id,
            code: code,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String name,
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BranchesCompanion.insert(
            id: id,
            code: code,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BranchesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {terminalsRefs = false,
              staffBranchAccessRefs = false,
              branchInventoriesRefs = false,
              invoicesRefs = false,
              inventoryMovementsRefs = false,
              sourceBranchTransfers = false,
              destinationBranchTransfers = false,
              auditEventsRefs = false,
              syncOutboxEventsRefs = false,
              supplierConnectorsRefs = false,
              supplierDeliveryJobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (terminalsRefs) db.terminals,
                if (staffBranchAccessRefs) db.staffBranchAccess,
                if (branchInventoriesRefs) db.branchInventories,
                if (invoicesRefs) db.invoices,
                if (inventoryMovementsRefs) db.inventoryMovements,
                if (sourceBranchTransfers) db.inventoryTransfers,
                if (destinationBranchTransfers) db.inventoryTransfers,
                if (auditEventsRefs) db.auditEvents,
                if (syncOutboxEventsRefs) db.syncOutboxEvents,
                if (supplierConnectorsRefs) db.supplierConnectors,
                if (supplierDeliveryJobsRefs) db.supplierDeliveryJobs
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (terminalsRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            Terminal>(
                        currentTable: table,
                        referencedTable:
                            $$BranchesTableReferences._terminalsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .terminalsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items),
                  if (staffBranchAccessRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            StaffBranchAccessData>(
                        currentTable: table,
                        referencedTable: $$BranchesTableReferences
                            ._staffBranchAccessRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .staffBranchAccessRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items),
                  if (branchInventoriesRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            BranchInventory>(
                        currentTable: table,
                        referencedTable: $$BranchesTableReferences
                            ._branchInventoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .branchInventoriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items),
                  if (invoicesRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable, Invoice>(
                        currentTable: table,
                        referencedTable:
                            $$BranchesTableReferences._invoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .invoicesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items),
                  if (inventoryMovementsRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            InventoryMovement>(
                        currentTable: table,
                        referencedTable: $$BranchesTableReferences
                            ._inventoryMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .inventoryMovementsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items),
                  if (sourceBranchTransfers)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            InventoryTransfer>(
                        currentTable: table,
                        referencedTable: $$BranchesTableReferences
                            ._sourceBranchTransfersTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .sourceBranchTransfers,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sourceBranchId == item.id),
                        typedResults: items),
                  if (destinationBranchTransfers)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            InventoryTransfer>(
                        currentTable: table,
                        referencedTable: $$BranchesTableReferences
                            ._destinationBranchTransfersTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .destinationBranchTransfers,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.destinationBranchId == item.id),
                        typedResults: items),
                  if (auditEventsRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            AuditEvent>(
                        currentTable: table,
                        referencedTable:
                            $$BranchesTableReferences._auditEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .auditEventsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items),
                  if (syncOutboxEventsRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            SyncOutboxEvent>(
                        currentTable: table,
                        referencedTable: $$BranchesTableReferences
                            ._syncOutboxEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .syncOutboxEventsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items),
                  if (supplierConnectorsRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            SupplierConnector>(
                        currentTable: table,
                        referencedTable: $$BranchesTableReferences
                            ._supplierConnectorsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .supplierConnectorsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items),
                  if (supplierDeliveryJobsRefs)
                    await $_getPrefetchedData<Branche, $BranchesTable,
                            SupplierDeliveryJob>(
                        currentTable: table,
                        referencedTable: $$BranchesTableReferences
                            ._supplierDeliveryJobsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BranchesTableReferences(db, table, p0)
                                .supplierDeliveryJobsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.branchId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BranchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BranchesTable,
    Branche,
    $$BranchesTableFilterComposer,
    $$BranchesTableOrderingComposer,
    $$BranchesTableAnnotationComposer,
    $$BranchesTableCreateCompanionBuilder,
    $$BranchesTableUpdateCompanionBuilder,
    (Branche, $$BranchesTableReferences),
    Branche,
    PrefetchHooks Function(
        {bool terminalsRefs,
        bool staffBranchAccessRefs,
        bool branchInventoriesRefs,
        bool invoicesRefs,
        bool inventoryMovementsRefs,
        bool sourceBranchTransfers,
        bool destinationBranchTransfers,
        bool auditEventsRefs,
        bool syncOutboxEventsRefs,
        bool supplierConnectorsRefs,
        bool supplierDeliveryJobsRefs})>;
typedef $$TerminalsTableCreateCompanionBuilder = TerminalsCompanion Function({
  required String id,
  required String branchId,
  required String code,
  required String machineIdentificationNumber,
  required String permitToUseNumber,
  required String machineSerialNumber,
  Value<bool> isActive,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TerminalsTableUpdateCompanionBuilder = TerminalsCompanion Function({
  Value<String> id,
  Value<String> branchId,
  Value<String> code,
  Value<String> machineIdentificationNumber,
  Value<String> permitToUseNumber,
  Value<String> machineSerialNumber,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TerminalsTableReferences
    extends BaseReferences<_$AppDatabase, $TerminalsTable, Terminal> {
  $$TerminalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BranchesTable _branchIdTable(_$AppDatabase db) => db.branches
      .createAlias($_aliasNameGenerator(db.terminals.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InvoiceSequencesTable, List<InvoiceSequence>>
      _invoiceSequencesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.invoiceSequences,
              aliasName: $_aliasNameGenerator(
                  db.terminals.id, db.invoiceSequences.terminalId));

  $$InvoiceSequencesTableProcessedTableManager get invoiceSequencesRefs {
    final manager = $$InvoiceSequencesTableTableManager(
            $_db, $_db.invoiceSequences)
        .filter((f) => f.terminalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_invoiceSequencesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.invoices,
          aliasName:
              $_aliasNameGenerator(db.terminals.id, db.invoices.terminalId));

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.terminalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TerminalsTableFilterComposer
    extends Composer<_$AppDatabase, $TerminalsTable> {
  $$TerminalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get machineIdentificationNumber => $composableBuilder(
      column: $table.machineIdentificationNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permitToUseNumber => $composableBuilder(
      column: $table.permitToUseNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get machineSerialNumber => $composableBuilder(
      column: $table.machineSerialNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> invoiceSequencesRefs(
      Expression<bool> Function($$InvoiceSequencesTableFilterComposer f) f) {
    final $$InvoiceSequencesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceSequences,
        getReferencedColumn: (t) => t.terminalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceSequencesTableFilterComposer(
              $db: $db,
              $table: $db.invoiceSequences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> invoicesRefs(
      Expression<bool> Function($$InvoicesTableFilterComposer f) f) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.terminalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TerminalsTableOrderingComposer
    extends Composer<_$AppDatabase, $TerminalsTable> {
  $$TerminalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get machineIdentificationNumber => $composableBuilder(
      column: $table.machineIdentificationNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permitToUseNumber => $composableBuilder(
      column: $table.permitToUseNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get machineSerialNumber => $composableBuilder(
      column: $table.machineSerialNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TerminalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TerminalsTable> {
  $$TerminalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get machineIdentificationNumber => $composableBuilder(
      column: $table.machineIdentificationNumber, builder: (column) => column);

  GeneratedColumn<String> get permitToUseNumber => $composableBuilder(
      column: $table.permitToUseNumber, builder: (column) => column);

  GeneratedColumn<String> get machineSerialNumber => $composableBuilder(
      column: $table.machineSerialNumber, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> invoiceSequencesRefs<T extends Object>(
      Expression<T> Function($$InvoiceSequencesTableAnnotationComposer a) f) {
    final $$InvoiceSequencesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceSequences,
        getReferencedColumn: (t) => t.terminalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceSequencesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoiceSequences,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> invoicesRefs<T extends Object>(
      Expression<T> Function($$InvoicesTableAnnotationComposer a) f) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.terminalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TerminalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TerminalsTable,
    Terminal,
    $$TerminalsTableFilterComposer,
    $$TerminalsTableOrderingComposer,
    $$TerminalsTableAnnotationComposer,
    $$TerminalsTableCreateCompanionBuilder,
    $$TerminalsTableUpdateCompanionBuilder,
    (Terminal, $$TerminalsTableReferences),
    Terminal,
    PrefetchHooks Function(
        {bool branchId, bool invoiceSequencesRefs, bool invoicesRefs})> {
  $$TerminalsTableTableManager(_$AppDatabase db, $TerminalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TerminalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TerminalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TerminalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> machineIdentificationNumber = const Value.absent(),
            Value<String> permitToUseNumber = const Value.absent(),
            Value<String> machineSerialNumber = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TerminalsCompanion(
            id: id,
            branchId: branchId,
            code: code,
            machineIdentificationNumber: machineIdentificationNumber,
            permitToUseNumber: permitToUseNumber,
            machineSerialNumber: machineSerialNumber,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String branchId,
            required String code,
            required String machineIdentificationNumber,
            required String permitToUseNumber,
            required String machineSerialNumber,
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TerminalsCompanion.insert(
            id: id,
            branchId: branchId,
            code: code,
            machineIdentificationNumber: machineIdentificationNumber,
            permitToUseNumber: permitToUseNumber,
            machineSerialNumber: machineSerialNumber,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TerminalsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {branchId = false,
              invoiceSequencesRefs = false,
              invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoiceSequencesRefs) db.invoiceSequences,
                if (invoicesRefs) db.invoices
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable:
                        $$TerminalsTableReferences._branchIdTable(db),
                    referencedColumn:
                        $$TerminalsTableReferences._branchIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceSequencesRefs)
                    await $_getPrefetchedData<Terminal, $TerminalsTable,
                            InvoiceSequence>(
                        currentTable: table,
                        referencedTable: $$TerminalsTableReferences
                            ._invoiceSequencesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TerminalsTableReferences(db, table, p0)
                                .invoiceSequencesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.terminalId == item.id),
                        typedResults: items),
                  if (invoicesRefs)
                    await $_getPrefetchedData<Terminal, $TerminalsTable,
                            Invoice>(
                        currentTable: table,
                        referencedTable:
                            $$TerminalsTableReferences._invoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TerminalsTableReferences(db, table, p0)
                                .invoicesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.terminalId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TerminalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TerminalsTable,
    Terminal,
    $$TerminalsTableFilterComposer,
    $$TerminalsTableOrderingComposer,
    $$TerminalsTableAnnotationComposer,
    $$TerminalsTableCreateCompanionBuilder,
    $$TerminalsTableUpdateCompanionBuilder,
    (Terminal, $$TerminalsTableReferences),
    Terminal,
    PrefetchHooks Function(
        {bool branchId, bool invoiceSequencesRefs, bool invoicesRefs})>;
typedef $$StaffUsersTableCreateCompanionBuilder = StaffUsersCompanion Function({
  required String id,
  required String displayName,
  required String emailNormalized,
  required String role,
  required String passwordHash,
  required String passwordSalt,
  required String passwordAlgorithm,
  required int passwordIterations,
  Value<int> failedLoginAttempts,
  Value<DateTime?> lockedUntil,
  Value<DateTime?> lastLoginAt,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$StaffUsersTableUpdateCompanionBuilder = StaffUsersCompanion Function({
  Value<String> id,
  Value<String> displayName,
  Value<String> emailNormalized,
  Value<String> role,
  Value<String> passwordHash,
  Value<String> passwordSalt,
  Value<String> passwordAlgorithm,
  Value<int> passwordIterations,
  Value<int> failedLoginAttempts,
  Value<DateTime?> lockedUntil,
  Value<DateTime?> lastLoginAt,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$StaffUsersTableReferences
    extends BaseReferences<_$AppDatabase, $StaffUsersTable, StaffUser> {
  $$StaffUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StaffBranchAccessTable,
      List<StaffBranchAccessData>> _staffBranchAccessRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.staffBranchAccess,
          aliasName: $_aliasNameGenerator(
              db.staffUsers.id, db.staffBranchAccess.staffUserId));

  $$StaffBranchAccessTableProcessedTableManager get staffBranchAccessRefs {
    final manager = $$StaffBranchAccessTableTableManager(
            $_db, $_db.staffBranchAccess)
        .filter((f) => f.staffUserId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_staffBranchAccessRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StaffUsersTableFilterComposer
    extends Composer<_$AppDatabase, $StaffUsersTable> {
  $$StaffUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailNormalized => $composableBuilder(
      column: $table.emailNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordSalt => $composableBuilder(
      column: $table.passwordSalt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordAlgorithm => $composableBuilder(
      column: $table.passwordAlgorithm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get passwordIterations => $composableBuilder(
      column: $table.passwordIterations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedLoginAttempts => $composableBuilder(
      column: $table.failedLoginAttempts,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> staffBranchAccessRefs(
      Expression<bool> Function($$StaffBranchAccessTableFilterComposer f) f) {
    final $$StaffBranchAccessTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.staffBranchAccess,
        getReferencedColumn: (t) => t.staffUserId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffBranchAccessTableFilterComposer(
              $db: $db,
              $table: $db.staffBranchAccess,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$StaffUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffUsersTable> {
  $$StaffUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailNormalized => $composableBuilder(
      column: $table.emailNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordSalt => $composableBuilder(
      column: $table.passwordSalt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordAlgorithm => $composableBuilder(
      column: $table.passwordAlgorithm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get passwordIterations => $composableBuilder(
      column: $table.passwordIterations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedLoginAttempts => $composableBuilder(
      column: $table.failedLoginAttempts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$StaffUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffUsersTable> {
  $$StaffUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get emailNormalized => $composableBuilder(
      column: $table.emailNormalized, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get passwordSalt => $composableBuilder(
      column: $table.passwordSalt, builder: (column) => column);

  GeneratedColumn<String> get passwordAlgorithm => $composableBuilder(
      column: $table.passwordAlgorithm, builder: (column) => column);

  GeneratedColumn<int> get passwordIterations => $composableBuilder(
      column: $table.passwordIterations, builder: (column) => column);

  GeneratedColumn<int> get failedLoginAttempts => $composableBuilder(
      column: $table.failedLoginAttempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> staffBranchAccessRefs<T extends Object>(
      Expression<T> Function($$StaffBranchAccessTableAnnotationComposer a) f) {
    final $$StaffBranchAccessTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.staffBranchAccess,
            getReferencedColumn: (t) => t.staffUserId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$StaffBranchAccessTableAnnotationComposer(
                  $db: $db,
                  $table: $db.staffBranchAccess,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$StaffUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffUsersTable,
    StaffUser,
    $$StaffUsersTableFilterComposer,
    $$StaffUsersTableOrderingComposer,
    $$StaffUsersTableAnnotationComposer,
    $$StaffUsersTableCreateCompanionBuilder,
    $$StaffUsersTableUpdateCompanionBuilder,
    (StaffUser, $$StaffUsersTableReferences),
    StaffUser,
    PrefetchHooks Function({bool staffBranchAccessRefs})> {
  $$StaffUsersTableTableManager(_$AppDatabase db, $StaffUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> emailNormalized = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> passwordSalt = const Value.absent(),
            Value<String> passwordAlgorithm = const Value.absent(),
            Value<int> passwordIterations = const Value.absent(),
            Value<int> failedLoginAttempts = const Value.absent(),
            Value<DateTime?> lockedUntil = const Value.absent(),
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffUsersCompanion(
            id: id,
            displayName: displayName,
            emailNormalized: emailNormalized,
            role: role,
            passwordHash: passwordHash,
            passwordSalt: passwordSalt,
            passwordAlgorithm: passwordAlgorithm,
            passwordIterations: passwordIterations,
            failedLoginAttempts: failedLoginAttempts,
            lockedUntil: lockedUntil,
            lastLoginAt: lastLoginAt,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String displayName,
            required String emailNormalized,
            required String role,
            required String passwordHash,
            required String passwordSalt,
            required String passwordAlgorithm,
            required int passwordIterations,
            Value<int> failedLoginAttempts = const Value.absent(),
            Value<DateTime?> lockedUntil = const Value.absent(),
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffUsersCompanion.insert(
            id: id,
            displayName: displayName,
            emailNormalized: emailNormalized,
            role: role,
            passwordHash: passwordHash,
            passwordSalt: passwordSalt,
            passwordAlgorithm: passwordAlgorithm,
            passwordIterations: passwordIterations,
            failedLoginAttempts: failedLoginAttempts,
            lockedUntil: lockedUntil,
            lastLoginAt: lastLoginAt,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StaffUsersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({staffBranchAccessRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (staffBranchAccessRefs) db.staffBranchAccess
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (staffBranchAccessRefs)
                    await $_getPrefetchedData<StaffUser, $StaffUsersTable,
                            StaffBranchAccessData>(
                        currentTable: table,
                        referencedTable: $$StaffUsersTableReferences
                            ._staffBranchAccessRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$StaffUsersTableReferences(db, table, p0)
                                .staffBranchAccessRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.staffUserId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$StaffUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffUsersTable,
    StaffUser,
    $$StaffUsersTableFilterComposer,
    $$StaffUsersTableOrderingComposer,
    $$StaffUsersTableAnnotationComposer,
    $$StaffUsersTableCreateCompanionBuilder,
    $$StaffUsersTableUpdateCompanionBuilder,
    (StaffUser, $$StaffUsersTableReferences),
    StaffUser,
    PrefetchHooks Function({bool staffBranchAccessRefs})>;
typedef $$StaffBranchAccessTableCreateCompanionBuilder
    = StaffBranchAccessCompanion Function({
  required String staffUserId,
  required String branchId,
  required DateTime grantedAt,
  required String grantedBy,
  Value<int> rowid,
});
typedef $$StaffBranchAccessTableUpdateCompanionBuilder
    = StaffBranchAccessCompanion Function({
  Value<String> staffUserId,
  Value<String> branchId,
  Value<DateTime> grantedAt,
  Value<String> grantedBy,
  Value<int> rowid,
});

final class $$StaffBranchAccessTableReferences extends BaseReferences<
    _$AppDatabase, $StaffBranchAccessTable, StaffBranchAccessData> {
  $$StaffBranchAccessTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $StaffUsersTable _staffUserIdTable(_$AppDatabase db) =>
      db.staffUsers.createAlias($_aliasNameGenerator(
          db.staffBranchAccess.staffUserId, db.staffUsers.id));

  $$StaffUsersTableProcessedTableManager get staffUserId {
    final $_column = $_itemColumn<String>('staff_user_id')!;

    final manager = $$StaffUsersTableTableManager($_db, $_db.staffUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_staffUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BranchesTable _branchIdTable(_$AppDatabase db) =>
      db.branches.createAlias(
          $_aliasNameGenerator(db.staffBranchAccess.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StaffBranchAccessTableFilterComposer
    extends Composer<_$AppDatabase, $StaffBranchAccessTable> {
  $$StaffBranchAccessTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get grantedAt => $composableBuilder(
      column: $table.grantedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grantedBy => $composableBuilder(
      column: $table.grantedBy, builder: (column) => ColumnFilters(column));

  $$StaffUsersTableFilterComposer get staffUserId {
    final $$StaffUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.staffUserId,
        referencedTable: $db.staffUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffUsersTableFilterComposer(
              $db: $db,
              $table: $db.staffUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StaffBranchAccessTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffBranchAccessTable> {
  $$StaffBranchAccessTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get grantedAt => $composableBuilder(
      column: $table.grantedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grantedBy => $composableBuilder(
      column: $table.grantedBy, builder: (column) => ColumnOrderings(column));

  $$StaffUsersTableOrderingComposer get staffUserId {
    final $$StaffUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.staffUserId,
        referencedTable: $db.staffUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffUsersTableOrderingComposer(
              $db: $db,
              $table: $db.staffUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StaffBranchAccessTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffBranchAccessTable> {
  $$StaffBranchAccessTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get grantedAt =>
      $composableBuilder(column: $table.grantedAt, builder: (column) => column);

  GeneratedColumn<String> get grantedBy =>
      $composableBuilder(column: $table.grantedBy, builder: (column) => column);

  $$StaffUsersTableAnnotationComposer get staffUserId {
    final $$StaffUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.staffUserId,
        referencedTable: $db.staffUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StaffUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.staffUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StaffBranchAccessTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffBranchAccessTable,
    StaffBranchAccessData,
    $$StaffBranchAccessTableFilterComposer,
    $$StaffBranchAccessTableOrderingComposer,
    $$StaffBranchAccessTableAnnotationComposer,
    $$StaffBranchAccessTableCreateCompanionBuilder,
    $$StaffBranchAccessTableUpdateCompanionBuilder,
    (StaffBranchAccessData, $$StaffBranchAccessTableReferences),
    StaffBranchAccessData,
    PrefetchHooks Function({bool staffUserId, bool branchId})> {
  $$StaffBranchAccessTableTableManager(
      _$AppDatabase db, $StaffBranchAccessTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffBranchAccessTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffBranchAccessTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffBranchAccessTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> staffUserId = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<DateTime> grantedAt = const Value.absent(),
            Value<String> grantedBy = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffBranchAccessCompanion(
            staffUserId: staffUserId,
            branchId: branchId,
            grantedAt: grantedAt,
            grantedBy: grantedBy,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String staffUserId,
            required String branchId,
            required DateTime grantedAt,
            required String grantedBy,
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffBranchAccessCompanion.insert(
            staffUserId: staffUserId,
            branchId: branchId,
            grantedAt: grantedAt,
            grantedBy: grantedBy,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StaffBranchAccessTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({staffUserId = false, branchId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (staffUserId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.staffUserId,
                    referencedTable: $$StaffBranchAccessTableReferences
                        ._staffUserIdTable(db),
                    referencedColumn: $$StaffBranchAccessTableReferences
                        ._staffUserIdTable(db)
                        .id,
                  ) as T;
                }
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable:
                        $$StaffBranchAccessTableReferences._branchIdTable(db),
                    referencedColumn: $$StaffBranchAccessTableReferences
                        ._branchIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StaffBranchAccessTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffBranchAccessTable,
    StaffBranchAccessData,
    $$StaffBranchAccessTableFilterComposer,
    $$StaffBranchAccessTableOrderingComposer,
    $$StaffBranchAccessTableAnnotationComposer,
    $$StaffBranchAccessTableCreateCompanionBuilder,
    $$StaffBranchAccessTableUpdateCompanionBuilder,
    (StaffBranchAccessData, $$StaffBranchAccessTableReferences),
    StaffBranchAccessData,
    PrefetchHooks Function({bool staffUserId, bool branchId})>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String sku,
  required String name,
  required String taxCategory,
  required int unitPriceCentavos,
  Value<String> categoryId,
  Value<int> colorArgb,
  Value<bool> isActive,
  Value<int> version,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> sku,
  Value<String> name,
  Value<String> taxCategory,
  Value<int> unitPriceCentavos,
  Value<String> categoryId,
  Value<int> colorArgb,
  Value<bool> isActive,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BranchInventoriesTable, List<BranchInventory>>
      _branchInventoriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.branchInventories,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.branchInventories.productId));

  $$BranchInventoriesTableProcessedTableManager get branchInventoriesRefs {
    final manager = $$BranchInventoriesTableTableManager(
            $_db, $_db.branchInventories)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_branchInventoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InvoiceLinesTable, List<InvoiceLine>>
      _invoiceLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.invoiceLines,
          aliasName:
              $_aliasNameGenerator(db.products.id, db.invoiceLines.productId));

  $$InvoiceLinesTableProcessedTableManager get invoiceLinesRefs {
    final manager = $$InvoiceLinesTableTableManager($_db, $_db.invoiceLines)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceLinesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryMovementsTable, List<InventoryMovement>>
      _inventoryMovementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryMovements,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.inventoryMovements.productId));

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager = $$InventoryMovementsTableTableManager(
            $_db, $_db.inventoryMovements)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_inventoryMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InventoryTransfersTable, List<InventoryTransfer>>
      _inventoryTransfersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inventoryTransfers,
              aliasName: $_aliasNameGenerator(
                  db.products.id, db.inventoryTransfers.productId));

  $$InventoryTransfersTableProcessedTableManager get inventoryTransfersRefs {
    final manager = $$InventoryTransfersTableTableManager(
            $_db, $_db.inventoryTransfers)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_inventoryTransfersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SupplierProductSubscriptionsTable,
      List<SupplierProductSubscription>> _supplierProductSubscriptionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.supplierProductSubscriptions,
          aliasName: $_aliasNameGenerator(
              db.products.id, db.supplierProductSubscriptions.productId));

  $$SupplierProductSubscriptionsTableProcessedTableManager
      get supplierProductSubscriptionsRefs {
    final manager = $$SupplierProductSubscriptionsTableTableManager(
            $_db, $_db.supplierProductSubscriptions)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_supplierProductSubscriptionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SupplierDeliveryJobsTable,
      List<SupplierDeliveryJob>> _supplierDeliveryJobsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.supplierDeliveryJobs,
          aliasName: $_aliasNameGenerator(
              db.products.id, db.supplierDeliveryJobs.productId));

  $$SupplierDeliveryJobsTableProcessedTableManager
      get supplierDeliveryJobsRefs {
    final manager = $$SupplierDeliveryJobsTableTableManager(
            $_db, $_db.supplierDeliveryJobs)
        .filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_supplierDeliveryJobsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxCategory => $composableBuilder(
      column: $table.taxCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceCentavos => $composableBuilder(
      column: $table.unitPriceCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorArgb => $composableBuilder(
      column: $table.colorArgb, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> branchInventoriesRefs(
      Expression<bool> Function($$BranchInventoriesTableFilterComposer f) f) {
    final $$BranchInventoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.branchInventories,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchInventoriesTableFilterComposer(
              $db: $db,
              $table: $db.branchInventories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> invoiceLinesRefs(
      Expression<bool> Function($$InvoiceLinesTableFilterComposer f) f) {
    final $$InvoiceLinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceLines,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceLinesTableFilterComposer(
              $db: $db,
              $table: $db.invoiceLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
      Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryMovements,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryMovementsTableFilterComposer(
              $db: $db,
              $table: $db.inventoryMovements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inventoryTransfersRefs(
      Expression<bool> Function($$InventoryTransfersTableFilterComposer f) f) {
    final $$InventoryTransfersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inventoryTransfers,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InventoryTransfersTableFilterComposer(
              $db: $db,
              $table: $db.inventoryTransfers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> supplierProductSubscriptionsRefs(
      Expression<bool> Function(
              $$SupplierProductSubscriptionsTableFilterComposer f)
          f) {
    final $$SupplierProductSubscriptionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierProductSubscriptions,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierProductSubscriptionsTableFilterComposer(
                  $db: $db,
                  $table: $db.supplierProductSubscriptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> supplierDeliveryJobsRefs(
      Expression<bool> Function($$SupplierDeliveryJobsTableFilterComposer f)
          f) {
    final $$SupplierDeliveryJobsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.supplierDeliveryJobs,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierDeliveryJobsTableFilterComposer(
              $db: $db,
              $table: $db.supplierDeliveryJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxCategory => $composableBuilder(
      column: $table.taxCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPriceCentavos => $composableBuilder(
      column: $table.unitPriceCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorArgb => $composableBuilder(
      column: $table.colorArgb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get taxCategory => $composableBuilder(
      column: $table.taxCategory, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCentavos => $composableBuilder(
      column: $table.unitPriceCentavos, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> branchInventoriesRefs<T extends Object>(
      Expression<T> Function($$BranchInventoriesTableAnnotationComposer a) f) {
    final $$BranchInventoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.branchInventories,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BranchInventoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.branchInventories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> invoiceLinesRefs<T extends Object>(
      Expression<T> Function($$InvoiceLinesTableAnnotationComposer a) f) {
    final $$InvoiceLinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceLines,
        getReferencedColumn: (t) => t.productId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceLinesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoiceLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
      Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryMovements,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryMovementsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryMovements,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> inventoryTransfersRefs<T extends Object>(
      Expression<T> Function($$InventoryTransfersTableAnnotationComposer a) f) {
    final $$InventoryTransfersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.inventoryTransfers,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InventoryTransfersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.inventoryTransfers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> supplierProductSubscriptionsRefs<T extends Object>(
      Expression<T> Function(
              $$SupplierProductSubscriptionsTableAnnotationComposer a)
          f) {
    final $$SupplierProductSubscriptionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierProductSubscriptions,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierProductSubscriptionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierProductSubscriptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> supplierDeliveryJobsRefs<T extends Object>(
      Expression<T> Function($$SupplierDeliveryJobsTableAnnotationComposer a)
          f) {
    final $$SupplierDeliveryJobsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierDeliveryJobs,
            getReferencedColumn: (t) => t.productId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierDeliveryJobsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierDeliveryJobs,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool branchInventoriesRefs,
        bool invoiceLinesRefs,
        bool inventoryMovementsRefs,
        bool inventoryTransfersRefs,
        bool supplierProductSubscriptionsRefs,
        bool supplierDeliveryJobsRefs})> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> taxCategory = const Value.absent(),
            Value<int> unitPriceCentavos = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<int> colorArgb = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            sku: sku,
            name: name,
            taxCategory: taxCategory,
            unitPriceCentavos: unitPriceCentavos,
            categoryId: categoryId,
            colorArgb: colorArgb,
            isActive: isActive,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sku,
            required String name,
            required String taxCategory,
            required int unitPriceCentavos,
            Value<String> categoryId = const Value.absent(),
            Value<int> colorArgb = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> version = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            sku: sku,
            name: name,
            taxCategory: taxCategory,
            unitPriceCentavos: unitPriceCentavos,
            categoryId: categoryId,
            colorArgb: colorArgb,
            isActive: isActive,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProductsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {branchInventoriesRefs = false,
              invoiceLinesRefs = false,
              inventoryMovementsRefs = false,
              inventoryTransfersRefs = false,
              supplierProductSubscriptionsRefs = false,
              supplierDeliveryJobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (branchInventoriesRefs) db.branchInventories,
                if (invoiceLinesRefs) db.invoiceLines,
                if (inventoryMovementsRefs) db.inventoryMovements,
                if (inventoryTransfersRefs) db.inventoryTransfers,
                if (supplierProductSubscriptionsRefs)
                  db.supplierProductSubscriptions,
                if (supplierDeliveryJobsRefs) db.supplierDeliveryJobs
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (branchInventoriesRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            BranchInventory>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._branchInventoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .branchInventoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (invoiceLinesRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            InvoiceLine>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._invoiceLinesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .invoiceLinesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (inventoryMovementsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            InventoryMovement>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._inventoryMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .inventoryMovementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (inventoryTransfersRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            InventoryTransfer>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._inventoryTransfersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .inventoryTransfersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (supplierProductSubscriptionsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            SupplierProductSubscription>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._supplierProductSubscriptionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .supplierProductSubscriptionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items),
                  if (supplierDeliveryJobsRefs)
                    await $_getPrefetchedData<Product, $ProductsTable,
                            SupplierDeliveryJob>(
                        currentTable: table,
                        referencedTable: $$ProductsTableReferences
                            ._supplierDeliveryJobsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductsTableReferences(db, table, p0)
                                .supplierDeliveryJobsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, $$ProductsTableReferences),
    Product,
    PrefetchHooks Function(
        {bool branchInventoriesRefs,
        bool invoiceLinesRefs,
        bool inventoryMovementsRefs,
        bool inventoryTransfersRefs,
        bool supplierProductSubscriptionsRefs,
        bool supplierDeliveryJobsRefs})>;
typedef $$BranchInventoriesTableCreateCompanionBuilder
    = BranchInventoriesCompanion Function({
  required String branchId,
  required String productId,
  Value<int> stockOnHand,
  Value<int> reorderPoint,
  Value<int> version,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$BranchInventoriesTableUpdateCompanionBuilder
    = BranchInventoriesCompanion Function({
  Value<String> branchId,
  Value<String> productId,
  Value<int> stockOnHand,
  Value<int> reorderPoint,
  Value<int> version,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$BranchInventoriesTableReferences extends BaseReferences<
    _$AppDatabase, $BranchInventoriesTable, BranchInventory> {
  $$BranchInventoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BranchesTable _branchIdTable(_$AppDatabase db) =>
      db.branches.createAlias(
          $_aliasNameGenerator(db.branchInventories.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.branchInventories.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BranchInventoriesTableFilterComposer
    extends Composer<_$AppDatabase, $BranchInventoriesTable> {
  $$BranchInventoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get stockOnHand => $composableBuilder(
      column: $table.stockOnHand, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reorderPoint => $composableBuilder(
      column: $table.reorderPoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BranchInventoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BranchInventoriesTable> {
  $$BranchInventoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get stockOnHand => $composableBuilder(
      column: $table.stockOnHand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reorderPoint => $composableBuilder(
      column: $table.reorderPoint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BranchInventoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BranchInventoriesTable> {
  $$BranchInventoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get stockOnHand => $composableBuilder(
      column: $table.stockOnHand, builder: (column) => column);

  GeneratedColumn<int> get reorderPoint => $composableBuilder(
      column: $table.reorderPoint, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BranchInventoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BranchInventoriesTable,
    BranchInventory,
    $$BranchInventoriesTableFilterComposer,
    $$BranchInventoriesTableOrderingComposer,
    $$BranchInventoriesTableAnnotationComposer,
    $$BranchInventoriesTableCreateCompanionBuilder,
    $$BranchInventoriesTableUpdateCompanionBuilder,
    (BranchInventory, $$BranchInventoriesTableReferences),
    BranchInventory,
    PrefetchHooks Function({bool branchId, bool productId})> {
  $$BranchInventoriesTableTableManager(
      _$AppDatabase db, $BranchInventoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchInventoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchInventoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchInventoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> branchId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<int> stockOnHand = const Value.absent(),
            Value<int> reorderPoint = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BranchInventoriesCompanion(
            branchId: branchId,
            productId: productId,
            stockOnHand: stockOnHand,
            reorderPoint: reorderPoint,
            version: version,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String branchId,
            required String productId,
            Value<int> stockOnHand = const Value.absent(),
            Value<int> reorderPoint = const Value.absent(),
            Value<int> version = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BranchInventoriesCompanion.insert(
            branchId: branchId,
            productId: productId,
            stockOnHand: stockOnHand,
            reorderPoint: reorderPoint,
            version: version,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BranchInventoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({branchId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable:
                        $$BranchInventoriesTableReferences._branchIdTable(db),
                    referencedColumn: $$BranchInventoriesTableReferences
                        ._branchIdTable(db)
                        .id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$BranchInventoriesTableReferences._productIdTable(db),
                    referencedColumn: $$BranchInventoriesTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BranchInventoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BranchInventoriesTable,
    BranchInventory,
    $$BranchInventoriesTableFilterComposer,
    $$BranchInventoriesTableOrderingComposer,
    $$BranchInventoriesTableAnnotationComposer,
    $$BranchInventoriesTableCreateCompanionBuilder,
    $$BranchInventoriesTableUpdateCompanionBuilder,
    (BranchInventory, $$BranchInventoriesTableReferences),
    BranchInventory,
    PrefetchHooks Function({bool branchId, bool productId})>;
typedef $$InvoiceSequencesTableCreateCompanionBuilder
    = InvoiceSequencesCompanion Function({
  required String terminalId,
  required int nextValue,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$InvoiceSequencesTableUpdateCompanionBuilder
    = InvoiceSequencesCompanion Function({
  Value<String> terminalId,
  Value<int> nextValue,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$InvoiceSequencesTableReferences extends BaseReferences<
    _$AppDatabase, $InvoiceSequencesTable, InvoiceSequence> {
  $$InvoiceSequencesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TerminalsTable _terminalIdTable(_$AppDatabase db) =>
      db.terminals.createAlias($_aliasNameGenerator(
          db.invoiceSequences.terminalId, db.terminals.id));

  $$TerminalsTableProcessedTableManager get terminalId {
    final $_column = $_itemColumn<String>('terminal_id')!;

    final manager = $$TerminalsTableTableManager($_db, $_db.terminals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_terminalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InvoiceSequencesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceSequencesTable> {
  $$InvoiceSequencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get nextValue => $composableBuilder(
      column: $table.nextValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TerminalsTableFilterComposer get terminalId {
    final $$TerminalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.terminalId,
        referencedTable: $db.terminals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TerminalsTableFilterComposer(
              $db: $db,
              $table: $db.terminals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceSequencesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceSequencesTable> {
  $$InvoiceSequencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get nextValue => $composableBuilder(
      column: $table.nextValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TerminalsTableOrderingComposer get terminalId {
    final $$TerminalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.terminalId,
        referencedTable: $db.terminals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TerminalsTableOrderingComposer(
              $db: $db,
              $table: $db.terminals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceSequencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceSequencesTable> {
  $$InvoiceSequencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get nextValue =>
      $composableBuilder(column: $table.nextValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TerminalsTableAnnotationComposer get terminalId {
    final $$TerminalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.terminalId,
        referencedTable: $db.terminals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TerminalsTableAnnotationComposer(
              $db: $db,
              $table: $db.terminals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceSequencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceSequencesTable,
    InvoiceSequence,
    $$InvoiceSequencesTableFilterComposer,
    $$InvoiceSequencesTableOrderingComposer,
    $$InvoiceSequencesTableAnnotationComposer,
    $$InvoiceSequencesTableCreateCompanionBuilder,
    $$InvoiceSequencesTableUpdateCompanionBuilder,
    (InvoiceSequence, $$InvoiceSequencesTableReferences),
    InvoiceSequence,
    PrefetchHooks Function({bool terminalId})> {
  $$InvoiceSequencesTableTableManager(
      _$AppDatabase db, $InvoiceSequencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceSequencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceSequencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceSequencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> terminalId = const Value.absent(),
            Value<int> nextValue = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceSequencesCompanion(
            terminalId: terminalId,
            nextValue: nextValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String terminalId,
            required int nextValue,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceSequencesCompanion.insert(
            terminalId: terminalId,
            nextValue: nextValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InvoiceSequencesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({terminalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (terminalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.terminalId,
                    referencedTable:
                        $$InvoiceSequencesTableReferences._terminalIdTable(db),
                    referencedColumn: $$InvoiceSequencesTableReferences
                        ._terminalIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InvoiceSequencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceSequencesTable,
    InvoiceSequence,
    $$InvoiceSequencesTableFilterComposer,
    $$InvoiceSequencesTableOrderingComposer,
    $$InvoiceSequencesTableAnnotationComposer,
    $$InvoiceSequencesTableCreateCompanionBuilder,
    $$InvoiceSequencesTableUpdateCompanionBuilder,
    (InvoiceSequence, $$InvoiceSequencesTableReferences),
    InvoiceSequence,
    PrefetchHooks Function({bool terminalId})>;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  required String id,
  required String invoiceNumber,
  required String branchId,
  required String terminalId,
  required DateTime issuedAt,
  required String status,
  required String paymentMethod,
  required String paymentReference,
  required int totalCentavos,
  required int vatableSalesCentavos,
  required int vatAmountCentavos,
  required int zeroRatedSalesCentavos,
  required int vatExemptSalesCentavos,
  required int nonVatSalesCentavos,
  required String sellerName,
  required String sellerTin,
  required String sellerAddress,
  required String sellerRegistrationType,
  required String branchCode,
  required String machineIdentificationNumber,
  required String permitToUseNumber,
  required String machineSerialNumber,
  required String softwareName,
  required String softwareVersion,
  Value<String?> buyerName,
  Value<String?> buyerTin,
  Value<String?> buyerAddress,
  Value<DateTime?> voidedAt,
  Value<String?> voidReason,
  Value<String?> originalInvoiceId,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<String> id,
  Value<String> invoiceNumber,
  Value<String> branchId,
  Value<String> terminalId,
  Value<DateTime> issuedAt,
  Value<String> status,
  Value<String> paymentMethod,
  Value<String> paymentReference,
  Value<int> totalCentavos,
  Value<int> vatableSalesCentavos,
  Value<int> vatAmountCentavos,
  Value<int> zeroRatedSalesCentavos,
  Value<int> vatExemptSalesCentavos,
  Value<int> nonVatSalesCentavos,
  Value<String> sellerName,
  Value<String> sellerTin,
  Value<String> sellerAddress,
  Value<String> sellerRegistrationType,
  Value<String> branchCode,
  Value<String> machineIdentificationNumber,
  Value<String> permitToUseNumber,
  Value<String> machineSerialNumber,
  Value<String> softwareName,
  Value<String> softwareVersion,
  Value<String?> buyerName,
  Value<String?> buyerTin,
  Value<String?> buyerAddress,
  Value<DateTime?> voidedAt,
  Value<String?> voidReason,
  Value<String?> originalInvoiceId,
  Value<bool> synced,
  Value<int> rowid,
});

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BranchesTable _branchIdTable(_$AppDatabase db) => db.branches
      .createAlias($_aliasNameGenerator(db.invoices.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TerminalsTable _terminalIdTable(_$AppDatabase db) =>
      db.terminals.createAlias(
          $_aliasNameGenerator(db.invoices.terminalId, db.terminals.id));

  $$TerminalsTableProcessedTableManager get terminalId {
    final $_column = $_itemColumn<String>('terminal_id')!;

    final manager = $$TerminalsTableTableManager($_db, $_db.terminals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_terminalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InvoiceLinesTable, List<InvoiceLine>>
      _invoiceLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.invoiceLines,
          aliasName:
              $_aliasNameGenerator(db.invoices.id, db.invoiceLines.invoiceId));

  $$InvoiceLinesTableProcessedTableManager get invoiceLinesRefs {
    final manager = $$InvoiceLinesTableTableManager($_db, $_db.invoiceLines)
        .filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceLinesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments,
          aliasName:
              $_aliasNameGenerator(db.invoices.id, db.payments.invoiceId));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$HardwareJobsTable, List<HardwareJob>>
      _hardwareJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.hardwareJobs,
          aliasName:
              $_aliasNameGenerator(db.invoices.id, db.hardwareJobs.invoiceId));

  $$HardwareJobsTableProcessedTableManager get hardwareJobsRefs {
    final manager = $$HardwareJobsTableTableManager($_db, $_db.hardwareJobs)
        .filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_hardwareJobsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
      column: $table.issuedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentReference => $composableBuilder(
      column: $table.paymentReference,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCentavos => $composableBuilder(
      column: $table.totalCentavos, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vatableSalesCentavos => $composableBuilder(
      column: $table.vatableSalesCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vatAmountCentavos => $composableBuilder(
      column: $table.vatAmountCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get zeroRatedSalesCentavos => $composableBuilder(
      column: $table.zeroRatedSalesCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vatExemptSalesCentavos => $composableBuilder(
      column: $table.vatExemptSalesCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nonVatSalesCentavos => $composableBuilder(
      column: $table.nonVatSalesCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sellerName => $composableBuilder(
      column: $table.sellerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sellerTin => $composableBuilder(
      column: $table.sellerTin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sellerAddress => $composableBuilder(
      column: $table.sellerAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sellerRegistrationType => $composableBuilder(
      column: $table.sellerRegistrationType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchCode => $composableBuilder(
      column: $table.branchCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get machineIdentificationNumber => $composableBuilder(
      column: $table.machineIdentificationNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get permitToUseNumber => $composableBuilder(
      column: $table.permitToUseNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get machineSerialNumber => $composableBuilder(
      column: $table.machineSerialNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get softwareName => $composableBuilder(
      column: $table.softwareName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get softwareVersion => $composableBuilder(
      column: $table.softwareVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buyerName => $composableBuilder(
      column: $table.buyerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buyerTin => $composableBuilder(
      column: $table.buyerTin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buyerAddress => $composableBuilder(
      column: $table.buyerAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
      column: $table.voidedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voidReason => $composableBuilder(
      column: $table.voidReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalInvoiceId => $composableBuilder(
      column: $table.originalInvoiceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TerminalsTableFilterComposer get terminalId {
    final $$TerminalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.terminalId,
        referencedTable: $db.terminals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TerminalsTableFilterComposer(
              $db: $db,
              $table: $db.terminals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> invoiceLinesRefs(
      Expression<bool> Function($$InvoiceLinesTableFilterComposer f) f) {
    final $$InvoiceLinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceLines,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceLinesTableFilterComposer(
              $db: $db,
              $table: $db.invoiceLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> hardwareJobsRefs(
      Expression<bool> Function($$HardwareJobsTableFilterComposer f) f) {
    final $$HardwareJobsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.hardwareJobs,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HardwareJobsTableFilterComposer(
              $db: $db,
              $table: $db.hardwareJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
      column: $table.issuedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentReference => $composableBuilder(
      column: $table.paymentReference,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCentavos => $composableBuilder(
      column: $table.totalCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vatableSalesCentavos => $composableBuilder(
      column: $table.vatableSalesCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vatAmountCentavos => $composableBuilder(
      column: $table.vatAmountCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get zeroRatedSalesCentavos => $composableBuilder(
      column: $table.zeroRatedSalesCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vatExemptSalesCentavos => $composableBuilder(
      column: $table.vatExemptSalesCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nonVatSalesCentavos => $composableBuilder(
      column: $table.nonVatSalesCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sellerName => $composableBuilder(
      column: $table.sellerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sellerTin => $composableBuilder(
      column: $table.sellerTin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sellerAddress => $composableBuilder(
      column: $table.sellerAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sellerRegistrationType => $composableBuilder(
      column: $table.sellerRegistrationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchCode => $composableBuilder(
      column: $table.branchCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get machineIdentificationNumber => $composableBuilder(
      column: $table.machineIdentificationNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get permitToUseNumber => $composableBuilder(
      column: $table.permitToUseNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get machineSerialNumber => $composableBuilder(
      column: $table.machineSerialNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get softwareName => $composableBuilder(
      column: $table.softwareName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get softwareVersion => $composableBuilder(
      column: $table.softwareVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buyerName => $composableBuilder(
      column: $table.buyerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buyerTin => $composableBuilder(
      column: $table.buyerTin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buyerAddress => $composableBuilder(
      column: $table.buyerAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
      column: $table.voidedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voidReason => $composableBuilder(
      column: $table.voidReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalInvoiceId => $composableBuilder(
      column: $table.originalInvoiceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TerminalsTableOrderingComposer get terminalId {
    final $$TerminalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.terminalId,
        referencedTable: $db.terminals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TerminalsTableOrderingComposer(
              $db: $db,
              $table: $db.terminals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get paymentReference => $composableBuilder(
      column: $table.paymentReference, builder: (column) => column);

  GeneratedColumn<int> get totalCentavos => $composableBuilder(
      column: $table.totalCentavos, builder: (column) => column);

  GeneratedColumn<int> get vatableSalesCentavos => $composableBuilder(
      column: $table.vatableSalesCentavos, builder: (column) => column);

  GeneratedColumn<int> get vatAmountCentavos => $composableBuilder(
      column: $table.vatAmountCentavos, builder: (column) => column);

  GeneratedColumn<int> get zeroRatedSalesCentavos => $composableBuilder(
      column: $table.zeroRatedSalesCentavos, builder: (column) => column);

  GeneratedColumn<int> get vatExemptSalesCentavos => $composableBuilder(
      column: $table.vatExemptSalesCentavos, builder: (column) => column);

  GeneratedColumn<int> get nonVatSalesCentavos => $composableBuilder(
      column: $table.nonVatSalesCentavos, builder: (column) => column);

  GeneratedColumn<String> get sellerName => $composableBuilder(
      column: $table.sellerName, builder: (column) => column);

  GeneratedColumn<String> get sellerTin =>
      $composableBuilder(column: $table.sellerTin, builder: (column) => column);

  GeneratedColumn<String> get sellerAddress => $composableBuilder(
      column: $table.sellerAddress, builder: (column) => column);

  GeneratedColumn<String> get sellerRegistrationType => $composableBuilder(
      column: $table.sellerRegistrationType, builder: (column) => column);

  GeneratedColumn<String> get branchCode => $composableBuilder(
      column: $table.branchCode, builder: (column) => column);

  GeneratedColumn<String> get machineIdentificationNumber => $composableBuilder(
      column: $table.machineIdentificationNumber, builder: (column) => column);

  GeneratedColumn<String> get permitToUseNumber => $composableBuilder(
      column: $table.permitToUseNumber, builder: (column) => column);

  GeneratedColumn<String> get machineSerialNumber => $composableBuilder(
      column: $table.machineSerialNumber, builder: (column) => column);

  GeneratedColumn<String> get softwareName => $composableBuilder(
      column: $table.softwareName, builder: (column) => column);

  GeneratedColumn<String> get softwareVersion => $composableBuilder(
      column: $table.softwareVersion, builder: (column) => column);

  GeneratedColumn<String> get buyerName =>
      $composableBuilder(column: $table.buyerName, builder: (column) => column);

  GeneratedColumn<String> get buyerTin =>
      $composableBuilder(column: $table.buyerTin, builder: (column) => column);

  GeneratedColumn<String> get buyerAddress => $composableBuilder(
      column: $table.buyerAddress, builder: (column) => column);

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
      column: $table.voidReason, builder: (column) => column);

  GeneratedColumn<String> get originalInvoiceId => $composableBuilder(
      column: $table.originalInvoiceId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TerminalsTableAnnotationComposer get terminalId {
    final $$TerminalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.terminalId,
        referencedTable: $db.terminals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TerminalsTableAnnotationComposer(
              $db: $db,
              $table: $db.terminals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> invoiceLinesRefs<T extends Object>(
      Expression<T> Function($$InvoiceLinesTableAnnotationComposer a) f) {
    final $$InvoiceLinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceLines,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceLinesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoiceLines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> hardwareJobsRefs<T extends Object>(
      Expression<T> Function($$HardwareJobsTableAnnotationComposer a) f) {
    final $$HardwareJobsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.hardwareJobs,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HardwareJobsTableAnnotationComposer(
              $db: $db,
              $table: $db.hardwareJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, $$InvoicesTableReferences),
    Invoice,
    PrefetchHooks Function(
        {bool branchId,
        bool terminalId,
        bool invoiceLinesRefs,
        bool paymentsRefs,
        bool hardwareJobsRefs})> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<String> terminalId = const Value.absent(),
            Value<DateTime> issuedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> paymentReference = const Value.absent(),
            Value<int> totalCentavos = const Value.absent(),
            Value<int> vatableSalesCentavos = const Value.absent(),
            Value<int> vatAmountCentavos = const Value.absent(),
            Value<int> zeroRatedSalesCentavos = const Value.absent(),
            Value<int> vatExemptSalesCentavos = const Value.absent(),
            Value<int> nonVatSalesCentavos = const Value.absent(),
            Value<String> sellerName = const Value.absent(),
            Value<String> sellerTin = const Value.absent(),
            Value<String> sellerAddress = const Value.absent(),
            Value<String> sellerRegistrationType = const Value.absent(),
            Value<String> branchCode = const Value.absent(),
            Value<String> machineIdentificationNumber = const Value.absent(),
            Value<String> permitToUseNumber = const Value.absent(),
            Value<String> machineSerialNumber = const Value.absent(),
            Value<String> softwareName = const Value.absent(),
            Value<String> softwareVersion = const Value.absent(),
            Value<String?> buyerName = const Value.absent(),
            Value<String?> buyerTin = const Value.absent(),
            Value<String?> buyerAddress = const Value.absent(),
            Value<DateTime?> voidedAt = const Value.absent(),
            Value<String?> voidReason = const Value.absent(),
            Value<String?> originalInvoiceId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            invoiceNumber: invoiceNumber,
            branchId: branchId,
            terminalId: terminalId,
            issuedAt: issuedAt,
            status: status,
            paymentMethod: paymentMethod,
            paymentReference: paymentReference,
            totalCentavos: totalCentavos,
            vatableSalesCentavos: vatableSalesCentavos,
            vatAmountCentavos: vatAmountCentavos,
            zeroRatedSalesCentavos: zeroRatedSalesCentavos,
            vatExemptSalesCentavos: vatExemptSalesCentavos,
            nonVatSalesCentavos: nonVatSalesCentavos,
            sellerName: sellerName,
            sellerTin: sellerTin,
            sellerAddress: sellerAddress,
            sellerRegistrationType: sellerRegistrationType,
            branchCode: branchCode,
            machineIdentificationNumber: machineIdentificationNumber,
            permitToUseNumber: permitToUseNumber,
            machineSerialNumber: machineSerialNumber,
            softwareName: softwareName,
            softwareVersion: softwareVersion,
            buyerName: buyerName,
            buyerTin: buyerTin,
            buyerAddress: buyerAddress,
            voidedAt: voidedAt,
            voidReason: voidReason,
            originalInvoiceId: originalInvoiceId,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceNumber,
            required String branchId,
            required String terminalId,
            required DateTime issuedAt,
            required String status,
            required String paymentMethod,
            required String paymentReference,
            required int totalCentavos,
            required int vatableSalesCentavos,
            required int vatAmountCentavos,
            required int zeroRatedSalesCentavos,
            required int vatExemptSalesCentavos,
            required int nonVatSalesCentavos,
            required String sellerName,
            required String sellerTin,
            required String sellerAddress,
            required String sellerRegistrationType,
            required String branchCode,
            required String machineIdentificationNumber,
            required String permitToUseNumber,
            required String machineSerialNumber,
            required String softwareName,
            required String softwareVersion,
            Value<String?> buyerName = const Value.absent(),
            Value<String?> buyerTin = const Value.absent(),
            Value<String?> buyerAddress = const Value.absent(),
            Value<DateTime?> voidedAt = const Value.absent(),
            Value<String?> voidReason = const Value.absent(),
            Value<String?> originalInvoiceId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            invoiceNumber: invoiceNumber,
            branchId: branchId,
            terminalId: terminalId,
            issuedAt: issuedAt,
            status: status,
            paymentMethod: paymentMethod,
            paymentReference: paymentReference,
            totalCentavos: totalCentavos,
            vatableSalesCentavos: vatableSalesCentavos,
            vatAmountCentavos: vatAmountCentavos,
            zeroRatedSalesCentavos: zeroRatedSalesCentavos,
            vatExemptSalesCentavos: vatExemptSalesCentavos,
            nonVatSalesCentavos: nonVatSalesCentavos,
            sellerName: sellerName,
            sellerTin: sellerTin,
            sellerAddress: sellerAddress,
            sellerRegistrationType: sellerRegistrationType,
            branchCode: branchCode,
            machineIdentificationNumber: machineIdentificationNumber,
            permitToUseNumber: permitToUseNumber,
            machineSerialNumber: machineSerialNumber,
            softwareName: softwareName,
            softwareVersion: softwareVersion,
            buyerName: buyerName,
            buyerTin: buyerTin,
            buyerAddress: buyerAddress,
            voidedAt: voidedAt,
            voidReason: voidReason,
            originalInvoiceId: originalInvoiceId,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$InvoicesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {branchId = false,
              terminalId = false,
              invoiceLinesRefs = false,
              paymentsRefs = false,
              hardwareJobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoiceLinesRefs) db.invoiceLines,
                if (paymentsRefs) db.payments,
                if (hardwareJobsRefs) db.hardwareJobs
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable:
                        $$InvoicesTableReferences._branchIdTable(db),
                    referencedColumn:
                        $$InvoicesTableReferences._branchIdTable(db).id,
                  ) as T;
                }
                if (terminalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.terminalId,
                    referencedTable:
                        $$InvoicesTableReferences._terminalIdTable(db),
                    referencedColumn:
                        $$InvoicesTableReferences._terminalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceLinesRefs)
                    await $_getPrefetchedData<Invoice, $InvoicesTable,
                            InvoiceLine>(
                        currentTable: table,
                        referencedTable: $$InvoicesTableReferences
                            ._invoiceLinesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvoicesTableReferences(db, table, p0)
                                .invoiceLinesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.invoiceId == item.id),
                        typedResults: items),
                  if (paymentsRefs)
                    await $_getPrefetchedData<Invoice, $InvoicesTable, Payment>(
                        currentTable: table,
                        referencedTable:
                            $$InvoicesTableReferences._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvoicesTableReferences(db, table, p0)
                                .paymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.invoiceId == item.id),
                        typedResults: items),
                  if (hardwareJobsRefs)
                    await $_getPrefetchedData<Invoice, $InvoicesTable,
                            HardwareJob>(
                        currentTable: table,
                        referencedTable: $$InvoicesTableReferences
                            ._hardwareJobsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvoicesTableReferences(db, table, p0)
                                .hardwareJobsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.invoiceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InvoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, $$InvoicesTableReferences),
    Invoice,
    PrefetchHooks Function(
        {bool branchId,
        bool terminalId,
        bool invoiceLinesRefs,
        bool paymentsRefs,
        bool hardwareJobsRefs})>;
typedef $$InvoiceLinesTableCreateCompanionBuilder = InvoiceLinesCompanion
    Function({
  required String id,
  required String invoiceId,
  required String productId,
  required String description,
  required int quantity,
  required int unitPriceCentavos,
  required int discountCentavos,
  required String taxCategory,
  required int lineTotalCentavos,
  Value<int> rowid,
});
typedef $$InvoiceLinesTableUpdateCompanionBuilder = InvoiceLinesCompanion
    Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<String> productId,
  Value<String> description,
  Value<int> quantity,
  Value<int> unitPriceCentavos,
  Value<int> discountCentavos,
  Value<String> taxCategory,
  Value<int> lineTotalCentavos,
  Value<int> rowid,
});

final class $$InvoiceLinesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceLinesTable, InvoiceLine> {
  $$InvoiceLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias(
          $_aliasNameGenerator(db.invoiceLines.invoiceId, db.invoices.id));

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
          $_aliasNameGenerator(db.invoiceLines.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InvoiceLinesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceCentavos => $composableBuilder(
      column: $table.unitPriceCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discountCentavos => $composableBuilder(
      column: $table.discountCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxCategory => $composableBuilder(
      column: $table.taxCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineTotalCentavos => $composableBuilder(
      column: $table.lineTotalCentavos,
      builder: (column) => ColumnFilters(column));

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPriceCentavos => $composableBuilder(
      column: $table.unitPriceCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discountCentavos => $composableBuilder(
      column: $table.discountCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxCategory => $composableBuilder(
      column: $table.taxCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineTotalCentavos => $composableBuilder(
      column: $table.lineTotalCentavos,
      builder: (column) => ColumnOrderings(column));

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableOrderingComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCentavos => $composableBuilder(
      column: $table.unitPriceCentavos, builder: (column) => column);

  GeneratedColumn<int> get discountCentavos => $composableBuilder(
      column: $table.discountCentavos, builder: (column) => column);

  GeneratedColumn<String> get taxCategory => $composableBuilder(
      column: $table.taxCategory, builder: (column) => column);

  GeneratedColumn<int> get lineTotalCentavos => $composableBuilder(
      column: $table.lineTotalCentavos, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceLinesTable,
    InvoiceLine,
    $$InvoiceLinesTableFilterComposer,
    $$InvoiceLinesTableOrderingComposer,
    $$InvoiceLinesTableAnnotationComposer,
    $$InvoiceLinesTableCreateCompanionBuilder,
    $$InvoiceLinesTableUpdateCompanionBuilder,
    (InvoiceLine, $$InvoiceLinesTableReferences),
    InvoiceLine,
    PrefetchHooks Function({bool invoiceId, bool productId})> {
  $$InvoiceLinesTableTableManager(_$AppDatabase db, $InvoiceLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> unitPriceCentavos = const Value.absent(),
            Value<int> discountCentavos = const Value.absent(),
            Value<String> taxCategory = const Value.absent(),
            Value<int> lineTotalCentavos = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceLinesCompanion(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            description: description,
            quantity: quantity,
            unitPriceCentavos: unitPriceCentavos,
            discountCentavos: discountCentavos,
            taxCategory: taxCategory,
            lineTotalCentavos: lineTotalCentavos,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required String productId,
            required String description,
            required int quantity,
            required int unitPriceCentavos,
            required int discountCentavos,
            required String taxCategory,
            required int lineTotalCentavos,
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceLinesCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            productId: productId,
            description: description,
            quantity: quantity,
            unitPriceCentavos: unitPriceCentavos,
            discountCentavos: discountCentavos,
            taxCategory: taxCategory,
            lineTotalCentavos: lineTotalCentavos,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InvoiceLinesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({invoiceId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (invoiceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.invoiceId,
                    referencedTable:
                        $$InvoiceLinesTableReferences._invoiceIdTable(db),
                    referencedColumn:
                        $$InvoiceLinesTableReferences._invoiceIdTable(db).id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$InvoiceLinesTableReferences._productIdTable(db),
                    referencedColumn:
                        $$InvoiceLinesTableReferences._productIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InvoiceLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceLinesTable,
    InvoiceLine,
    $$InvoiceLinesTableFilterComposer,
    $$InvoiceLinesTableOrderingComposer,
    $$InvoiceLinesTableAnnotationComposer,
    $$InvoiceLinesTableCreateCompanionBuilder,
    $$InvoiceLinesTableUpdateCompanionBuilder,
    (InvoiceLine, $$InvoiceLinesTableReferences),
    InvoiceLine,
    PrefetchHooks Function({bool invoiceId, bool productId})>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String invoiceId,
  required String provider,
  required String status,
  required int amountCentavos,
  required String reference,
  required DateTime authorizedAt,
  required bool isOffline,
  Value<int?> cashTenderedCentavos,
  Value<int?> changeCentavos,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<String> provider,
  Value<String> status,
  Value<int> amountCentavos,
  Value<String> reference,
  Value<DateTime> authorizedAt,
  Value<bool> isOffline,
  Value<int?> cashTenderedCentavos,
  Value<int?> changeCentavos,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) => db.invoices
      .createAlias($_aliasNameGenerator(db.payments.invoiceId, db.invoices.id));

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountCentavos => $composableBuilder(
      column: $table.amountCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get authorizedAt => $composableBuilder(
      column: $table.authorizedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOffline => $composableBuilder(
      column: $table.isOffline, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cashTenderedCentavos => $composableBuilder(
      column: $table.cashTenderedCentavos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get changeCentavos => $composableBuilder(
      column: $table.changeCentavos,
      builder: (column) => ColumnFilters(column));

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountCentavos => $composableBuilder(
      column: $table.amountCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get authorizedAt => $composableBuilder(
      column: $table.authorizedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOffline => $composableBuilder(
      column: $table.isOffline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cashTenderedCentavos => $composableBuilder(
      column: $table.cashTenderedCentavos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get changeCentavos => $composableBuilder(
      column: $table.changeCentavos,
      builder: (column) => ColumnOrderings(column));

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableOrderingComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get amountCentavos => $composableBuilder(
      column: $table.amountCentavos, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<DateTime> get authorizedAt => $composableBuilder(
      column: $table.authorizedAt, builder: (column) => column);

  GeneratedColumn<bool> get isOffline =>
      $composableBuilder(column: $table.isOffline, builder: (column) => column);

  GeneratedColumn<int> get cashTenderedCentavos => $composableBuilder(
      column: $table.cashTenderedCentavos, builder: (column) => column);

  GeneratedColumn<int> get changeCentavos => $composableBuilder(
      column: $table.changeCentavos, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool invoiceId})> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> amountCentavos = const Value.absent(),
            Value<String> reference = const Value.absent(),
            Value<DateTime> authorizedAt = const Value.absent(),
            Value<bool> isOffline = const Value.absent(),
            Value<int?> cashTenderedCentavos = const Value.absent(),
            Value<int?> changeCentavos = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            invoiceId: invoiceId,
            provider: provider,
            status: status,
            amountCentavos: amountCentavos,
            reference: reference,
            authorizedAt: authorizedAt,
            isOffline: isOffline,
            cashTenderedCentavos: cashTenderedCentavos,
            changeCentavos: changeCentavos,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required String provider,
            required String status,
            required int amountCentavos,
            required String reference,
            required DateTime authorizedAt,
            required bool isOffline,
            Value<int?> cashTenderedCentavos = const Value.absent(),
            Value<int?> changeCentavos = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            provider: provider,
            status: status,
            amountCentavos: amountCentavos,
            reference: reference,
            authorizedAt: authorizedAt,
            isOffline: isOffline,
            cashTenderedCentavos: cashTenderedCentavos,
            changeCentavos: changeCentavos,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PaymentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (invoiceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.invoiceId,
                    referencedTable:
                        $$PaymentsTableReferences._invoiceIdTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._invoiceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool invoiceId})>;
typedef $$InventoryMovementsTableCreateCompanionBuilder
    = InventoryMovementsCompanion Function({
  required String id,
  required String branchId,
  required String productId,
  required String type,
  required int quantityDelta,
  required int balanceAfter,
  required String referenceType,
  required String referenceId,
  required DateTime occurredAt,
  Value<int> rowid,
});
typedef $$InventoryMovementsTableUpdateCompanionBuilder
    = InventoryMovementsCompanion Function({
  Value<String> id,
  Value<String> branchId,
  Value<String> productId,
  Value<String> type,
  Value<int> quantityDelta,
  Value<int> balanceAfter,
  Value<String> referenceType,
  Value<String> referenceId,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});

final class $$InventoryMovementsTableReferences extends BaseReferences<
    _$AppDatabase, $InventoryMovementsTable, InventoryMovement> {
  $$InventoryMovementsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BranchesTable _branchIdTable(_$AppDatabase db) =>
      db.branches.createAlias(
          $_aliasNameGenerator(db.inventoryMovements.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.inventoryMovements.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityDelta => $composableBuilder(
      column: $table.quantityDelta, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityDelta => $composableBuilder(
      column: $table.quantityDelta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceType => $composableBuilder(
      column: $table.referenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantityDelta => $composableBuilder(
      column: $table.quantityDelta, builder: (column) => column);

  GeneratedColumn<int> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
      column: $table.referenceType, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryMovementsTable,
    InventoryMovement,
    $$InventoryMovementsTableFilterComposer,
    $$InventoryMovementsTableOrderingComposer,
    $$InventoryMovementsTableAnnotationComposer,
    $$InventoryMovementsTableCreateCompanionBuilder,
    $$InventoryMovementsTableUpdateCompanionBuilder,
    (InventoryMovement, $$InventoryMovementsTableReferences),
    InventoryMovement,
    PrefetchHooks Function({bool branchId, bool productId})> {
  $$InventoryMovementsTableTableManager(
      _$AppDatabase db, $InventoryMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryMovementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> quantityDelta = const Value.absent(),
            Value<int> balanceAfter = const Value.absent(),
            Value<String> referenceType = const Value.absent(),
            Value<String> referenceId = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryMovementsCompanion(
            id: id,
            branchId: branchId,
            productId: productId,
            type: type,
            quantityDelta: quantityDelta,
            balanceAfter: balanceAfter,
            referenceType: referenceType,
            referenceId: referenceId,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String branchId,
            required String productId,
            required String type,
            required int quantityDelta,
            required int balanceAfter,
            required String referenceType,
            required String referenceId,
            required DateTime occurredAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryMovementsCompanion.insert(
            id: id,
            branchId: branchId,
            productId: productId,
            type: type,
            quantityDelta: quantityDelta,
            balanceAfter: balanceAfter,
            referenceType: referenceType,
            referenceId: referenceId,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryMovementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({branchId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable:
                        $$InventoryMovementsTableReferences._branchIdTable(db),
                    referencedColumn: $$InventoryMovementsTableReferences
                        ._branchIdTable(db)
                        .id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$InventoryMovementsTableReferences._productIdTable(db),
                    referencedColumn: $$InventoryMovementsTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryMovementsTable,
    InventoryMovement,
    $$InventoryMovementsTableFilterComposer,
    $$InventoryMovementsTableOrderingComposer,
    $$InventoryMovementsTableAnnotationComposer,
    $$InventoryMovementsTableCreateCompanionBuilder,
    $$InventoryMovementsTableUpdateCompanionBuilder,
    (InventoryMovement, $$InventoryMovementsTableReferences),
    InventoryMovement,
    PrefetchHooks Function({bool branchId, bool productId})>;
typedef $$InventoryTransfersTableCreateCompanionBuilder
    = InventoryTransfersCompanion Function({
  required String id,
  required String productId,
  required String sourceBranchId,
  required String destinationBranchId,
  required int quantity,
  required String status,
  required String createdBy,
  required DateTime createdAt,
  required DateTime dispatchedAt,
  Value<String?> receivedBy,
  Value<DateTime?> receivedAt,
  Value<String?> cancelledBy,
  Value<DateTime?> cancelledAt,
  Value<String?> cancellationReason,
  Value<int> version,
  Value<int> rowid,
});
typedef $$InventoryTransfersTableUpdateCompanionBuilder
    = InventoryTransfersCompanion Function({
  Value<String> id,
  Value<String> productId,
  Value<String> sourceBranchId,
  Value<String> destinationBranchId,
  Value<int> quantity,
  Value<String> status,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> dispatchedAt,
  Value<String?> receivedBy,
  Value<DateTime?> receivedAt,
  Value<String?> cancelledBy,
  Value<DateTime?> cancelledAt,
  Value<String?> cancellationReason,
  Value<int> version,
  Value<int> rowid,
});

final class $$InventoryTransfersTableReferences extends BaseReferences<
    _$AppDatabase, $InventoryTransfersTable, InventoryTransfer> {
  $$InventoryTransfersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.inventoryTransfers.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BranchesTable _sourceBranchIdTable(_$AppDatabase db) =>
      db.branches.createAlias($_aliasNameGenerator(
          db.inventoryTransfers.sourceBranchId, db.branches.id));

  $$BranchesTableProcessedTableManager get sourceBranchId {
    final $_column = $_itemColumn<String>('source_branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceBranchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BranchesTable _destinationBranchIdTable(_$AppDatabase db) =>
      db.branches.createAlias($_aliasNameGenerator(
          db.inventoryTransfers.destinationBranchId, db.branches.id));

  $$BranchesTableProcessedTableManager get destinationBranchId {
    final $_column = $_itemColumn<String>('destination_branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_destinationBranchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InventoryTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryTransfersTable> {
  $$InventoryTransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dispatchedAt => $composableBuilder(
      column: $table.dispatchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receivedBy => $composableBuilder(
      column: $table.receivedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cancelledBy => $composableBuilder(
      column: $table.cancelledBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cancellationReason => $composableBuilder(
      column: $table.cancellationReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableFilterComposer get sourceBranchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceBranchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableFilterComposer get destinationBranchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.destinationBranchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryTransfersTable> {
  $$InventoryTransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dispatchedAt => $composableBuilder(
      column: $table.dispatchedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receivedBy => $composableBuilder(
      column: $table.receivedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cancelledBy => $composableBuilder(
      column: $table.cancelledBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cancellationReason => $composableBuilder(
      column: $table.cancellationReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableOrderingComposer get sourceBranchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceBranchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableOrderingComposer get destinationBranchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.destinationBranchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryTransfersTable> {
  $$InventoryTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dispatchedAt => $composableBuilder(
      column: $table.dispatchedAt, builder: (column) => column);

  GeneratedColumn<String> get receivedBy => $composableBuilder(
      column: $table.receivedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => column);

  GeneratedColumn<String> get cancelledBy => $composableBuilder(
      column: $table.cancelledBy, builder: (column) => column);

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
      column: $table.cancelledAt, builder: (column) => column);

  GeneratedColumn<String> get cancellationReason => $composableBuilder(
      column: $table.cancellationReason, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableAnnotationComposer get sourceBranchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceBranchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableAnnotationComposer get destinationBranchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.destinationBranchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InventoryTransfersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventoryTransfersTable,
    InventoryTransfer,
    $$InventoryTransfersTableFilterComposer,
    $$InventoryTransfersTableOrderingComposer,
    $$InventoryTransfersTableAnnotationComposer,
    $$InventoryTransfersTableCreateCompanionBuilder,
    $$InventoryTransfersTableUpdateCompanionBuilder,
    (InventoryTransfer, $$InventoryTransfersTableReferences),
    InventoryTransfer,
    PrefetchHooks Function(
        {bool productId, bool sourceBranchId, bool destinationBranchId})> {
  $$InventoryTransfersTableTableManager(
      _$AppDatabase db, $InventoryTransfersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTransfersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> sourceBranchId = const Value.absent(),
            Value<String> destinationBranchId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> dispatchedAt = const Value.absent(),
            Value<String?> receivedBy = const Value.absent(),
            Value<DateTime?> receivedAt = const Value.absent(),
            Value<String?> cancelledBy = const Value.absent(),
            Value<DateTime?> cancelledAt = const Value.absent(),
            Value<String?> cancellationReason = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryTransfersCompanion(
            id: id,
            productId: productId,
            sourceBranchId: sourceBranchId,
            destinationBranchId: destinationBranchId,
            quantity: quantity,
            status: status,
            createdBy: createdBy,
            createdAt: createdAt,
            dispatchedAt: dispatchedAt,
            receivedBy: receivedBy,
            receivedAt: receivedAt,
            cancelledBy: cancelledBy,
            cancelledAt: cancelledAt,
            cancellationReason: cancellationReason,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String productId,
            required String sourceBranchId,
            required String destinationBranchId,
            required int quantity,
            required String status,
            required String createdBy,
            required DateTime createdAt,
            required DateTime dispatchedAt,
            Value<String?> receivedBy = const Value.absent(),
            Value<DateTime?> receivedAt = const Value.absent(),
            Value<String?> cancelledBy = const Value.absent(),
            Value<DateTime?> cancelledAt = const Value.absent(),
            Value<String?> cancellationReason = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryTransfersCompanion.insert(
            id: id,
            productId: productId,
            sourceBranchId: sourceBranchId,
            destinationBranchId: destinationBranchId,
            quantity: quantity,
            status: status,
            createdBy: createdBy,
            createdAt: createdAt,
            dispatchedAt: dispatchedAt,
            receivedBy: receivedBy,
            receivedAt: receivedAt,
            cancelledBy: cancelledBy,
            cancelledAt: cancelledAt,
            cancellationReason: cancellationReason,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InventoryTransfersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {productId = false,
              sourceBranchId = false,
              destinationBranchId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$InventoryTransfersTableReferences._productIdTable(db),
                    referencedColumn: $$InventoryTransfersTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }
                if (sourceBranchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceBranchId,
                    referencedTable: $$InventoryTransfersTableReferences
                        ._sourceBranchIdTable(db),
                    referencedColumn: $$InventoryTransfersTableReferences
                        ._sourceBranchIdTable(db)
                        .id,
                  ) as T;
                }
                if (destinationBranchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.destinationBranchId,
                    referencedTable: $$InventoryTransfersTableReferences
                        ._destinationBranchIdTable(db),
                    referencedColumn: $$InventoryTransfersTableReferences
                        ._destinationBranchIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InventoryTransfersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventoryTransfersTable,
    InventoryTransfer,
    $$InventoryTransfersTableFilterComposer,
    $$InventoryTransfersTableOrderingComposer,
    $$InventoryTransfersTableAnnotationComposer,
    $$InventoryTransfersTableCreateCompanionBuilder,
    $$InventoryTransfersTableUpdateCompanionBuilder,
    (InventoryTransfer, $$InventoryTransfersTableReferences),
    InventoryTransfer,
    PrefetchHooks Function(
        {bool productId, bool sourceBranchId, bool destinationBranchId})>;
typedef $$AuditEventsTableCreateCompanionBuilder = AuditEventsCompanion
    Function({
  required String id,
  required String branchId,
  required int sequence,
  required String previousHash,
  required String eventHash,
  Value<String?> terminalId,
  required String actorId,
  required String eventType,
  required String entityType,
  required String entityId,
  required String payloadJson,
  required DateTime occurredAt,
  Value<int> rowid,
});
typedef $$AuditEventsTableUpdateCompanionBuilder = AuditEventsCompanion
    Function({
  Value<String> id,
  Value<String> branchId,
  Value<int> sequence,
  Value<String> previousHash,
  Value<String> eventHash,
  Value<String?> terminalId,
  Value<String> actorId,
  Value<String> eventType,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> payloadJson,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});

final class $$AuditEventsTableReferences
    extends BaseReferences<_$AppDatabase, $AuditEventsTable, AuditEvent> {
  $$AuditEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BranchesTable _branchIdTable(_$AppDatabase db) =>
      db.branches.createAlias(
          $_aliasNameGenerator(db.auditEvents.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AuditEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousHash => $composableBuilder(
      column: $table.previousHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventHash => $composableBuilder(
      column: $table.eventHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get terminalId => $composableBuilder(
      column: $table.terminalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actorId => $composableBuilder(
      column: $table.actorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousHash => $composableBuilder(
      column: $table.previousHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventHash => $composableBuilder(
      column: $table.eventHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get terminalId => $composableBuilder(
      column: $table.terminalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actorId => $composableBuilder(
      column: $table.actorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get previousHash => $composableBuilder(
      column: $table.previousHash, builder: (column) => column);

  GeneratedColumn<String> get eventHash =>
      $composableBuilder(column: $table.eventHash, builder: (column) => column);

  GeneratedColumn<String> get terminalId => $composableBuilder(
      column: $table.terminalId, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AuditEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditEventsTable,
    AuditEvent,
    $$AuditEventsTableFilterComposer,
    $$AuditEventsTableOrderingComposer,
    $$AuditEventsTableAnnotationComposer,
    $$AuditEventsTableCreateCompanionBuilder,
    $$AuditEventsTableUpdateCompanionBuilder,
    (AuditEvent, $$AuditEventsTableReferences),
    AuditEvent,
    PrefetchHooks Function({bool branchId})> {
  $$AuditEventsTableTableManager(_$AppDatabase db, $AuditEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<int> sequence = const Value.absent(),
            Value<String> previousHash = const Value.absent(),
            Value<String> eventHash = const Value.absent(),
            Value<String?> terminalId = const Value.absent(),
            Value<String> actorId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditEventsCompanion(
            id: id,
            branchId: branchId,
            sequence: sequence,
            previousHash: previousHash,
            eventHash: eventHash,
            terminalId: terminalId,
            actorId: actorId,
            eventType: eventType,
            entityType: entityType,
            entityId: entityId,
            payloadJson: payloadJson,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String branchId,
            required int sequence,
            required String previousHash,
            required String eventHash,
            Value<String?> terminalId = const Value.absent(),
            required String actorId,
            required String eventType,
            required String entityType,
            required String entityId,
            required String payloadJson,
            required DateTime occurredAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditEventsCompanion.insert(
            id: id,
            branchId: branchId,
            sequence: sequence,
            previousHash: previousHash,
            eventHash: eventHash,
            terminalId: terminalId,
            actorId: actorId,
            eventType: eventType,
            entityType: entityType,
            entityId: entityId,
            payloadJson: payloadJson,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AuditEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({branchId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable:
                        $$AuditEventsTableReferences._branchIdTable(db),
                    referencedColumn:
                        $$AuditEventsTableReferences._branchIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AuditEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditEventsTable,
    AuditEvent,
    $$AuditEventsTableFilterComposer,
    $$AuditEventsTableOrderingComposer,
    $$AuditEventsTableAnnotationComposer,
    $$AuditEventsTableCreateCompanionBuilder,
    $$AuditEventsTableUpdateCompanionBuilder,
    (AuditEvent, $$AuditEventsTableReferences),
    AuditEvent,
    PrefetchHooks Function({bool branchId})>;
typedef $$SyncOutboxEventsTableCreateCompanionBuilder
    = SyncOutboxEventsCompanion Function({
  required String id,
  required String branchId,
  required String aggregateType,
  required String aggregateId,
  required String eventType,
  required String idempotencyKey,
  required String payloadJson,
  required DateTime createdAt,
  Value<int> attemptCount,
  Value<DateTime?> nextAttemptAt,
  Value<String?> leaseId,
  Value<DateTime?> leaseExpiresAt,
  Value<String?> lastError,
  Value<String?> serverEventId,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$SyncOutboxEventsTableUpdateCompanionBuilder
    = SyncOutboxEventsCompanion Function({
  Value<String> id,
  Value<String> branchId,
  Value<String> aggregateType,
  Value<String> aggregateId,
  Value<String> eventType,
  Value<String> idempotencyKey,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> attemptCount,
  Value<DateTime?> nextAttemptAt,
  Value<String?> leaseId,
  Value<DateTime?> leaseExpiresAt,
  Value<String?> lastError,
  Value<String?> serverEventId,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

final class $$SyncOutboxEventsTableReferences extends BaseReferences<
    _$AppDatabase, $SyncOutboxEventsTable, SyncOutboxEvent> {
  $$SyncOutboxEventsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BranchesTable _branchIdTable(_$AppDatabase db) =>
      db.branches.createAlias(
          $_aliasNameGenerator(db.syncOutboxEvents.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SupplierDeliveryJobsTable,
      List<SupplierDeliveryJob>> _supplierDeliveryJobsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.supplierDeliveryJobs,
          aliasName: $_aliasNameGenerator(
              db.syncOutboxEvents.id, db.supplierDeliveryJobs.sourceEventId));

  $$SupplierDeliveryJobsTableProcessedTableManager
      get supplierDeliveryJobsRefs {
    final manager = $$SupplierDeliveryJobsTableTableManager(
            $_db, $_db.supplierDeliveryJobs)
        .filter(
            (f) => f.sourceEventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_supplierDeliveryJobsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SyncOutboxEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxEventsTable> {
  $$SyncOutboxEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aggregateType => $composableBuilder(
      column: $table.aggregateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aggregateId => $composableBuilder(
      column: $table.aggregateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get leaseId => $composableBuilder(
      column: $table.leaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get leaseExpiresAt => $composableBuilder(
      column: $table.leaseExpiresAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverEventId => $composableBuilder(
      column: $table.serverEventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> supplierDeliveryJobsRefs(
      Expression<bool> Function($$SupplierDeliveryJobsTableFilterComposer f)
          f) {
    final $$SupplierDeliveryJobsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.supplierDeliveryJobs,
        getReferencedColumn: (t) => t.sourceEventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierDeliveryJobsTableFilterComposer(
              $db: $db,
              $table: $db.supplierDeliveryJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SyncOutboxEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxEventsTable> {
  $$SyncOutboxEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aggregateType => $composableBuilder(
      column: $table.aggregateType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aggregateId => $composableBuilder(
      column: $table.aggregateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get leaseId => $composableBuilder(
      column: $table.leaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get leaseExpiresAt => $composableBuilder(
      column: $table.leaseExpiresAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverEventId => $composableBuilder(
      column: $table.serverEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncOutboxEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxEventsTable> {
  $$SyncOutboxEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get aggregateType => $composableBuilder(
      column: $table.aggregateType, builder: (column) => column);

  GeneratedColumn<String> get aggregateId => $composableBuilder(
      column: $table.aggregateId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get leaseId =>
      $composableBuilder(column: $table.leaseId, builder: (column) => column);

  GeneratedColumn<DateTime> get leaseExpiresAt => $composableBuilder(
      column: $table.leaseExpiresAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get serverEventId => $composableBuilder(
      column: $table.serverEventId, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> supplierDeliveryJobsRefs<T extends Object>(
      Expression<T> Function($$SupplierDeliveryJobsTableAnnotationComposer a)
          f) {
    final $$SupplierDeliveryJobsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierDeliveryJobs,
            getReferencedColumn: (t) => t.sourceEventId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierDeliveryJobsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierDeliveryJobs,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SyncOutboxEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOutboxEventsTable,
    SyncOutboxEvent,
    $$SyncOutboxEventsTableFilterComposer,
    $$SyncOutboxEventsTableOrderingComposer,
    $$SyncOutboxEventsTableAnnotationComposer,
    $$SyncOutboxEventsTableCreateCompanionBuilder,
    $$SyncOutboxEventsTableUpdateCompanionBuilder,
    (SyncOutboxEvent, $$SyncOutboxEventsTableReferences),
    SyncOutboxEvent,
    PrefetchHooks Function({bool branchId, bool supplierDeliveryJobsRefs})> {
  $$SyncOutboxEventsTableTableManager(
      _$AppDatabase db, $SyncOutboxEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<String> aggregateType = const Value.absent(),
            Value<String> aggregateId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> leaseId = const Value.absent(),
            Value<DateTime?> leaseExpiresAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String?> serverEventId = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxEventsCompanion(
            id: id,
            branchId: branchId,
            aggregateType: aggregateType,
            aggregateId: aggregateId,
            eventType: eventType,
            idempotencyKey: idempotencyKey,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attemptCount: attemptCount,
            nextAttemptAt: nextAttemptAt,
            leaseId: leaseId,
            leaseExpiresAt: leaseExpiresAt,
            lastError: lastError,
            serverEventId: serverEventId,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String branchId,
            required String aggregateType,
            required String aggregateId,
            required String eventType,
            required String idempotencyKey,
            required String payloadJson,
            required DateTime createdAt,
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<String?> leaseId = const Value.absent(),
            Value<DateTime?> leaseExpiresAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String?> serverEventId = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncOutboxEventsCompanion.insert(
            id: id,
            branchId: branchId,
            aggregateType: aggregateType,
            aggregateId: aggregateId,
            eventType: eventType,
            idempotencyKey: idempotencyKey,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attemptCount: attemptCount,
            nextAttemptAt: nextAttemptAt,
            leaseId: leaseId,
            leaseExpiresAt: leaseExpiresAt,
            lastError: lastError,
            serverEventId: serverEventId,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SyncOutboxEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {branchId = false, supplierDeliveryJobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (supplierDeliveryJobsRefs) db.supplierDeliveryJobs
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable:
                        $$SyncOutboxEventsTableReferences._branchIdTable(db),
                    referencedColumn:
                        $$SyncOutboxEventsTableReferences._branchIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (supplierDeliveryJobsRefs)
                    await $_getPrefetchedData<SyncOutboxEvent,
                            $SyncOutboxEventsTable, SupplierDeliveryJob>(
                        currentTable: table,
                        referencedTable: $$SyncOutboxEventsTableReferences
                            ._supplierDeliveryJobsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SyncOutboxEventsTableReferences(db, table, p0)
                                .supplierDeliveryJobsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sourceEventId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SyncOutboxEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncOutboxEventsTable,
    SyncOutboxEvent,
    $$SyncOutboxEventsTableFilterComposer,
    $$SyncOutboxEventsTableOrderingComposer,
    $$SyncOutboxEventsTableAnnotationComposer,
    $$SyncOutboxEventsTableCreateCompanionBuilder,
    $$SyncOutboxEventsTableUpdateCompanionBuilder,
    (SyncOutboxEvent, $$SyncOutboxEventsTableReferences),
    SyncOutboxEvent,
    PrefetchHooks Function({bool branchId, bool supplierDeliveryJobsRefs})>;
typedef $$HardwareJobsTableCreateCompanionBuilder = HardwareJobsCompanion
    Function({
  required String id,
  required String invoiceId,
  required String jobType,
  required String status,
  required String payloadJson,
  required String idempotencyKey,
  required DateTime createdAt,
  Value<int> attemptCount,
  Value<DateTime?> processingStartedAt,
  Value<DateTime?> nextAttemptAt,
  Value<DateTime?> completedAt,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$HardwareJobsTableUpdateCompanionBuilder = HardwareJobsCompanion
    Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<String> jobType,
  Value<String> status,
  Value<String> payloadJson,
  Value<String> idempotencyKey,
  Value<DateTime> createdAt,
  Value<int> attemptCount,
  Value<DateTime?> processingStartedAt,
  Value<DateTime?> nextAttemptAt,
  Value<DateTime?> completedAt,
  Value<String?> lastError,
  Value<int> rowid,
});

final class $$HardwareJobsTableReferences
    extends BaseReferences<_$AppDatabase, $HardwareJobsTable, HardwareJob> {
  $$HardwareJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias(
          $_aliasNameGenerator(db.hardwareJobs.invoiceId, db.invoices.id));

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$HardwareJobsTableFilterComposer
    extends Composer<_$AppDatabase, $HardwareJobsTable> {
  $$HardwareJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get processingStartedAt => $composableBuilder(
      column: $table.processingStartedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HardwareJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $HardwareJobsTable> {
  $$HardwareJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get processingStartedAt => $composableBuilder(
      column: $table.processingStartedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableOrderingComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HardwareJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HardwareJobsTable> {
  $$HardwareJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<DateTime> get processingStartedAt => $composableBuilder(
      column: $table.processingStartedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HardwareJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HardwareJobsTable,
    HardwareJob,
    $$HardwareJobsTableFilterComposer,
    $$HardwareJobsTableOrderingComposer,
    $$HardwareJobsTableAnnotationComposer,
    $$HardwareJobsTableCreateCompanionBuilder,
    $$HardwareJobsTableUpdateCompanionBuilder,
    (HardwareJob, $$HardwareJobsTableReferences),
    HardwareJob,
    PrefetchHooks Function({bool invoiceId})> {
  $$HardwareJobsTableTableManager(_$AppDatabase db, $HardwareJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HardwareJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HardwareJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HardwareJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> jobType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> processingStartedAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HardwareJobsCompanion(
            id: id,
            invoiceId: invoiceId,
            jobType: jobType,
            status: status,
            payloadJson: payloadJson,
            idempotencyKey: idempotencyKey,
            createdAt: createdAt,
            attemptCount: attemptCount,
            processingStartedAt: processingStartedAt,
            nextAttemptAt: nextAttemptAt,
            completedAt: completedAt,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required String jobType,
            required String status,
            required String payloadJson,
            required String idempotencyKey,
            required DateTime createdAt,
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> processingStartedAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HardwareJobsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            jobType: jobType,
            status: status,
            payloadJson: payloadJson,
            idempotencyKey: idempotencyKey,
            createdAt: createdAt,
            attemptCount: attemptCount,
            processingStartedAt: processingStartedAt,
            nextAttemptAt: nextAttemptAt,
            completedAt: completedAt,
            lastError: lastError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$HardwareJobsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (invoiceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.invoiceId,
                    referencedTable:
                        $$HardwareJobsTableReferences._invoiceIdTable(db),
                    referencedColumn:
                        $$HardwareJobsTableReferences._invoiceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$HardwareJobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HardwareJobsTable,
    HardwareJob,
    $$HardwareJobsTableFilterComposer,
    $$HardwareJobsTableOrderingComposer,
    $$HardwareJobsTableAnnotationComposer,
    $$HardwareJobsTableCreateCompanionBuilder,
    $$HardwareJobsTableUpdateCompanionBuilder,
    (HardwareJob, $$HardwareJobsTableReferences),
    HardwareJob,
    PrefetchHooks Function({bool invoiceId})>;
typedef $$SupplierConnectorsTableCreateCompanionBuilder
    = SupplierConnectorsCompanion Function({
  required String id,
  required String branchId,
  required String name,
  required String connectorType,
  required String secretReference,
  Value<bool> isEnabled,
  required String approvedBy,
  required DateTime approvedAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SupplierConnectorsTableUpdateCompanionBuilder
    = SupplierConnectorsCompanion Function({
  Value<String> id,
  Value<String> branchId,
  Value<String> name,
  Value<String> connectorType,
  Value<String> secretReference,
  Value<bool> isEnabled,
  Value<String> approvedBy,
  Value<DateTime> approvedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SupplierConnectorsTableReferences extends BaseReferences<
    _$AppDatabase, $SupplierConnectorsTable, SupplierConnector> {
  $$SupplierConnectorsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BranchesTable _branchIdTable(_$AppDatabase db) =>
      db.branches.createAlias(
          $_aliasNameGenerator(db.supplierConnectors.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SupplierProductSubscriptionsTable,
      List<SupplierProductSubscription>> _supplierProductSubscriptionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.supplierProductSubscriptions,
          aliasName: $_aliasNameGenerator(db.supplierConnectors.id,
              db.supplierProductSubscriptions.connectorId));

  $$SupplierProductSubscriptionsTableProcessedTableManager
      get supplierProductSubscriptionsRefs {
    final manager = $$SupplierProductSubscriptionsTableTableManager(
            $_db, $_db.supplierProductSubscriptions)
        .filter((f) => f.connectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_supplierProductSubscriptionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SupplierDeliveryJobsTable,
      List<SupplierDeliveryJob>> _supplierDeliveryJobsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.supplierDeliveryJobs,
          aliasName: $_aliasNameGenerator(
              db.supplierConnectors.id, db.supplierDeliveryJobs.connectorId));

  $$SupplierDeliveryJobsTableProcessedTableManager
      get supplierDeliveryJobsRefs {
    final manager = $$SupplierDeliveryJobsTableTableManager(
            $_db, $_db.supplierDeliveryJobs)
        .filter((f) => f.connectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_supplierDeliveryJobsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SupplierConnectorsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierConnectorsTable> {
  $$SupplierConnectorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get connectorType => $composableBuilder(
      column: $table.connectorType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secretReference => $composableBuilder(
      column: $table.secretReference,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> supplierProductSubscriptionsRefs(
      Expression<bool> Function(
              $$SupplierProductSubscriptionsTableFilterComposer f)
          f) {
    final $$SupplierProductSubscriptionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierProductSubscriptions,
            getReferencedColumn: (t) => t.connectorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierProductSubscriptionsTableFilterComposer(
                  $db: $db,
                  $table: $db.supplierProductSubscriptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> supplierDeliveryJobsRefs(
      Expression<bool> Function($$SupplierDeliveryJobsTableFilterComposer f)
          f) {
    final $$SupplierDeliveryJobsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.supplierDeliveryJobs,
        getReferencedColumn: (t) => t.connectorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierDeliveryJobsTableFilterComposer(
              $db: $db,
              $table: $db.supplierDeliveryJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SupplierConnectorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierConnectorsTable> {
  $$SupplierConnectorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get connectorType => $composableBuilder(
      column: $table.connectorType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secretReference => $composableBuilder(
      column: $table.secretReference,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplierConnectorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierConnectorsTable> {
  $$SupplierConnectorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get connectorType => $composableBuilder(
      column: $table.connectorType, builder: (column) => column);

  GeneratedColumn<String> get secretReference => $composableBuilder(
      column: $table.secretReference, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> supplierProductSubscriptionsRefs<T extends Object>(
      Expression<T> Function(
              $$SupplierProductSubscriptionsTableAnnotationComposer a)
          f) {
    final $$SupplierProductSubscriptionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierProductSubscriptions,
            getReferencedColumn: (t) => t.connectorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierProductSubscriptionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierProductSubscriptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> supplierDeliveryJobsRefs<T extends Object>(
      Expression<T> Function($$SupplierDeliveryJobsTableAnnotationComposer a)
          f) {
    final $$SupplierDeliveryJobsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.supplierDeliveryJobs,
            getReferencedColumn: (t) => t.connectorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierDeliveryJobsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierDeliveryJobs,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SupplierConnectorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SupplierConnectorsTable,
    SupplierConnector,
    $$SupplierConnectorsTableFilterComposer,
    $$SupplierConnectorsTableOrderingComposer,
    $$SupplierConnectorsTableAnnotationComposer,
    $$SupplierConnectorsTableCreateCompanionBuilder,
    $$SupplierConnectorsTableUpdateCompanionBuilder,
    (SupplierConnector, $$SupplierConnectorsTableReferences),
    SupplierConnector,
    PrefetchHooks Function(
        {bool branchId,
        bool supplierProductSubscriptionsRefs,
        bool supplierDeliveryJobsRefs})> {
  $$SupplierConnectorsTableTableManager(
      _$AppDatabase db, $SupplierConnectorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierConnectorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierConnectorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierConnectorsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> connectorType = const Value.absent(),
            Value<String> secretReference = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<String> approvedBy = const Value.absent(),
            Value<DateTime> approvedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SupplierConnectorsCompanion(
            id: id,
            branchId: branchId,
            name: name,
            connectorType: connectorType,
            secretReference: secretReference,
            isEnabled: isEnabled,
            approvedBy: approvedBy,
            approvedAt: approvedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String branchId,
            required String name,
            required String connectorType,
            required String secretReference,
            Value<bool> isEnabled = const Value.absent(),
            required String approvedBy,
            required DateTime approvedAt,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SupplierConnectorsCompanion.insert(
            id: id,
            branchId: branchId,
            name: name,
            connectorType: connectorType,
            secretReference: secretReference,
            isEnabled: isEnabled,
            approvedBy: approvedBy,
            approvedAt: approvedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SupplierConnectorsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {branchId = false,
              supplierProductSubscriptionsRefs = false,
              supplierDeliveryJobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (supplierProductSubscriptionsRefs)
                  db.supplierProductSubscriptions,
                if (supplierDeliveryJobsRefs) db.supplierDeliveryJobs
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable:
                        $$SupplierConnectorsTableReferences._branchIdTable(db),
                    referencedColumn: $$SupplierConnectorsTableReferences
                        ._branchIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (supplierProductSubscriptionsRefs)
                    await $_getPrefetchedData<
                            SupplierConnector,
                            $SupplierConnectorsTable,
                            SupplierProductSubscription>(
                        currentTable: table,
                        referencedTable: $$SupplierConnectorsTableReferences
                            ._supplierProductSubscriptionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SupplierConnectorsTableReferences(db, table, p0)
                                .supplierProductSubscriptionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.connectorId == item.id),
                        typedResults: items),
                  if (supplierDeliveryJobsRefs)
                    await $_getPrefetchedData<SupplierConnector,
                            $SupplierConnectorsTable, SupplierDeliveryJob>(
                        currentTable: table,
                        referencedTable: $$SupplierConnectorsTableReferences
                            ._supplierDeliveryJobsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SupplierConnectorsTableReferences(db, table, p0)
                                .supplierDeliveryJobsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.connectorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SupplierConnectorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SupplierConnectorsTable,
    SupplierConnector,
    $$SupplierConnectorsTableFilterComposer,
    $$SupplierConnectorsTableOrderingComposer,
    $$SupplierConnectorsTableAnnotationComposer,
    $$SupplierConnectorsTableCreateCompanionBuilder,
    $$SupplierConnectorsTableUpdateCompanionBuilder,
    (SupplierConnector, $$SupplierConnectorsTableReferences),
    SupplierConnector,
    PrefetchHooks Function(
        {bool branchId,
        bool supplierProductSubscriptionsRefs,
        bool supplierDeliveryJobsRefs})>;
typedef $$SupplierProductSubscriptionsTableCreateCompanionBuilder
    = SupplierProductSubscriptionsCompanion Function({
  required String connectorId,
  required String productId,
  required String allowedFieldsJson,
  required int suggestedOrderQuantity,
  Value<bool> isEnabled,
  required String approvedBy,
  required DateTime approvedAt,
  Value<int> rowid,
});
typedef $$SupplierProductSubscriptionsTableUpdateCompanionBuilder
    = SupplierProductSubscriptionsCompanion Function({
  Value<String> connectorId,
  Value<String> productId,
  Value<String> allowedFieldsJson,
  Value<int> suggestedOrderQuantity,
  Value<bool> isEnabled,
  Value<String> approvedBy,
  Value<DateTime> approvedAt,
  Value<int> rowid,
});

final class $$SupplierProductSubscriptionsTableReferences
    extends BaseReferences<_$AppDatabase, $SupplierProductSubscriptionsTable,
        SupplierProductSubscription> {
  $$SupplierProductSubscriptionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SupplierConnectorsTable _connectorIdTable(_$AppDatabase db) =>
      db.supplierConnectors.createAlias($_aliasNameGenerator(
          db.supplierProductSubscriptions.connectorId,
          db.supplierConnectors.id));

  $$SupplierConnectorsTableProcessedTableManager get connectorId {
    final $_column = $_itemColumn<String>('connector_id')!;

    final manager =
        $$SupplierConnectorsTableTableManager($_db, $_db.supplierConnectors)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.supplierProductSubscriptions.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SupplierProductSubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierProductSubscriptionsTable> {
  $$SupplierProductSubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get allowedFieldsJson => $composableBuilder(
      column: $table.allowedFieldsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get suggestedOrderQuantity => $composableBuilder(
      column: $table.suggestedOrderQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnFilters(column));

  $$SupplierConnectorsTableFilterComposer get connectorId {
    final $$SupplierConnectorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.connectorId,
        referencedTable: $db.supplierConnectors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierConnectorsTableFilterComposer(
              $db: $db,
              $table: $db.supplierConnectors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplierProductSubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierProductSubscriptionsTable> {
  $$SupplierProductSubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get allowedFieldsJson => $composableBuilder(
      column: $table.allowedFieldsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get suggestedOrderQuantity => $composableBuilder(
      column: $table.suggestedOrderQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnOrderings(column));

  $$SupplierConnectorsTableOrderingComposer get connectorId {
    final $$SupplierConnectorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.connectorId,
        referencedTable: $db.supplierConnectors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierConnectorsTableOrderingComposer(
              $db: $db,
              $table: $db.supplierConnectors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplierProductSubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierProductSubscriptionsTable> {
  $$SupplierProductSubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get allowedFieldsJson => $composableBuilder(
      column: $table.allowedFieldsJson, builder: (column) => column);

  GeneratedColumn<int> get suggestedOrderQuantity => $composableBuilder(
      column: $table.suggestedOrderQuantity, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get approvedBy => $composableBuilder(
      column: $table.approvedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => column);

  $$SupplierConnectorsTableAnnotationComposer get connectorId {
    final $$SupplierConnectorsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.connectorId,
            referencedTable: $db.supplierConnectors,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierConnectorsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierConnectors,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplierProductSubscriptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SupplierProductSubscriptionsTable,
    SupplierProductSubscription,
    $$SupplierProductSubscriptionsTableFilterComposer,
    $$SupplierProductSubscriptionsTableOrderingComposer,
    $$SupplierProductSubscriptionsTableAnnotationComposer,
    $$SupplierProductSubscriptionsTableCreateCompanionBuilder,
    $$SupplierProductSubscriptionsTableUpdateCompanionBuilder,
    (
      SupplierProductSubscription,
      $$SupplierProductSubscriptionsTableReferences
    ),
    SupplierProductSubscription,
    PrefetchHooks Function({bool connectorId, bool productId})> {
  $$SupplierProductSubscriptionsTableTableManager(
      _$AppDatabase db, $SupplierProductSubscriptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierProductSubscriptionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierProductSubscriptionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierProductSubscriptionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> connectorId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> allowedFieldsJson = const Value.absent(),
            Value<int> suggestedOrderQuantity = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<String> approvedBy = const Value.absent(),
            Value<DateTime> approvedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SupplierProductSubscriptionsCompanion(
            connectorId: connectorId,
            productId: productId,
            allowedFieldsJson: allowedFieldsJson,
            suggestedOrderQuantity: suggestedOrderQuantity,
            isEnabled: isEnabled,
            approvedBy: approvedBy,
            approvedAt: approvedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String connectorId,
            required String productId,
            required String allowedFieldsJson,
            required int suggestedOrderQuantity,
            Value<bool> isEnabled = const Value.absent(),
            required String approvedBy,
            required DateTime approvedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SupplierProductSubscriptionsCompanion.insert(
            connectorId: connectorId,
            productId: productId,
            allowedFieldsJson: allowedFieldsJson,
            suggestedOrderQuantity: suggestedOrderQuantity,
            isEnabled: isEnabled,
            approvedBy: approvedBy,
            approvedAt: approvedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SupplierProductSubscriptionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({connectorId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (connectorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.connectorId,
                    referencedTable:
                        $$SupplierProductSubscriptionsTableReferences
                            ._connectorIdTable(db),
                    referencedColumn:
                        $$SupplierProductSubscriptionsTableReferences
                            ._connectorIdTable(db)
                            .id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable:
                        $$SupplierProductSubscriptionsTableReferences
                            ._productIdTable(db),
                    referencedColumn:
                        $$SupplierProductSubscriptionsTableReferences
                            ._productIdTable(db)
                            .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SupplierProductSubscriptionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SupplierProductSubscriptionsTable,
        SupplierProductSubscription,
        $$SupplierProductSubscriptionsTableFilterComposer,
        $$SupplierProductSubscriptionsTableOrderingComposer,
        $$SupplierProductSubscriptionsTableAnnotationComposer,
        $$SupplierProductSubscriptionsTableCreateCompanionBuilder,
        $$SupplierProductSubscriptionsTableUpdateCompanionBuilder,
        (
          SupplierProductSubscription,
          $$SupplierProductSubscriptionsTableReferences
        ),
        SupplierProductSubscription,
        PrefetchHooks Function({bool connectorId, bool productId})>;
typedef $$SupplierDeliveryJobsTableCreateCompanionBuilder
    = SupplierDeliveryJobsCompanion Function({
  required String id,
  required String connectorId,
  required String sourceEventId,
  required String branchId,
  required String productId,
  required String status,
  required String idempotencyKey,
  required String payloadJson,
  required DateTime createdAt,
  Value<int> attemptCount,
  Value<String?> leaseId,
  Value<DateTime?> leaseExpiresAt,
  Value<DateTime?> nextAttemptAt,
  Value<DateTime?> completedAt,
  Value<String?> externalReference,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$SupplierDeliveryJobsTableUpdateCompanionBuilder
    = SupplierDeliveryJobsCompanion Function({
  Value<String> id,
  Value<String> connectorId,
  Value<String> sourceEventId,
  Value<String> branchId,
  Value<String> productId,
  Value<String> status,
  Value<String> idempotencyKey,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> attemptCount,
  Value<String?> leaseId,
  Value<DateTime?> leaseExpiresAt,
  Value<DateTime?> nextAttemptAt,
  Value<DateTime?> completedAt,
  Value<String?> externalReference,
  Value<String?> lastError,
  Value<int> rowid,
});

final class $$SupplierDeliveryJobsTableReferences extends BaseReferences<
    _$AppDatabase, $SupplierDeliveryJobsTable, SupplierDeliveryJob> {
  $$SupplierDeliveryJobsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SupplierConnectorsTable _connectorIdTable(_$AppDatabase db) =>
      db.supplierConnectors.createAlias($_aliasNameGenerator(
          db.supplierDeliveryJobs.connectorId, db.supplierConnectors.id));

  $$SupplierConnectorsTableProcessedTableManager get connectorId {
    final $_column = $_itemColumn<String>('connector_id')!;

    final manager =
        $$SupplierConnectorsTableTableManager($_db, $_db.supplierConnectors)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SyncOutboxEventsTable _sourceEventIdTable(_$AppDatabase db) =>
      db.syncOutboxEvents.createAlias($_aliasNameGenerator(
          db.supplierDeliveryJobs.sourceEventId, db.syncOutboxEvents.id));

  $$SyncOutboxEventsTableProcessedTableManager get sourceEventId {
    final $_column = $_itemColumn<String>('source_event_id')!;

    final manager =
        $$SyncOutboxEventsTableTableManager($_db, $_db.syncOutboxEvents)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BranchesTable _branchIdTable(_$AppDatabase db) =>
      db.branches.createAlias($_aliasNameGenerator(
          db.supplierDeliveryJobs.branchId, db.branches.id));

  $$BranchesTableProcessedTableManager get branchId {
    final $_column = $_itemColumn<String>('branch_id')!;

    final manager = $$BranchesTableTableManager($_db, $_db.branches)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_branchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias($_aliasNameGenerator(
          db.supplierDeliveryJobs.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SupplierDeliveryJobsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierDeliveryJobsTable> {
  $$SupplierDeliveryJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get leaseId => $composableBuilder(
      column: $table.leaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get leaseExpiresAt => $composableBuilder(
      column: $table.leaseExpiresAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalReference => $composableBuilder(
      column: $table.externalReference,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  $$SupplierConnectorsTableFilterComposer get connectorId {
    final $$SupplierConnectorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.connectorId,
        referencedTable: $db.supplierConnectors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierConnectorsTableFilterComposer(
              $db: $db,
              $table: $db.supplierConnectors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SyncOutboxEventsTableFilterComposer get sourceEventId {
    final $$SyncOutboxEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceEventId,
        referencedTable: $db.syncOutboxEvents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncOutboxEventsTableFilterComposer(
              $db: $db,
              $table: $db.syncOutboxEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableFilterComposer get branchId {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableFilterComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplierDeliveryJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierDeliveryJobsTable> {
  $$SupplierDeliveryJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get leaseId => $composableBuilder(
      column: $table.leaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get leaseExpiresAt => $composableBuilder(
      column: $table.leaseExpiresAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalReference => $composableBuilder(
      column: $table.externalReference,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  $$SupplierConnectorsTableOrderingComposer get connectorId {
    final $$SupplierConnectorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.connectorId,
        referencedTable: $db.supplierConnectors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SupplierConnectorsTableOrderingComposer(
              $db: $db,
              $table: $db.supplierConnectors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SyncOutboxEventsTableOrderingComposer get sourceEventId {
    final $$SyncOutboxEventsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceEventId,
        referencedTable: $db.syncOutboxEvents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncOutboxEventsTableOrderingComposer(
              $db: $db,
              $table: $db.syncOutboxEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableOrderingComposer get branchId {
    final $$BranchesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableOrderingComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableOrderingComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplierDeliveryJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierDeliveryJobsTable> {
  $$SupplierDeliveryJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<String> get leaseId =>
      $composableBuilder(column: $table.leaseId, builder: (column) => column);

  GeneratedColumn<DateTime> get leaseExpiresAt => $composableBuilder(
      column: $table.leaseExpiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get externalReference => $composableBuilder(
      column: $table.externalReference, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  $$SupplierConnectorsTableAnnotationComposer get connectorId {
    final $$SupplierConnectorsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.connectorId,
            referencedTable: $db.supplierConnectors,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SupplierConnectorsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.supplierConnectors,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$SyncOutboxEventsTableAnnotationComposer get sourceEventId {
    final $$SyncOutboxEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceEventId,
        referencedTable: $db.syncOutboxEvents,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncOutboxEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.syncOutboxEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BranchesTableAnnotationComposer get branchId {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.branchId,
        referencedTable: $db.branches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BranchesTableAnnotationComposer(
              $db: $db,
              $table: $db.branches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productId,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SupplierDeliveryJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SupplierDeliveryJobsTable,
    SupplierDeliveryJob,
    $$SupplierDeliveryJobsTableFilterComposer,
    $$SupplierDeliveryJobsTableOrderingComposer,
    $$SupplierDeliveryJobsTableAnnotationComposer,
    $$SupplierDeliveryJobsTableCreateCompanionBuilder,
    $$SupplierDeliveryJobsTableUpdateCompanionBuilder,
    (SupplierDeliveryJob, $$SupplierDeliveryJobsTableReferences),
    SupplierDeliveryJob,
    PrefetchHooks Function(
        {bool connectorId,
        bool sourceEventId,
        bool branchId,
        bool productId})> {
  $$SupplierDeliveryJobsTableTableManager(
      _$AppDatabase db, $SupplierDeliveryJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierDeliveryJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierDeliveryJobsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierDeliveryJobsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> connectorId = const Value.absent(),
            Value<String> sourceEventId = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<String?> leaseId = const Value.absent(),
            Value<DateTime?> leaseExpiresAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> externalReference = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SupplierDeliveryJobsCompanion(
            id: id,
            connectorId: connectorId,
            sourceEventId: sourceEventId,
            branchId: branchId,
            productId: productId,
            status: status,
            idempotencyKey: idempotencyKey,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attemptCount: attemptCount,
            leaseId: leaseId,
            leaseExpiresAt: leaseExpiresAt,
            nextAttemptAt: nextAttemptAt,
            completedAt: completedAt,
            externalReference: externalReference,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String connectorId,
            required String sourceEventId,
            required String branchId,
            required String productId,
            required String status,
            required String idempotencyKey,
            required String payloadJson,
            required DateTime createdAt,
            Value<int> attemptCount = const Value.absent(),
            Value<String?> leaseId = const Value.absent(),
            Value<DateTime?> leaseExpiresAt = const Value.absent(),
            Value<DateTime?> nextAttemptAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> externalReference = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SupplierDeliveryJobsCompanion.insert(
            id: id,
            connectorId: connectorId,
            sourceEventId: sourceEventId,
            branchId: branchId,
            productId: productId,
            status: status,
            idempotencyKey: idempotencyKey,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attemptCount: attemptCount,
            leaseId: leaseId,
            leaseExpiresAt: leaseExpiresAt,
            nextAttemptAt: nextAttemptAt,
            completedAt: completedAt,
            externalReference: externalReference,
            lastError: lastError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SupplierDeliveryJobsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {connectorId = false,
              sourceEventId = false,
              branchId = false,
              productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (connectorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.connectorId,
                    referencedTable: $$SupplierDeliveryJobsTableReferences
                        ._connectorIdTable(db),
                    referencedColumn: $$SupplierDeliveryJobsTableReferences
                        ._connectorIdTable(db)
                        .id,
                  ) as T;
                }
                if (sourceEventId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceEventId,
                    referencedTable: $$SupplierDeliveryJobsTableReferences
                        ._sourceEventIdTable(db),
                    referencedColumn: $$SupplierDeliveryJobsTableReferences
                        ._sourceEventIdTable(db)
                        .id,
                  ) as T;
                }
                if (branchId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.branchId,
                    referencedTable: $$SupplierDeliveryJobsTableReferences
                        ._branchIdTable(db),
                    referencedColumn: $$SupplierDeliveryJobsTableReferences
                        ._branchIdTable(db)
                        .id,
                  ) as T;
                }
                if (productId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productId,
                    referencedTable: $$SupplierDeliveryJobsTableReferences
                        ._productIdTable(db),
                    referencedColumn: $$SupplierDeliveryJobsTableReferences
                        ._productIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SupplierDeliveryJobsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SupplierDeliveryJobsTable,
        SupplierDeliveryJob,
        $$SupplierDeliveryJobsTableFilterComposer,
        $$SupplierDeliveryJobsTableOrderingComposer,
        $$SupplierDeliveryJobsTableAnnotationComposer,
        $$SupplierDeliveryJobsTableCreateCompanionBuilder,
        $$SupplierDeliveryJobsTableUpdateCompanionBuilder,
        (SupplierDeliveryJob, $$SupplierDeliveryJobsTableReferences),
        SupplierDeliveryJob,
        PrefetchHooks Function(
            {bool connectorId,
            bool sourceEventId,
            bool branchId,
            bool productId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db, _db.branches);
  $$TerminalsTableTableManager get terminals =>
      $$TerminalsTableTableManager(_db, _db.terminals);
  $$StaffUsersTableTableManager get staffUsers =>
      $$StaffUsersTableTableManager(_db, _db.staffUsers);
  $$StaffBranchAccessTableTableManager get staffBranchAccess =>
      $$StaffBranchAccessTableTableManager(_db, _db.staffBranchAccess);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$BranchInventoriesTableTableManager get branchInventories =>
      $$BranchInventoriesTableTableManager(_db, _db.branchInventories);
  $$InvoiceSequencesTableTableManager get invoiceSequences =>
      $$InvoiceSequencesTableTableManager(_db, _db.invoiceSequences);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceLinesTableTableManager get invoiceLines =>
      $$InvoiceLinesTableTableManager(_db, _db.invoiceLines);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(_db, _db.inventoryMovements);
  $$InventoryTransfersTableTableManager get inventoryTransfers =>
      $$InventoryTransfersTableTableManager(_db, _db.inventoryTransfers);
  $$AuditEventsTableTableManager get auditEvents =>
      $$AuditEventsTableTableManager(_db, _db.auditEvents);
  $$SyncOutboxEventsTableTableManager get syncOutboxEvents =>
      $$SyncOutboxEventsTableTableManager(_db, _db.syncOutboxEvents);
  $$HardwareJobsTableTableManager get hardwareJobs =>
      $$HardwareJobsTableTableManager(_db, _db.hardwareJobs);
  $$SupplierConnectorsTableTableManager get supplierConnectors =>
      $$SupplierConnectorsTableTableManager(_db, _db.supplierConnectors);
  $$SupplierProductSubscriptionsTableTableManager
      get supplierProductSubscriptions =>
          $$SupplierProductSubscriptionsTableTableManager(
              _db, _db.supplierProductSubscriptions);
  $$SupplierDeliveryJobsTableTableManager get supplierDeliveryJobs =>
      $$SupplierDeliveryJobsTableTableManager(_db, _db.supplierDeliveryJobs);
}
