// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_database.dart';

// ignore_for_file: type=lint
class $TelescopesTable extends Telescopes
    with TableInfo<$TelescopesTable, TelescopeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelescopesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apertureMmMeta = const VerificationMeta(
    'apertureMm',
  );
  @override
  late final GeneratedColumn<double> apertureMm = GeneratedColumn<double>(
    'aperture_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focalLengthMmMeta = const VerificationMeta(
    'focalLengthMm',
  );
  @override
  late final GeneratedColumn<double> focalLengthMm = GeneratedColumn<double>(
    'focal_length_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    apertureMm,
    focalLengthMm,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telescopes';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelescopeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('aperture_mm')) {
      context.handle(
        _apertureMmMeta,
        apertureMm.isAcceptableOrUnknown(data['aperture_mm']!, _apertureMmMeta),
      );
    } else if (isInserting) {
      context.missing(_apertureMmMeta);
    }
    if (data.containsKey('focal_length_mm')) {
      context.handle(
        _focalLengthMmMeta,
        focalLengthMm.isAcceptableOrUnknown(
          data['focal_length_mm']!,
          _focalLengthMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_focalLengthMmMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelescopeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelescopeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      apertureMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aperture_mm'],
      )!,
      focalLengthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focal_length_mm'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $TelescopesTable createAlias(String alias) {
    return $TelescopesTable(attachedDatabase, alias);
  }
}

class TelescopeRow extends DataClass implements Insertable<TelescopeRow> {
  final String id;
  final String name;
  final String type;
  final double apertureMm;
  final double focalLengthMm;
  final String? note;
  const TelescopeRow({
    required this.id,
    required this.name,
    required this.type,
    required this.apertureMm,
    required this.focalLengthMm,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['aperture_mm'] = Variable<double>(apertureMm);
    map['focal_length_mm'] = Variable<double>(focalLengthMm);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TelescopesCompanion toCompanion(bool nullToAbsent) {
    return TelescopesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      apertureMm: Value(apertureMm),
      focalLengthMm: Value(focalLengthMm),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory TelescopeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelescopeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      apertureMm: serializer.fromJson<double>(json['apertureMm']),
      focalLengthMm: serializer.fromJson<double>(json['focalLengthMm']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'apertureMm': serializer.toJson<double>(apertureMm),
      'focalLengthMm': serializer.toJson<double>(focalLengthMm),
      'note': serializer.toJson<String?>(note),
    };
  }

  TelescopeRow copyWith({
    String? id,
    String? name,
    String? type,
    double? apertureMm,
    double? focalLengthMm,
    Value<String?> note = const Value.absent(),
  }) => TelescopeRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    apertureMm: apertureMm ?? this.apertureMm,
    focalLengthMm: focalLengthMm ?? this.focalLengthMm,
    note: note.present ? note.value : this.note,
  );
  TelescopeRow copyWithCompanion(TelescopesCompanion data) {
    return TelescopeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      apertureMm: data.apertureMm.present
          ? data.apertureMm.value
          : this.apertureMm,
      focalLengthMm: data.focalLengthMm.present
          ? data.focalLengthMm.value
          : this.focalLengthMm,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelescopeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('apertureMm: $apertureMm, ')
          ..write('focalLengthMm: $focalLengthMm, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, apertureMm, focalLengthMm, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelescopeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.apertureMm == this.apertureMm &&
          other.focalLengthMm == this.focalLengthMm &&
          other.note == this.note);
}

class TelescopesCompanion extends UpdateCompanion<TelescopeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> apertureMm;
  final Value<double> focalLengthMm;
  final Value<String?> note;
  final Value<int> rowid;
  const TelescopesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.apertureMm = const Value.absent(),
    this.focalLengthMm = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TelescopesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required double apertureMm,
    required double focalLengthMm,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       apertureMm = Value(apertureMm),
       focalLengthMm = Value(focalLengthMm);
  static Insertable<TelescopeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? apertureMm,
    Expression<double>? focalLengthMm,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (apertureMm != null) 'aperture_mm': apertureMm,
      if (focalLengthMm != null) 'focal_length_mm': focalLengthMm,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TelescopesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<double>? apertureMm,
    Value<double>? focalLengthMm,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return TelescopesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      apertureMm: apertureMm ?? this.apertureMm,
      focalLengthMm: focalLengthMm ?? this.focalLengthMm,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (apertureMm.present) {
      map['aperture_mm'] = Variable<double>(apertureMm.value);
    }
    if (focalLengthMm.present) {
      map['focal_length_mm'] = Variable<double>(focalLengthMm.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelescopesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('apertureMm: $apertureMm, ')
          ..write('focalLengthMm: $focalLengthMm, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CamerasTable extends Cameras with TableInfo<$CamerasTable, CameraRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CamerasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensorWidthMmMeta = const VerificationMeta(
    'sensorWidthMm',
  );
  @override
  late final GeneratedColumn<double> sensorWidthMm = GeneratedColumn<double>(
    'sensor_width_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensorHeightMmMeta = const VerificationMeta(
    'sensorHeightMm',
  );
  @override
  late final GeneratedColumn<double> sensorHeightMm = GeneratedColumn<double>(
    'sensor_height_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pixelSizeUmMeta = const VerificationMeta(
    'pixelSizeUm',
  );
  @override
  late final GeneratedColumn<double> pixelSizeUm = GeneratedColumn<double>(
    'pixel_size_um',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionXMeta = const VerificationMeta(
    'resolutionX',
  );
  @override
  late final GeneratedColumn<int> resolutionX = GeneratedColumn<int>(
    'resolution_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionYMeta = const VerificationMeta(
    'resolutionY',
  );
  @override
  late final GeneratedColumn<int> resolutionY = GeneratedColumn<int>(
    'resolution_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensorTypeMeta = const VerificationMeta(
    'sensorType',
  );
  @override
  late final GeneratedColumn<String> sensorType = GeneratedColumn<String>(
    'sensor_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isColorMeta = const VerificationMeta(
    'isColor',
  );
  @override
  late final GeneratedColumn<bool> isColor = GeneratedColumn<bool>(
    'is_color',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_color" IN (0, 1))',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sensorWidthMm,
    sensorHeightMm,
    pixelSizeUm,
    resolutionX,
    resolutionY,
    sensorType,
    isColor,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cameras';
  @override
  VerificationContext validateIntegrity(
    Insertable<CameraRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sensor_width_mm')) {
      context.handle(
        _sensorWidthMmMeta,
        sensorWidthMm.isAcceptableOrUnknown(
          data['sensor_width_mm']!,
          _sensorWidthMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sensorWidthMmMeta);
    }
    if (data.containsKey('sensor_height_mm')) {
      context.handle(
        _sensorHeightMmMeta,
        sensorHeightMm.isAcceptableOrUnknown(
          data['sensor_height_mm']!,
          _sensorHeightMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sensorHeightMmMeta);
    }
    if (data.containsKey('pixel_size_um')) {
      context.handle(
        _pixelSizeUmMeta,
        pixelSizeUm.isAcceptableOrUnknown(
          data['pixel_size_um']!,
          _pixelSizeUmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pixelSizeUmMeta);
    }
    if (data.containsKey('resolution_x')) {
      context.handle(
        _resolutionXMeta,
        resolutionX.isAcceptableOrUnknown(
          data['resolution_x']!,
          _resolutionXMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolutionXMeta);
    }
    if (data.containsKey('resolution_y')) {
      context.handle(
        _resolutionYMeta,
        resolutionY.isAcceptableOrUnknown(
          data['resolution_y']!,
          _resolutionYMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolutionYMeta);
    }
    if (data.containsKey('sensor_type')) {
      context.handle(
        _sensorTypeMeta,
        sensorType.isAcceptableOrUnknown(data['sensor_type']!, _sensorTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sensorTypeMeta);
    }
    if (data.containsKey('is_color')) {
      context.handle(
        _isColorMeta,
        isColor.isAcceptableOrUnknown(data['is_color']!, _isColorMeta),
      );
    } else if (isInserting) {
      context.missing(_isColorMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CameraRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CameraRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sensorWidthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sensor_width_mm'],
      )!,
      sensorHeightMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sensor_height_mm'],
      )!,
      pixelSizeUm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pixel_size_um'],
      )!,
      resolutionX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolution_x'],
      )!,
      resolutionY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolution_y'],
      )!,
      sensorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensor_type'],
      )!,
      isColor: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_color'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $CamerasTable createAlias(String alias) {
    return $CamerasTable(attachedDatabase, alias);
  }
}

class CameraRow extends DataClass implements Insertable<CameraRow> {
  final String id;
  final String name;
  final double sensorWidthMm;
  final double sensorHeightMm;
  final double pixelSizeUm;
  final int resolutionX;
  final int resolutionY;
  final String sensorType;
  final bool isColor;
  final String? note;
  const CameraRow({
    required this.id,
    required this.name,
    required this.sensorWidthMm,
    required this.sensorHeightMm,
    required this.pixelSizeUm,
    required this.resolutionX,
    required this.resolutionY,
    required this.sensorType,
    required this.isColor,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sensor_width_mm'] = Variable<double>(sensorWidthMm);
    map['sensor_height_mm'] = Variable<double>(sensorHeightMm);
    map['pixel_size_um'] = Variable<double>(pixelSizeUm);
    map['resolution_x'] = Variable<int>(resolutionX);
    map['resolution_y'] = Variable<int>(resolutionY);
    map['sensor_type'] = Variable<String>(sensorType);
    map['is_color'] = Variable<bool>(isColor);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  CamerasCompanion toCompanion(bool nullToAbsent) {
    return CamerasCompanion(
      id: Value(id),
      name: Value(name),
      sensorWidthMm: Value(sensorWidthMm),
      sensorHeightMm: Value(sensorHeightMm),
      pixelSizeUm: Value(pixelSizeUm),
      resolutionX: Value(resolutionX),
      resolutionY: Value(resolutionY),
      sensorType: Value(sensorType),
      isColor: Value(isColor),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory CameraRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CameraRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sensorWidthMm: serializer.fromJson<double>(json['sensorWidthMm']),
      sensorHeightMm: serializer.fromJson<double>(json['sensorHeightMm']),
      pixelSizeUm: serializer.fromJson<double>(json['pixelSizeUm']),
      resolutionX: serializer.fromJson<int>(json['resolutionX']),
      resolutionY: serializer.fromJson<int>(json['resolutionY']),
      sensorType: serializer.fromJson<String>(json['sensorType']),
      isColor: serializer.fromJson<bool>(json['isColor']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sensorWidthMm': serializer.toJson<double>(sensorWidthMm),
      'sensorHeightMm': serializer.toJson<double>(sensorHeightMm),
      'pixelSizeUm': serializer.toJson<double>(pixelSizeUm),
      'resolutionX': serializer.toJson<int>(resolutionX),
      'resolutionY': serializer.toJson<int>(resolutionY),
      'sensorType': serializer.toJson<String>(sensorType),
      'isColor': serializer.toJson<bool>(isColor),
      'note': serializer.toJson<String?>(note),
    };
  }

  CameraRow copyWith({
    String? id,
    String? name,
    double? sensorWidthMm,
    double? sensorHeightMm,
    double? pixelSizeUm,
    int? resolutionX,
    int? resolutionY,
    String? sensorType,
    bool? isColor,
    Value<String?> note = const Value.absent(),
  }) => CameraRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sensorWidthMm: sensorWidthMm ?? this.sensorWidthMm,
    sensorHeightMm: sensorHeightMm ?? this.sensorHeightMm,
    pixelSizeUm: pixelSizeUm ?? this.pixelSizeUm,
    resolutionX: resolutionX ?? this.resolutionX,
    resolutionY: resolutionY ?? this.resolutionY,
    sensorType: sensorType ?? this.sensorType,
    isColor: isColor ?? this.isColor,
    note: note.present ? note.value : this.note,
  );
  CameraRow copyWithCompanion(CamerasCompanion data) {
    return CameraRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sensorWidthMm: data.sensorWidthMm.present
          ? data.sensorWidthMm.value
          : this.sensorWidthMm,
      sensorHeightMm: data.sensorHeightMm.present
          ? data.sensorHeightMm.value
          : this.sensorHeightMm,
      pixelSizeUm: data.pixelSizeUm.present
          ? data.pixelSizeUm.value
          : this.pixelSizeUm,
      resolutionX: data.resolutionX.present
          ? data.resolutionX.value
          : this.resolutionX,
      resolutionY: data.resolutionY.present
          ? data.resolutionY.value
          : this.resolutionY,
      sensorType: data.sensorType.present
          ? data.sensorType.value
          : this.sensorType,
      isColor: data.isColor.present ? data.isColor.value : this.isColor,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CameraRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sensorWidthMm: $sensorWidthMm, ')
          ..write('sensorHeightMm: $sensorHeightMm, ')
          ..write('pixelSizeUm: $pixelSizeUm, ')
          ..write('resolutionX: $resolutionX, ')
          ..write('resolutionY: $resolutionY, ')
          ..write('sensorType: $sensorType, ')
          ..write('isColor: $isColor, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sensorWidthMm,
    sensorHeightMm,
    pixelSizeUm,
    resolutionX,
    resolutionY,
    sensorType,
    isColor,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CameraRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sensorWidthMm == this.sensorWidthMm &&
          other.sensorHeightMm == this.sensorHeightMm &&
          other.pixelSizeUm == this.pixelSizeUm &&
          other.resolutionX == this.resolutionX &&
          other.resolutionY == this.resolutionY &&
          other.sensorType == this.sensorType &&
          other.isColor == this.isColor &&
          other.note == this.note);
}

class CamerasCompanion extends UpdateCompanion<CameraRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> sensorWidthMm;
  final Value<double> sensorHeightMm;
  final Value<double> pixelSizeUm;
  final Value<int> resolutionX;
  final Value<int> resolutionY;
  final Value<String> sensorType;
  final Value<bool> isColor;
  final Value<String?> note;
  final Value<int> rowid;
  const CamerasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sensorWidthMm = const Value.absent(),
    this.sensorHeightMm = const Value.absent(),
    this.pixelSizeUm = const Value.absent(),
    this.resolutionX = const Value.absent(),
    this.resolutionY = const Value.absent(),
    this.sensorType = const Value.absent(),
    this.isColor = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CamerasCompanion.insert({
    required String id,
    required String name,
    required double sensorWidthMm,
    required double sensorHeightMm,
    required double pixelSizeUm,
    required int resolutionX,
    required int resolutionY,
    required String sensorType,
    required bool isColor,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sensorWidthMm = Value(sensorWidthMm),
       sensorHeightMm = Value(sensorHeightMm),
       pixelSizeUm = Value(pixelSizeUm),
       resolutionX = Value(resolutionX),
       resolutionY = Value(resolutionY),
       sensorType = Value(sensorType),
       isColor = Value(isColor);
  static Insertable<CameraRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? sensorWidthMm,
    Expression<double>? sensorHeightMm,
    Expression<double>? pixelSizeUm,
    Expression<int>? resolutionX,
    Expression<int>? resolutionY,
    Expression<String>? sensorType,
    Expression<bool>? isColor,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sensorWidthMm != null) 'sensor_width_mm': sensorWidthMm,
      if (sensorHeightMm != null) 'sensor_height_mm': sensorHeightMm,
      if (pixelSizeUm != null) 'pixel_size_um': pixelSizeUm,
      if (resolutionX != null) 'resolution_x': resolutionX,
      if (resolutionY != null) 'resolution_y': resolutionY,
      if (sensorType != null) 'sensor_type': sensorType,
      if (isColor != null) 'is_color': isColor,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CamerasCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? sensorWidthMm,
    Value<double>? sensorHeightMm,
    Value<double>? pixelSizeUm,
    Value<int>? resolutionX,
    Value<int>? resolutionY,
    Value<String>? sensorType,
    Value<bool>? isColor,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return CamerasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sensorWidthMm: sensorWidthMm ?? this.sensorWidthMm,
      sensorHeightMm: sensorHeightMm ?? this.sensorHeightMm,
      pixelSizeUm: pixelSizeUm ?? this.pixelSizeUm,
      resolutionX: resolutionX ?? this.resolutionX,
      resolutionY: resolutionY ?? this.resolutionY,
      sensorType: sensorType ?? this.sensorType,
      isColor: isColor ?? this.isColor,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sensorWidthMm.present) {
      map['sensor_width_mm'] = Variable<double>(sensorWidthMm.value);
    }
    if (sensorHeightMm.present) {
      map['sensor_height_mm'] = Variable<double>(sensorHeightMm.value);
    }
    if (pixelSizeUm.present) {
      map['pixel_size_um'] = Variable<double>(pixelSizeUm.value);
    }
    if (resolutionX.present) {
      map['resolution_x'] = Variable<int>(resolutionX.value);
    }
    if (resolutionY.present) {
      map['resolution_y'] = Variable<int>(resolutionY.value);
    }
    if (sensorType.present) {
      map['sensor_type'] = Variable<String>(sensorType.value);
    }
    if (isColor.present) {
      map['is_color'] = Variable<bool>(isColor.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CamerasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sensorWidthMm: $sensorWidthMm, ')
          ..write('sensorHeightMm: $sensorHeightMm, ')
          ..write('pixelSizeUm: $pixelSizeUm, ')
          ..write('resolutionX: $resolutionX, ')
          ..write('resolutionY: $resolutionY, ')
          ..write('sensorType: $sensorType, ')
          ..write('isColor: $isColor, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EyepiecesTable extends Eyepieces
    with TableInfo<$EyepiecesTable, EyepieceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EyepiecesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focalLengthMmMeta = const VerificationMeta(
    'focalLengthMm',
  );
  @override
  late final GeneratedColumn<double> focalLengthMm = GeneratedColumn<double>(
    'focal_length_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apparentFovDegMeta = const VerificationMeta(
    'apparentFovDeg',
  );
  @override
  late final GeneratedColumn<double> apparentFovDeg = GeneratedColumn<double>(
    'apparent_fov_deg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barrelSizeMeta = const VerificationMeta(
    'barrelSize',
  );
  @override
  late final GeneratedColumn<String> barrelSize = GeneratedColumn<String>(
    'barrel_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    focalLengthMm,
    apparentFovDeg,
    barrelSize,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eyepieces';
  @override
  VerificationContext validateIntegrity(
    Insertable<EyepieceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('focal_length_mm')) {
      context.handle(
        _focalLengthMmMeta,
        focalLengthMm.isAcceptableOrUnknown(
          data['focal_length_mm']!,
          _focalLengthMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_focalLengthMmMeta);
    }
    if (data.containsKey('apparent_fov_deg')) {
      context.handle(
        _apparentFovDegMeta,
        apparentFovDeg.isAcceptableOrUnknown(
          data['apparent_fov_deg']!,
          _apparentFovDegMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apparentFovDegMeta);
    }
    if (data.containsKey('barrel_size')) {
      context.handle(
        _barrelSizeMeta,
        barrelSize.isAcceptableOrUnknown(data['barrel_size']!, _barrelSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_barrelSizeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EyepieceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EyepieceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      focalLengthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focal_length_mm'],
      )!,
      apparentFovDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}apparent_fov_deg'],
      )!,
      barrelSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barrel_size'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $EyepiecesTable createAlias(String alias) {
    return $EyepiecesTable(attachedDatabase, alias);
  }
}

class EyepieceRow extends DataClass implements Insertable<EyepieceRow> {
  final String id;
  final String name;
  final double focalLengthMm;
  final double apparentFovDeg;
  final String barrelSize;
  final String? note;
  const EyepieceRow({
    required this.id,
    required this.name,
    required this.focalLengthMm,
    required this.apparentFovDeg,
    required this.barrelSize,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['focal_length_mm'] = Variable<double>(focalLengthMm);
    map['apparent_fov_deg'] = Variable<double>(apparentFovDeg);
    map['barrel_size'] = Variable<String>(barrelSize);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  EyepiecesCompanion toCompanion(bool nullToAbsent) {
    return EyepiecesCompanion(
      id: Value(id),
      name: Value(name),
      focalLengthMm: Value(focalLengthMm),
      apparentFovDeg: Value(apparentFovDeg),
      barrelSize: Value(barrelSize),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory EyepieceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EyepieceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      focalLengthMm: serializer.fromJson<double>(json['focalLengthMm']),
      apparentFovDeg: serializer.fromJson<double>(json['apparentFovDeg']),
      barrelSize: serializer.fromJson<String>(json['barrelSize']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'focalLengthMm': serializer.toJson<double>(focalLengthMm),
      'apparentFovDeg': serializer.toJson<double>(apparentFovDeg),
      'barrelSize': serializer.toJson<String>(barrelSize),
      'note': serializer.toJson<String?>(note),
    };
  }

  EyepieceRow copyWith({
    String? id,
    String? name,
    double? focalLengthMm,
    double? apparentFovDeg,
    String? barrelSize,
    Value<String?> note = const Value.absent(),
  }) => EyepieceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    focalLengthMm: focalLengthMm ?? this.focalLengthMm,
    apparentFovDeg: apparentFovDeg ?? this.apparentFovDeg,
    barrelSize: barrelSize ?? this.barrelSize,
    note: note.present ? note.value : this.note,
  );
  EyepieceRow copyWithCompanion(EyepiecesCompanion data) {
    return EyepieceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      focalLengthMm: data.focalLengthMm.present
          ? data.focalLengthMm.value
          : this.focalLengthMm,
      apparentFovDeg: data.apparentFovDeg.present
          ? data.apparentFovDeg.value
          : this.apparentFovDeg,
      barrelSize: data.barrelSize.present
          ? data.barrelSize.value
          : this.barrelSize,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EyepieceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('focalLengthMm: $focalLengthMm, ')
          ..write('apparentFovDeg: $apparentFovDeg, ')
          ..write('barrelSize: $barrelSize, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, focalLengthMm, apparentFovDeg, barrelSize, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EyepieceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.focalLengthMm == this.focalLengthMm &&
          other.apparentFovDeg == this.apparentFovDeg &&
          other.barrelSize == this.barrelSize &&
          other.note == this.note);
}

class EyepiecesCompanion extends UpdateCompanion<EyepieceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> focalLengthMm;
  final Value<double> apparentFovDeg;
  final Value<String> barrelSize;
  final Value<String?> note;
  final Value<int> rowid;
  const EyepiecesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.focalLengthMm = const Value.absent(),
    this.apparentFovDeg = const Value.absent(),
    this.barrelSize = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EyepiecesCompanion.insert({
    required String id,
    required String name,
    required double focalLengthMm,
    required double apparentFovDeg,
    required String barrelSize,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       focalLengthMm = Value(focalLengthMm),
       apparentFovDeg = Value(apparentFovDeg),
       barrelSize = Value(barrelSize);
  static Insertable<EyepieceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? focalLengthMm,
    Expression<double>? apparentFovDeg,
    Expression<String>? barrelSize,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (focalLengthMm != null) 'focal_length_mm': focalLengthMm,
      if (apparentFovDeg != null) 'apparent_fov_deg': apparentFovDeg,
      if (barrelSize != null) 'barrel_size': barrelSize,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EyepiecesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? focalLengthMm,
    Value<double>? apparentFovDeg,
    Value<String>? barrelSize,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return EyepiecesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      focalLengthMm: focalLengthMm ?? this.focalLengthMm,
      apparentFovDeg: apparentFovDeg ?? this.apparentFovDeg,
      barrelSize: barrelSize ?? this.barrelSize,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (focalLengthMm.present) {
      map['focal_length_mm'] = Variable<double>(focalLengthMm.value);
    }
    if (apparentFovDeg.present) {
      map['apparent_fov_deg'] = Variable<double>(apparentFovDeg.value);
    }
    if (barrelSize.present) {
      map['barrel_size'] = Variable<String>(barrelSize.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EyepiecesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('focalLengthMm: $focalLengthMm, ')
          ..write('apparentFovDeg: $apparentFovDeg, ')
          ..write('barrelSize: $barrelSize, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModifiersTable extends Modifiers
    with TableInfo<$ModifiersTable, ModifierRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModifiersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factorMeta = const VerificationMeta('factor');
  @override
  late final GeneratedColumn<double> factor = GeneratedColumn<double>(
    'factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, kind, factor, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modifiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModifierRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('factor')) {
      context.handle(
        _factorMeta,
        factor.isAcceptableOrUnknown(data['factor']!, _factorMeta),
      );
    } else if (isInserting) {
      context.missing(_factorMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModifierRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModifierRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      factor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}factor'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ModifiersTable createAlias(String alias) {
    return $ModifiersTable(attachedDatabase, alias);
  }
}

class ModifierRow extends DataClass implements Insertable<ModifierRow> {
  final String id;
  final String name;
  final String kind;
  final double factor;
  final String? note;
  const ModifierRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.factor,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['factor'] = Variable<double>(factor);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ModifiersCompanion toCompanion(bool nullToAbsent) {
    return ModifiersCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      factor: Value(factor),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ModifierRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModifierRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      factor: serializer.fromJson<double>(json['factor']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'factor': serializer.toJson<double>(factor),
      'note': serializer.toJson<String?>(note),
    };
  }

  ModifierRow copyWith({
    String? id,
    String? name,
    String? kind,
    double? factor,
    Value<String?> note = const Value.absent(),
  }) => ModifierRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    factor: factor ?? this.factor,
    note: note.present ? note.value : this.note,
  );
  ModifierRow copyWithCompanion(ModifiersCompanion data) {
    return ModifierRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      factor: data.factor.present ? data.factor.value : this.factor,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModifierRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('factor: $factor, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, kind, factor, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModifierRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.factor == this.factor &&
          other.note == this.note);
}

class ModifiersCompanion extends UpdateCompanion<ModifierRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<double> factor;
  final Value<String?> note;
  final Value<int> rowid;
  const ModifiersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.factor = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModifiersCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required double factor,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       factor = Value(factor);
  static Insertable<ModifierRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<double>? factor,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (factor != null) 'factor': factor,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModifiersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<double>? factor,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ModifiersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      factor: factor ?? this.factor,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (factor.present) {
      map['factor'] = Variable<double>(factor.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModifiersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('factor: $factor, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EquipmentSetsTable extends EquipmentSets
    with TableInfo<$EquipmentSetsTable, EquipmentSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telescopeIdMeta = const VerificationMeta(
    'telescopeId',
  );
  @override
  late final GeneratedColumn<String> telescopeId = GeneratedColumn<String>(
    'telescope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cameraIdMeta = const VerificationMeta(
    'cameraId',
  );
  @override
  late final GeneratedColumn<String> cameraId = GeneratedColumn<String>(
    'camera_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eyepieceIdMeta = const VerificationMeta(
    'eyepieceId',
  );
  @override
  late final GeneratedColumn<String> eyepieceId = GeneratedColumn<String>(
    'eyepiece_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifierIdMeta = const VerificationMeta(
    'modifierId',
  );
  @override
  late final GeneratedColumn<String> modifierId = GeneratedColumn<String>(
    'modifier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frameColorArgbMeta = const VerificationMeta(
    'frameColorArgb',
  );
  @override
  late final GeneratedColumn<int> frameColorArgb = GeneratedColumn<int>(
    'frame_color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    telescopeId,
    cameraId,
    eyepieceId,
    modifierId,
    frameColorArgb,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipment_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<EquipmentSetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('telescope_id')) {
      context.handle(
        _telescopeIdMeta,
        telescopeId.isAcceptableOrUnknown(
          data['telescope_id']!,
          _telescopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_telescopeIdMeta);
    }
    if (data.containsKey('camera_id')) {
      context.handle(
        _cameraIdMeta,
        cameraId.isAcceptableOrUnknown(data['camera_id']!, _cameraIdMeta),
      );
    }
    if (data.containsKey('eyepiece_id')) {
      context.handle(
        _eyepieceIdMeta,
        eyepieceId.isAcceptableOrUnknown(data['eyepiece_id']!, _eyepieceIdMeta),
      );
    }
    if (data.containsKey('modifier_id')) {
      context.handle(
        _modifierIdMeta,
        modifierId.isAcceptableOrUnknown(data['modifier_id']!, _modifierIdMeta),
      );
    }
    if (data.containsKey('frame_color_argb')) {
      context.handle(
        _frameColorArgbMeta,
        frameColorArgb.isAcceptableOrUnknown(
          data['frame_color_argb']!,
          _frameColorArgbMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frameColorArgbMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EquipmentSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EquipmentSetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      telescopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telescope_id'],
      )!,
      cameraId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camera_id'],
      ),
      eyepieceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eyepiece_id'],
      ),
      modifierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifier_id'],
      ),
      frameColorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frame_color_argb'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $EquipmentSetsTable createAlias(String alias) {
    return $EquipmentSetsTable(attachedDatabase, alias);
  }
}

class EquipmentSetRow extends DataClass implements Insertable<EquipmentSetRow> {
  final String id;
  final String name;
  final String telescopeId;
  final String? cameraId;
  final String? eyepieceId;
  final String? modifierId;
  final int frameColorArgb;
  final String? note;
  const EquipmentSetRow({
    required this.id,
    required this.name,
    required this.telescopeId,
    this.cameraId,
    this.eyepieceId,
    this.modifierId,
    required this.frameColorArgb,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['telescope_id'] = Variable<String>(telescopeId);
    if (!nullToAbsent || cameraId != null) {
      map['camera_id'] = Variable<String>(cameraId);
    }
    if (!nullToAbsent || eyepieceId != null) {
      map['eyepiece_id'] = Variable<String>(eyepieceId);
    }
    if (!nullToAbsent || modifierId != null) {
      map['modifier_id'] = Variable<String>(modifierId);
    }
    map['frame_color_argb'] = Variable<int>(frameColorArgb);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  EquipmentSetsCompanion toCompanion(bool nullToAbsent) {
    return EquipmentSetsCompanion(
      id: Value(id),
      name: Value(name),
      telescopeId: Value(telescopeId),
      cameraId: cameraId == null && nullToAbsent
          ? const Value.absent()
          : Value(cameraId),
      eyepieceId: eyepieceId == null && nullToAbsent
          ? const Value.absent()
          : Value(eyepieceId),
      modifierId: modifierId == null && nullToAbsent
          ? const Value.absent()
          : Value(modifierId),
      frameColorArgb: Value(frameColorArgb),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory EquipmentSetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EquipmentSetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      telescopeId: serializer.fromJson<String>(json['telescopeId']),
      cameraId: serializer.fromJson<String?>(json['cameraId']),
      eyepieceId: serializer.fromJson<String?>(json['eyepieceId']),
      modifierId: serializer.fromJson<String?>(json['modifierId']),
      frameColorArgb: serializer.fromJson<int>(json['frameColorArgb']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'telescopeId': serializer.toJson<String>(telescopeId),
      'cameraId': serializer.toJson<String?>(cameraId),
      'eyepieceId': serializer.toJson<String?>(eyepieceId),
      'modifierId': serializer.toJson<String?>(modifierId),
      'frameColorArgb': serializer.toJson<int>(frameColorArgb),
      'note': serializer.toJson<String?>(note),
    };
  }

  EquipmentSetRow copyWith({
    String? id,
    String? name,
    String? telescopeId,
    Value<String?> cameraId = const Value.absent(),
    Value<String?> eyepieceId = const Value.absent(),
    Value<String?> modifierId = const Value.absent(),
    int? frameColorArgb,
    Value<String?> note = const Value.absent(),
  }) => EquipmentSetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    telescopeId: telescopeId ?? this.telescopeId,
    cameraId: cameraId.present ? cameraId.value : this.cameraId,
    eyepieceId: eyepieceId.present ? eyepieceId.value : this.eyepieceId,
    modifierId: modifierId.present ? modifierId.value : this.modifierId,
    frameColorArgb: frameColorArgb ?? this.frameColorArgb,
    note: note.present ? note.value : this.note,
  );
  EquipmentSetRow copyWithCompanion(EquipmentSetsCompanion data) {
    return EquipmentSetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      telescopeId: data.telescopeId.present
          ? data.telescopeId.value
          : this.telescopeId,
      cameraId: data.cameraId.present ? data.cameraId.value : this.cameraId,
      eyepieceId: data.eyepieceId.present
          ? data.eyepieceId.value
          : this.eyepieceId,
      modifierId: data.modifierId.present
          ? data.modifierId.value
          : this.modifierId,
      frameColorArgb: data.frameColorArgb.present
          ? data.frameColorArgb.value
          : this.frameColorArgb,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentSetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('telescopeId: $telescopeId, ')
          ..write('cameraId: $cameraId, ')
          ..write('eyepieceId: $eyepieceId, ')
          ..write('modifierId: $modifierId, ')
          ..write('frameColorArgb: $frameColorArgb, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    telescopeId,
    cameraId,
    eyepieceId,
    modifierId,
    frameColorArgb,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EquipmentSetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.telescopeId == this.telescopeId &&
          other.cameraId == this.cameraId &&
          other.eyepieceId == this.eyepieceId &&
          other.modifierId == this.modifierId &&
          other.frameColorArgb == this.frameColorArgb &&
          other.note == this.note);
}

class EquipmentSetsCompanion extends UpdateCompanion<EquipmentSetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> telescopeId;
  final Value<String?> cameraId;
  final Value<String?> eyepieceId;
  final Value<String?> modifierId;
  final Value<int> frameColorArgb;
  final Value<String?> note;
  final Value<int> rowid;
  const EquipmentSetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.telescopeId = const Value.absent(),
    this.cameraId = const Value.absent(),
    this.eyepieceId = const Value.absent(),
    this.modifierId = const Value.absent(),
    this.frameColorArgb = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EquipmentSetsCompanion.insert({
    required String id,
    required String name,
    required String telescopeId,
    this.cameraId = const Value.absent(),
    this.eyepieceId = const Value.absent(),
    this.modifierId = const Value.absent(),
    required int frameColorArgb,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       telescopeId = Value(telescopeId),
       frameColorArgb = Value(frameColorArgb);
  static Insertable<EquipmentSetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? telescopeId,
    Expression<String>? cameraId,
    Expression<String>? eyepieceId,
    Expression<String>? modifierId,
    Expression<int>? frameColorArgb,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (telescopeId != null) 'telescope_id': telescopeId,
      if (cameraId != null) 'camera_id': cameraId,
      if (eyepieceId != null) 'eyepiece_id': eyepieceId,
      if (modifierId != null) 'modifier_id': modifierId,
      if (frameColorArgb != null) 'frame_color_argb': frameColorArgb,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EquipmentSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? telescopeId,
    Value<String?>? cameraId,
    Value<String?>? eyepieceId,
    Value<String?>? modifierId,
    Value<int>? frameColorArgb,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return EquipmentSetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      telescopeId: telescopeId ?? this.telescopeId,
      cameraId: cameraId ?? this.cameraId,
      eyepieceId: eyepieceId ?? this.eyepieceId,
      modifierId: modifierId ?? this.modifierId,
      frameColorArgb: frameColorArgb ?? this.frameColorArgb,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (telescopeId.present) {
      map['telescope_id'] = Variable<String>(telescopeId.value);
    }
    if (cameraId.present) {
      map['camera_id'] = Variable<String>(cameraId.value);
    }
    if (eyepieceId.present) {
      map['eyepiece_id'] = Variable<String>(eyepieceId.value);
    }
    if (modifierId.present) {
      map['modifier_id'] = Variable<String>(modifierId.value);
    }
    if (frameColorArgb.present) {
      map['frame_color_argb'] = Variable<int>(frameColorArgb.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentSetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('telescopeId: $telescopeId, ')
          ..write('cameraId: $cameraId, ')
          ..write('eyepieceId: $eyepieceId, ')
          ..write('modifierId: $modifierId, ')
          ..write('frameColorArgb: $frameColorArgb, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$EquipmentDatabase extends GeneratedDatabase {
  _$EquipmentDatabase(QueryExecutor e) : super(e);
  $EquipmentDatabaseManager get managers => $EquipmentDatabaseManager(this);
  late final $TelescopesTable telescopes = $TelescopesTable(this);
  late final $CamerasTable cameras = $CamerasTable(this);
  late final $EyepiecesTable eyepieces = $EyepiecesTable(this);
  late final $ModifiersTable modifiers = $ModifiersTable(this);
  late final $EquipmentSetsTable equipmentSets = $EquipmentSetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    telescopes,
    cameras,
    eyepieces,
    modifiers,
    equipmentSets,
  ];
}

typedef $$TelescopesTableCreateCompanionBuilder =
    TelescopesCompanion Function({
      required String id,
      required String name,
      required String type,
      required double apertureMm,
      required double focalLengthMm,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$TelescopesTableUpdateCompanionBuilder =
    TelescopesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<double> apertureMm,
      Value<double> focalLengthMm,
      Value<String?> note,
      Value<int> rowid,
    });

class $$TelescopesTableFilterComposer
    extends Composer<_$EquipmentDatabase, $TelescopesTable> {
  $$TelescopesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get apertureMm => $composableBuilder(
    column: $table.apertureMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TelescopesTableOrderingComposer
    extends Composer<_$EquipmentDatabase, $TelescopesTable> {
  $$TelescopesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get apertureMm => $composableBuilder(
    column: $table.apertureMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TelescopesTableAnnotationComposer
    extends Composer<_$EquipmentDatabase, $TelescopesTable> {
  $$TelescopesTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get apertureMm => $composableBuilder(
    column: $table.apertureMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TelescopesTableTableManager
    extends
        RootTableManager<
          _$EquipmentDatabase,
          $TelescopesTable,
          TelescopeRow,
          $$TelescopesTableFilterComposer,
          $$TelescopesTableOrderingComposer,
          $$TelescopesTableAnnotationComposer,
          $$TelescopesTableCreateCompanionBuilder,
          $$TelescopesTableUpdateCompanionBuilder,
          (
            TelescopeRow,
            BaseReferences<_$EquipmentDatabase, $TelescopesTable, TelescopeRow>,
          ),
          TelescopeRow,
          PrefetchHooks Function()
        > {
  $$TelescopesTableTableManager(_$EquipmentDatabase db, $TelescopesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelescopesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelescopesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelescopesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> apertureMm = const Value.absent(),
                Value<double> focalLengthMm = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TelescopesCompanion(
                id: id,
                name: name,
                type: type,
                apertureMm: apertureMm,
                focalLengthMm: focalLengthMm,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required double apertureMm,
                required double focalLengthMm,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TelescopesCompanion.insert(
                id: id,
                name: name,
                type: type,
                apertureMm: apertureMm,
                focalLengthMm: focalLengthMm,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TelescopesTableProcessedTableManager =
    ProcessedTableManager<
      _$EquipmentDatabase,
      $TelescopesTable,
      TelescopeRow,
      $$TelescopesTableFilterComposer,
      $$TelescopesTableOrderingComposer,
      $$TelescopesTableAnnotationComposer,
      $$TelescopesTableCreateCompanionBuilder,
      $$TelescopesTableUpdateCompanionBuilder,
      (
        TelescopeRow,
        BaseReferences<_$EquipmentDatabase, $TelescopesTable, TelescopeRow>,
      ),
      TelescopeRow,
      PrefetchHooks Function()
    >;
typedef $$CamerasTableCreateCompanionBuilder =
    CamerasCompanion Function({
      required String id,
      required String name,
      required double sensorWidthMm,
      required double sensorHeightMm,
      required double pixelSizeUm,
      required int resolutionX,
      required int resolutionY,
      required String sensorType,
      required bool isColor,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$CamerasTableUpdateCompanionBuilder =
    CamerasCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> sensorWidthMm,
      Value<double> sensorHeightMm,
      Value<double> pixelSizeUm,
      Value<int> resolutionX,
      Value<int> resolutionY,
      Value<String> sensorType,
      Value<bool> isColor,
      Value<String?> note,
      Value<int> rowid,
    });

class $$CamerasTableFilterComposer
    extends Composer<_$EquipmentDatabase, $CamerasTable> {
  $$CamerasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sensorWidthMm => $composableBuilder(
    column: $table.sensorWidthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sensorHeightMm => $composableBuilder(
    column: $table.sensorHeightMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pixelSizeUm => $composableBuilder(
    column: $table.pixelSizeUm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolutionX => $composableBuilder(
    column: $table.resolutionX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolutionY => $composableBuilder(
    column: $table.resolutionY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isColor => $composableBuilder(
    column: $table.isColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CamerasTableOrderingComposer
    extends Composer<_$EquipmentDatabase, $CamerasTable> {
  $$CamerasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sensorWidthMm => $composableBuilder(
    column: $table.sensorWidthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sensorHeightMm => $composableBuilder(
    column: $table.sensorHeightMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pixelSizeUm => $composableBuilder(
    column: $table.pixelSizeUm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolutionX => $composableBuilder(
    column: $table.resolutionX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolutionY => $composableBuilder(
    column: $table.resolutionY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isColor => $composableBuilder(
    column: $table.isColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CamerasTableAnnotationComposer
    extends Composer<_$EquipmentDatabase, $CamerasTable> {
  $$CamerasTableAnnotationComposer({
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

  GeneratedColumn<double> get sensorWidthMm => $composableBuilder(
    column: $table.sensorWidthMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sensorHeightMm => $composableBuilder(
    column: $table.sensorHeightMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pixelSizeUm => $composableBuilder(
    column: $table.pixelSizeUm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolutionX => $composableBuilder(
    column: $table.resolutionX,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolutionY => $composableBuilder(
    column: $table.resolutionY,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isColor =>
      $composableBuilder(column: $table.isColor, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$CamerasTableTableManager
    extends
        RootTableManager<
          _$EquipmentDatabase,
          $CamerasTable,
          CameraRow,
          $$CamerasTableFilterComposer,
          $$CamerasTableOrderingComposer,
          $$CamerasTableAnnotationComposer,
          $$CamerasTableCreateCompanionBuilder,
          $$CamerasTableUpdateCompanionBuilder,
          (
            CameraRow,
            BaseReferences<_$EquipmentDatabase, $CamerasTable, CameraRow>,
          ),
          CameraRow,
          PrefetchHooks Function()
        > {
  $$CamerasTableTableManager(_$EquipmentDatabase db, $CamerasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CamerasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CamerasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CamerasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> sensorWidthMm = const Value.absent(),
                Value<double> sensorHeightMm = const Value.absent(),
                Value<double> pixelSizeUm = const Value.absent(),
                Value<int> resolutionX = const Value.absent(),
                Value<int> resolutionY = const Value.absent(),
                Value<String> sensorType = const Value.absent(),
                Value<bool> isColor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CamerasCompanion(
                id: id,
                name: name,
                sensorWidthMm: sensorWidthMm,
                sensorHeightMm: sensorHeightMm,
                pixelSizeUm: pixelSizeUm,
                resolutionX: resolutionX,
                resolutionY: resolutionY,
                sensorType: sensorType,
                isColor: isColor,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double sensorWidthMm,
                required double sensorHeightMm,
                required double pixelSizeUm,
                required int resolutionX,
                required int resolutionY,
                required String sensorType,
                required bool isColor,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CamerasCompanion.insert(
                id: id,
                name: name,
                sensorWidthMm: sensorWidthMm,
                sensorHeightMm: sensorHeightMm,
                pixelSizeUm: pixelSizeUm,
                resolutionX: resolutionX,
                resolutionY: resolutionY,
                sensorType: sensorType,
                isColor: isColor,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CamerasTableProcessedTableManager =
    ProcessedTableManager<
      _$EquipmentDatabase,
      $CamerasTable,
      CameraRow,
      $$CamerasTableFilterComposer,
      $$CamerasTableOrderingComposer,
      $$CamerasTableAnnotationComposer,
      $$CamerasTableCreateCompanionBuilder,
      $$CamerasTableUpdateCompanionBuilder,
      (
        CameraRow,
        BaseReferences<_$EquipmentDatabase, $CamerasTable, CameraRow>,
      ),
      CameraRow,
      PrefetchHooks Function()
    >;
typedef $$EyepiecesTableCreateCompanionBuilder =
    EyepiecesCompanion Function({
      required String id,
      required String name,
      required double focalLengthMm,
      required double apparentFovDeg,
      required String barrelSize,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$EyepiecesTableUpdateCompanionBuilder =
    EyepiecesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> focalLengthMm,
      Value<double> apparentFovDeg,
      Value<String> barrelSize,
      Value<String?> note,
      Value<int> rowid,
    });

class $$EyepiecesTableFilterComposer
    extends Composer<_$EquipmentDatabase, $EyepiecesTable> {
  $$EyepiecesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get apparentFovDeg => $composableBuilder(
    column: $table.apparentFovDeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barrelSize => $composableBuilder(
    column: $table.barrelSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EyepiecesTableOrderingComposer
    extends Composer<_$EquipmentDatabase, $EyepiecesTable> {
  $$EyepiecesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get apparentFovDeg => $composableBuilder(
    column: $table.apparentFovDeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barrelSize => $composableBuilder(
    column: $table.barrelSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EyepiecesTableAnnotationComposer
    extends Composer<_$EquipmentDatabase, $EyepiecesTable> {
  $$EyepiecesTableAnnotationComposer({
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

  GeneratedColumn<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get apparentFovDeg => $composableBuilder(
    column: $table.apparentFovDeg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barrelSize => $composableBuilder(
    column: $table.barrelSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$EyepiecesTableTableManager
    extends
        RootTableManager<
          _$EquipmentDatabase,
          $EyepiecesTable,
          EyepieceRow,
          $$EyepiecesTableFilterComposer,
          $$EyepiecesTableOrderingComposer,
          $$EyepiecesTableAnnotationComposer,
          $$EyepiecesTableCreateCompanionBuilder,
          $$EyepiecesTableUpdateCompanionBuilder,
          (
            EyepieceRow,
            BaseReferences<_$EquipmentDatabase, $EyepiecesTable, EyepieceRow>,
          ),
          EyepieceRow,
          PrefetchHooks Function()
        > {
  $$EyepiecesTableTableManager(_$EquipmentDatabase db, $EyepiecesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EyepiecesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EyepiecesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EyepiecesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> focalLengthMm = const Value.absent(),
                Value<double> apparentFovDeg = const Value.absent(),
                Value<String> barrelSize = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EyepiecesCompanion(
                id: id,
                name: name,
                focalLengthMm: focalLengthMm,
                apparentFovDeg: apparentFovDeg,
                barrelSize: barrelSize,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double focalLengthMm,
                required double apparentFovDeg,
                required String barrelSize,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EyepiecesCompanion.insert(
                id: id,
                name: name,
                focalLengthMm: focalLengthMm,
                apparentFovDeg: apparentFovDeg,
                barrelSize: barrelSize,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EyepiecesTableProcessedTableManager =
    ProcessedTableManager<
      _$EquipmentDatabase,
      $EyepiecesTable,
      EyepieceRow,
      $$EyepiecesTableFilterComposer,
      $$EyepiecesTableOrderingComposer,
      $$EyepiecesTableAnnotationComposer,
      $$EyepiecesTableCreateCompanionBuilder,
      $$EyepiecesTableUpdateCompanionBuilder,
      (
        EyepieceRow,
        BaseReferences<_$EquipmentDatabase, $EyepiecesTable, EyepieceRow>,
      ),
      EyepieceRow,
      PrefetchHooks Function()
    >;
typedef $$ModifiersTableCreateCompanionBuilder =
    ModifiersCompanion Function({
      required String id,
      required String name,
      required String kind,
      required double factor,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$ModifiersTableUpdateCompanionBuilder =
    ModifiersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<double> factor,
      Value<String?> note,
      Value<int> rowid,
    });

class $$ModifiersTableFilterComposer
    extends Composer<_$EquipmentDatabase, $ModifiersTable> {
  $$ModifiersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModifiersTableOrderingComposer
    extends Composer<_$EquipmentDatabase, $ModifiersTable> {
  $$ModifiersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModifiersTableAnnotationComposer
    extends Composer<_$EquipmentDatabase, $ModifiersTable> {
  $$ModifiersTableAnnotationComposer({
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

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get factor =>
      $composableBuilder(column: $table.factor, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$ModifiersTableTableManager
    extends
        RootTableManager<
          _$EquipmentDatabase,
          $ModifiersTable,
          ModifierRow,
          $$ModifiersTableFilterComposer,
          $$ModifiersTableOrderingComposer,
          $$ModifiersTableAnnotationComposer,
          $$ModifiersTableCreateCompanionBuilder,
          $$ModifiersTableUpdateCompanionBuilder,
          (
            ModifierRow,
            BaseReferences<_$EquipmentDatabase, $ModifiersTable, ModifierRow>,
          ),
          ModifierRow,
          PrefetchHooks Function()
        > {
  $$ModifiersTableTableManager(_$EquipmentDatabase db, $ModifiersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModifiersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModifiersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModifiersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double> factor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModifiersCompanion(
                id: id,
                name: name,
                kind: kind,
                factor: factor,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                required double factor,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModifiersCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                factor: factor,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModifiersTableProcessedTableManager =
    ProcessedTableManager<
      _$EquipmentDatabase,
      $ModifiersTable,
      ModifierRow,
      $$ModifiersTableFilterComposer,
      $$ModifiersTableOrderingComposer,
      $$ModifiersTableAnnotationComposer,
      $$ModifiersTableCreateCompanionBuilder,
      $$ModifiersTableUpdateCompanionBuilder,
      (
        ModifierRow,
        BaseReferences<_$EquipmentDatabase, $ModifiersTable, ModifierRow>,
      ),
      ModifierRow,
      PrefetchHooks Function()
    >;
typedef $$EquipmentSetsTableCreateCompanionBuilder =
    EquipmentSetsCompanion Function({
      required String id,
      required String name,
      required String telescopeId,
      Value<String?> cameraId,
      Value<String?> eyepieceId,
      Value<String?> modifierId,
      required int frameColorArgb,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$EquipmentSetsTableUpdateCompanionBuilder =
    EquipmentSetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> telescopeId,
      Value<String?> cameraId,
      Value<String?> eyepieceId,
      Value<String?> modifierId,
      Value<int> frameColorArgb,
      Value<String?> note,
      Value<int> rowid,
    });

class $$EquipmentSetsTableFilterComposer
    extends Composer<_$EquipmentDatabase, $EquipmentSetsTable> {
  $$EquipmentSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telescopeId => $composableBuilder(
    column: $table.telescopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cameraId => $composableBuilder(
    column: $table.cameraId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eyepieceId => $composableBuilder(
    column: $table.eyepieceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifierId => $composableBuilder(
    column: $table.modifierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frameColorArgb => $composableBuilder(
    column: $table.frameColorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EquipmentSetsTableOrderingComposer
    extends Composer<_$EquipmentDatabase, $EquipmentSetsTable> {
  $$EquipmentSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telescopeId => $composableBuilder(
    column: $table.telescopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cameraId => $composableBuilder(
    column: $table.cameraId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eyepieceId => $composableBuilder(
    column: $table.eyepieceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifierId => $composableBuilder(
    column: $table.modifierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frameColorArgb => $composableBuilder(
    column: $table.frameColorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EquipmentSetsTableAnnotationComposer
    extends Composer<_$EquipmentDatabase, $EquipmentSetsTable> {
  $$EquipmentSetsTableAnnotationComposer({
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

  GeneratedColumn<String> get telescopeId => $composableBuilder(
    column: $table.telescopeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cameraId =>
      $composableBuilder(column: $table.cameraId, builder: (column) => column);

  GeneratedColumn<String> get eyepieceId => $composableBuilder(
    column: $table.eyepieceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modifierId => $composableBuilder(
    column: $table.modifierId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frameColorArgb => $composableBuilder(
    column: $table.frameColorArgb,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$EquipmentSetsTableTableManager
    extends
        RootTableManager<
          _$EquipmentDatabase,
          $EquipmentSetsTable,
          EquipmentSetRow,
          $$EquipmentSetsTableFilterComposer,
          $$EquipmentSetsTableOrderingComposer,
          $$EquipmentSetsTableAnnotationComposer,
          $$EquipmentSetsTableCreateCompanionBuilder,
          $$EquipmentSetsTableUpdateCompanionBuilder,
          (
            EquipmentSetRow,
            BaseReferences<
              _$EquipmentDatabase,
              $EquipmentSetsTable,
              EquipmentSetRow
            >,
          ),
          EquipmentSetRow,
          PrefetchHooks Function()
        > {
  $$EquipmentSetsTableTableManager(
    _$EquipmentDatabase db,
    $EquipmentSetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> telescopeId = const Value.absent(),
                Value<String?> cameraId = const Value.absent(),
                Value<String?> eyepieceId = const Value.absent(),
                Value<String?> modifierId = const Value.absent(),
                Value<int> frameColorArgb = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EquipmentSetsCompanion(
                id: id,
                name: name,
                telescopeId: telescopeId,
                cameraId: cameraId,
                eyepieceId: eyepieceId,
                modifierId: modifierId,
                frameColorArgb: frameColorArgb,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String telescopeId,
                Value<String?> cameraId = const Value.absent(),
                Value<String?> eyepieceId = const Value.absent(),
                Value<String?> modifierId = const Value.absent(),
                required int frameColorArgb,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EquipmentSetsCompanion.insert(
                id: id,
                name: name,
                telescopeId: telescopeId,
                cameraId: cameraId,
                eyepieceId: eyepieceId,
                modifierId: modifierId,
                frameColorArgb: frameColorArgb,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EquipmentSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$EquipmentDatabase,
      $EquipmentSetsTable,
      EquipmentSetRow,
      $$EquipmentSetsTableFilterComposer,
      $$EquipmentSetsTableOrderingComposer,
      $$EquipmentSetsTableAnnotationComposer,
      $$EquipmentSetsTableCreateCompanionBuilder,
      $$EquipmentSetsTableUpdateCompanionBuilder,
      (
        EquipmentSetRow,
        BaseReferences<
          _$EquipmentDatabase,
          $EquipmentSetsTable,
          EquipmentSetRow
        >,
      ),
      EquipmentSetRow,
      PrefetchHooks Function()
    >;

class $EquipmentDatabaseManager {
  final _$EquipmentDatabase _db;
  $EquipmentDatabaseManager(this._db);
  $$TelescopesTableTableManager get telescopes =>
      $$TelescopesTableTableManager(_db, _db.telescopes);
  $$CamerasTableTableManager get cameras =>
      $$CamerasTableTableManager(_db, _db.cameras);
  $$EyepiecesTableTableManager get eyepieces =>
      $$EyepiecesTableTableManager(_db, _db.eyepieces);
  $$ModifiersTableTableManager get modifiers =>
      $$ModifiersTableTableManager(_db, _db.modifiers);
  $$EquipmentSetsTableTableManager get equipmentSets =>
      $$EquipmentSetsTableTableManager(_db, _db.equipmentSets);
}
