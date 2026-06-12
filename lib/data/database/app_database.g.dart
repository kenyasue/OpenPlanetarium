// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StarsTable extends Stars with TableInfo<$StarsTable, CatalogStarRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _catalogMeta = const VerificationMeta(
    'catalog',
  );
  @override
  late final GeneratedColumn<String> catalog = GeneratedColumn<String>(
    'catalog',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starIdMeta = const VerificationMeta('starId');
  @override
  late final GeneratedColumn<int> starId = GeneratedColumn<int>(
    'star_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tileIndexMeta = const VerificationMeta(
    'tileIndex',
  );
  @override
  late final GeneratedColumn<int> tileIndex = GeneratedColumn<int>(
    'tile_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _raDegMeta = const VerificationMeta('raDeg');
  @override
  late final GeneratedColumn<double> raDeg = GeneratedColumn<double>(
    'ra_deg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decDegMeta = const VerificationMeta('decDeg');
  @override
  late final GeneratedColumn<double> decDeg = GeneratedColumn<double>(
    'dec_deg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _magnitudeMeta = const VerificationMeta(
    'magnitude',
  );
  @override
  late final GeneratedColumn<double> magnitude = GeneratedColumn<double>(
    'magnitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorIndexBVMeta = const VerificationMeta(
    'colorIndexBV',
  );
  @override
  late final GeneratedColumn<double> colorIndexBV = GeneratedColumn<double>(
    'color_index_b_v',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    catalog,
    starId,
    tileIndex,
    raDeg,
    decDeg,
    magnitude,
    colorIndexBV,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stars';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogStarRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('catalog')) {
      context.handle(
        _catalogMeta,
        catalog.isAcceptableOrUnknown(data['catalog']!, _catalogMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogMeta);
    }
    if (data.containsKey('star_id')) {
      context.handle(
        _starIdMeta,
        starId.isAcceptableOrUnknown(data['star_id']!, _starIdMeta),
      );
    } else if (isInserting) {
      context.missing(_starIdMeta);
    }
    if (data.containsKey('tile_index')) {
      context.handle(
        _tileIndexMeta,
        tileIndex.isAcceptableOrUnknown(data['tile_index']!, _tileIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_tileIndexMeta);
    }
    if (data.containsKey('ra_deg')) {
      context.handle(
        _raDegMeta,
        raDeg.isAcceptableOrUnknown(data['ra_deg']!, _raDegMeta),
      );
    } else if (isInserting) {
      context.missing(_raDegMeta);
    }
    if (data.containsKey('dec_deg')) {
      context.handle(
        _decDegMeta,
        decDeg.isAcceptableOrUnknown(data['dec_deg']!, _decDegMeta),
      );
    } else if (isInserting) {
      context.missing(_decDegMeta);
    }
    if (data.containsKey('magnitude')) {
      context.handle(
        _magnitudeMeta,
        magnitude.isAcceptableOrUnknown(data['magnitude']!, _magnitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_magnitudeMeta);
    }
    if (data.containsKey('color_index_b_v')) {
      context.handle(
        _colorIndexBVMeta,
        colorIndexBV.isAcceptableOrUnknown(
          data['color_index_b_v']!,
          _colorIndexBVMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {catalog, starId};
  @override
  CatalogStarRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogStarRow(
      catalog: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog'],
      )!,
      starId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}star_id'],
      )!,
      tileIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tile_index'],
      )!,
      raDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ra_deg'],
      )!,
      decDeg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dec_deg'],
      )!,
      magnitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnitude'],
      )!,
      colorIndexBV: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}color_index_b_v'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
    );
  }

  @override
  $StarsTable createAlias(String alias) {
    return $StarsTable(attachedDatabase, alias);
  }
}

class CatalogStarRow extends DataClass implements Insertable<CatalogStarRow> {
  final String catalog;
  final int starId;
  final int tileIndex;
  final double raDeg;
  final double decDeg;
  final double magnitude;
  final double? colorIndexBV;
  final String? name;
  const CatalogStarRow({
    required this.catalog,
    required this.starId,
    required this.tileIndex,
    required this.raDeg,
    required this.decDeg,
    required this.magnitude,
    this.colorIndexBV,
    this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['catalog'] = Variable<String>(catalog);
    map['star_id'] = Variable<int>(starId);
    map['tile_index'] = Variable<int>(tileIndex);
    map['ra_deg'] = Variable<double>(raDeg);
    map['dec_deg'] = Variable<double>(decDeg);
    map['magnitude'] = Variable<double>(magnitude);
    if (!nullToAbsent || colorIndexBV != null) {
      map['color_index_b_v'] = Variable<double>(colorIndexBV);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  StarsCompanion toCompanion(bool nullToAbsent) {
    return StarsCompanion(
      catalog: Value(catalog),
      starId: Value(starId),
      tileIndex: Value(tileIndex),
      raDeg: Value(raDeg),
      decDeg: Value(decDeg),
      magnitude: Value(magnitude),
      colorIndexBV: colorIndexBV == null && nullToAbsent
          ? const Value.absent()
          : Value(colorIndexBV),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
    );
  }

  factory CatalogStarRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogStarRow(
      catalog: serializer.fromJson<String>(json['catalog']),
      starId: serializer.fromJson<int>(json['starId']),
      tileIndex: serializer.fromJson<int>(json['tileIndex']),
      raDeg: serializer.fromJson<double>(json['raDeg']),
      decDeg: serializer.fromJson<double>(json['decDeg']),
      magnitude: serializer.fromJson<double>(json['magnitude']),
      colorIndexBV: serializer.fromJson<double?>(json['colorIndexBV']),
      name: serializer.fromJson<String?>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'catalog': serializer.toJson<String>(catalog),
      'starId': serializer.toJson<int>(starId),
      'tileIndex': serializer.toJson<int>(tileIndex),
      'raDeg': serializer.toJson<double>(raDeg),
      'decDeg': serializer.toJson<double>(decDeg),
      'magnitude': serializer.toJson<double>(magnitude),
      'colorIndexBV': serializer.toJson<double?>(colorIndexBV),
      'name': serializer.toJson<String?>(name),
    };
  }

  CatalogStarRow copyWith({
    String? catalog,
    int? starId,
    int? tileIndex,
    double? raDeg,
    double? decDeg,
    double? magnitude,
    Value<double?> colorIndexBV = const Value.absent(),
    Value<String?> name = const Value.absent(),
  }) => CatalogStarRow(
    catalog: catalog ?? this.catalog,
    starId: starId ?? this.starId,
    tileIndex: tileIndex ?? this.tileIndex,
    raDeg: raDeg ?? this.raDeg,
    decDeg: decDeg ?? this.decDeg,
    magnitude: magnitude ?? this.magnitude,
    colorIndexBV: colorIndexBV.present ? colorIndexBV.value : this.colorIndexBV,
    name: name.present ? name.value : this.name,
  );
  CatalogStarRow copyWithCompanion(StarsCompanion data) {
    return CatalogStarRow(
      catalog: data.catalog.present ? data.catalog.value : this.catalog,
      starId: data.starId.present ? data.starId.value : this.starId,
      tileIndex: data.tileIndex.present ? data.tileIndex.value : this.tileIndex,
      raDeg: data.raDeg.present ? data.raDeg.value : this.raDeg,
      decDeg: data.decDeg.present ? data.decDeg.value : this.decDeg,
      magnitude: data.magnitude.present ? data.magnitude.value : this.magnitude,
      colorIndexBV: data.colorIndexBV.present
          ? data.colorIndexBV.value
          : this.colorIndexBV,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogStarRow(')
          ..write('catalog: $catalog, ')
          ..write('starId: $starId, ')
          ..write('tileIndex: $tileIndex, ')
          ..write('raDeg: $raDeg, ')
          ..write('decDeg: $decDeg, ')
          ..write('magnitude: $magnitude, ')
          ..write('colorIndexBV: $colorIndexBV, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    catalog,
    starId,
    tileIndex,
    raDeg,
    decDeg,
    magnitude,
    colorIndexBV,
    name,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogStarRow &&
          other.catalog == this.catalog &&
          other.starId == this.starId &&
          other.tileIndex == this.tileIndex &&
          other.raDeg == this.raDeg &&
          other.decDeg == this.decDeg &&
          other.magnitude == this.magnitude &&
          other.colorIndexBV == this.colorIndexBV &&
          other.name == this.name);
}

class StarsCompanion extends UpdateCompanion<CatalogStarRow> {
  final Value<String> catalog;
  final Value<int> starId;
  final Value<int> tileIndex;
  final Value<double> raDeg;
  final Value<double> decDeg;
  final Value<double> magnitude;
  final Value<double?> colorIndexBV;
  final Value<String?> name;
  final Value<int> rowid;
  const StarsCompanion({
    this.catalog = const Value.absent(),
    this.starId = const Value.absent(),
    this.tileIndex = const Value.absent(),
    this.raDeg = const Value.absent(),
    this.decDeg = const Value.absent(),
    this.magnitude = const Value.absent(),
    this.colorIndexBV = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StarsCompanion.insert({
    required String catalog,
    required int starId,
    required int tileIndex,
    required double raDeg,
    required double decDeg,
    required double magnitude,
    this.colorIndexBV = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : catalog = Value(catalog),
       starId = Value(starId),
       tileIndex = Value(tileIndex),
       raDeg = Value(raDeg),
       decDeg = Value(decDeg),
       magnitude = Value(magnitude);
  static Insertable<CatalogStarRow> custom({
    Expression<String>? catalog,
    Expression<int>? starId,
    Expression<int>? tileIndex,
    Expression<double>? raDeg,
    Expression<double>? decDeg,
    Expression<double>? magnitude,
    Expression<double>? colorIndexBV,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (catalog != null) 'catalog': catalog,
      if (starId != null) 'star_id': starId,
      if (tileIndex != null) 'tile_index': tileIndex,
      if (raDeg != null) 'ra_deg': raDeg,
      if (decDeg != null) 'dec_deg': decDeg,
      if (magnitude != null) 'magnitude': magnitude,
      if (colorIndexBV != null) 'color_index_b_v': colorIndexBV,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StarsCompanion copyWith({
    Value<String>? catalog,
    Value<int>? starId,
    Value<int>? tileIndex,
    Value<double>? raDeg,
    Value<double>? decDeg,
    Value<double>? magnitude,
    Value<double?>? colorIndexBV,
    Value<String?>? name,
    Value<int>? rowid,
  }) {
    return StarsCompanion(
      catalog: catalog ?? this.catalog,
      starId: starId ?? this.starId,
      tileIndex: tileIndex ?? this.tileIndex,
      raDeg: raDeg ?? this.raDeg,
      decDeg: decDeg ?? this.decDeg,
      magnitude: magnitude ?? this.magnitude,
      colorIndexBV: colorIndexBV ?? this.colorIndexBV,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (catalog.present) {
      map['catalog'] = Variable<String>(catalog.value);
    }
    if (starId.present) {
      map['star_id'] = Variable<int>(starId.value);
    }
    if (tileIndex.present) {
      map['tile_index'] = Variable<int>(tileIndex.value);
    }
    if (raDeg.present) {
      map['ra_deg'] = Variable<double>(raDeg.value);
    }
    if (decDeg.present) {
      map['dec_deg'] = Variable<double>(decDeg.value);
    }
    if (magnitude.present) {
      map['magnitude'] = Variable<double>(magnitude.value);
    }
    if (colorIndexBV.present) {
      map['color_index_b_v'] = Variable<double>(colorIndexBV.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StarsCompanion(')
          ..write('catalog: $catalog, ')
          ..write('starId: $starId, ')
          ..write('tileIndex: $tileIndex, ')
          ..write('raDeg: $raDeg, ')
          ..write('decDeg: $decDeg, ')
          ..write('magnitude: $magnitude, ')
          ..write('colorIndexBV: $colorIndexBV, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadedTilesTable extends DownloadedTiles
    with TableInfo<$DownloadedTilesTable, DownloadedTile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedTilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _catalogMeta = const VerificationMeta(
    'catalog',
  );
  @override
  late final GeneratedColumn<String> catalog = GeneratedColumn<String>(
    'catalog',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tileIndexMeta = const VerificationMeta(
    'tileIndex',
  );
  @override
  late final GeneratedColumn<int> tileIndex = GeneratedColumn<int>(
    'tile_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [catalog, tileIndex, sha256];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_tiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedTile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('catalog')) {
      context.handle(
        _catalogMeta,
        catalog.isAcceptableOrUnknown(data['catalog']!, _catalogMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogMeta);
    }
    if (data.containsKey('tile_index')) {
      context.handle(
        _tileIndexMeta,
        tileIndex.isAcceptableOrUnknown(data['tile_index']!, _tileIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_tileIndexMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {catalog, tileIndex};
  @override
  DownloadedTile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedTile(
      catalog: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog'],
      )!,
      tileIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tile_index'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
    );
  }

  @override
  $DownloadedTilesTable createAlias(String alias) {
    return $DownloadedTilesTable(attachedDatabase, alias);
  }
}

class DownloadedTile extends DataClass implements Insertable<DownloadedTile> {
  final String catalog;
  final int tileIndex;
  final String sha256;
  const DownloadedTile({
    required this.catalog,
    required this.tileIndex,
    required this.sha256,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['catalog'] = Variable<String>(catalog);
    map['tile_index'] = Variable<int>(tileIndex);
    map['sha256'] = Variable<String>(sha256);
    return map;
  }

  DownloadedTilesCompanion toCompanion(bool nullToAbsent) {
    return DownloadedTilesCompanion(
      catalog: Value(catalog),
      tileIndex: Value(tileIndex),
      sha256: Value(sha256),
    );
  }

  factory DownloadedTile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedTile(
      catalog: serializer.fromJson<String>(json['catalog']),
      tileIndex: serializer.fromJson<int>(json['tileIndex']),
      sha256: serializer.fromJson<String>(json['sha256']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'catalog': serializer.toJson<String>(catalog),
      'tileIndex': serializer.toJson<int>(tileIndex),
      'sha256': serializer.toJson<String>(sha256),
    };
  }

  DownloadedTile copyWith({String? catalog, int? tileIndex, String? sha256}) =>
      DownloadedTile(
        catalog: catalog ?? this.catalog,
        tileIndex: tileIndex ?? this.tileIndex,
        sha256: sha256 ?? this.sha256,
      );
  DownloadedTile copyWithCompanion(DownloadedTilesCompanion data) {
    return DownloadedTile(
      catalog: data.catalog.present ? data.catalog.value : this.catalog,
      tileIndex: data.tileIndex.present ? data.tileIndex.value : this.tileIndex,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTile(')
          ..write('catalog: $catalog, ')
          ..write('tileIndex: $tileIndex, ')
          ..write('sha256: $sha256')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(catalog, tileIndex, sha256);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedTile &&
          other.catalog == this.catalog &&
          other.tileIndex == this.tileIndex &&
          other.sha256 == this.sha256);
}

class DownloadedTilesCompanion extends UpdateCompanion<DownloadedTile> {
  final Value<String> catalog;
  final Value<int> tileIndex;
  final Value<String> sha256;
  final Value<int> rowid;
  const DownloadedTilesCompanion({
    this.catalog = const Value.absent(),
    this.tileIndex = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedTilesCompanion.insert({
    required String catalog,
    required int tileIndex,
    required String sha256,
    this.rowid = const Value.absent(),
  }) : catalog = Value(catalog),
       tileIndex = Value(tileIndex),
       sha256 = Value(sha256);
  static Insertable<DownloadedTile> custom({
    Expression<String>? catalog,
    Expression<int>? tileIndex,
    Expression<String>? sha256,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (catalog != null) 'catalog': catalog,
      if (tileIndex != null) 'tile_index': tileIndex,
      if (sha256 != null) 'sha256': sha256,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedTilesCompanion copyWith({
    Value<String>? catalog,
    Value<int>? tileIndex,
    Value<String>? sha256,
    Value<int>? rowid,
  }) {
    return DownloadedTilesCompanion(
      catalog: catalog ?? this.catalog,
      tileIndex: tileIndex ?? this.tileIndex,
      sha256: sha256 ?? this.sha256,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (catalog.present) {
      map['catalog'] = Variable<String>(catalog.value);
    }
    if (tileIndex.present) {
      map['tile_index'] = Variable<int>(tileIndex.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTilesCompanion(')
          ..write('catalog: $catalog, ')
          ..write('tileIndex: $tileIndex, ')
          ..write('sha256: $sha256, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StarsTable stars = $StarsTable(this);
  late final $DownloadedTilesTable downloadedTiles = $DownloadedTilesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [stars, downloadedTiles];
}

typedef $$StarsTableCreateCompanionBuilder =
    StarsCompanion Function({
      required String catalog,
      required int starId,
      required int tileIndex,
      required double raDeg,
      required double decDeg,
      required double magnitude,
      Value<double?> colorIndexBV,
      Value<String?> name,
      Value<int> rowid,
    });
typedef $$StarsTableUpdateCompanionBuilder =
    StarsCompanion Function({
      Value<String> catalog,
      Value<int> starId,
      Value<int> tileIndex,
      Value<double> raDeg,
      Value<double> decDeg,
      Value<double> magnitude,
      Value<double?> colorIndexBV,
      Value<String?> name,
      Value<int> rowid,
    });

class $$StarsTableFilterComposer extends Composer<_$AppDatabase, $StarsTable> {
  $$StarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get catalog => $composableBuilder(
    column: $table.catalog,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get starId => $composableBuilder(
    column: $table.starId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tileIndex => $composableBuilder(
    column: $table.tileIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get raDeg => $composableBuilder(
    column: $table.raDeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get decDeg => $composableBuilder(
    column: $table.decDeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnitude => $composableBuilder(
    column: $table.magnitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get colorIndexBV => $composableBuilder(
    column: $table.colorIndexBV,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StarsTableOrderingComposer
    extends Composer<_$AppDatabase, $StarsTable> {
  $$StarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get catalog => $composableBuilder(
    column: $table.catalog,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get starId => $composableBuilder(
    column: $table.starId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tileIndex => $composableBuilder(
    column: $table.tileIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get raDeg => $composableBuilder(
    column: $table.raDeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get decDeg => $composableBuilder(
    column: $table.decDeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnitude => $composableBuilder(
    column: $table.magnitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get colorIndexBV => $composableBuilder(
    column: $table.colorIndexBV,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StarsTable> {
  $$StarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get catalog =>
      $composableBuilder(column: $table.catalog, builder: (column) => column);

  GeneratedColumn<int> get starId =>
      $composableBuilder(column: $table.starId, builder: (column) => column);

  GeneratedColumn<int> get tileIndex =>
      $composableBuilder(column: $table.tileIndex, builder: (column) => column);

  GeneratedColumn<double> get raDeg =>
      $composableBuilder(column: $table.raDeg, builder: (column) => column);

  GeneratedColumn<double> get decDeg =>
      $composableBuilder(column: $table.decDeg, builder: (column) => column);

  GeneratedColumn<double> get magnitude =>
      $composableBuilder(column: $table.magnitude, builder: (column) => column);

  GeneratedColumn<double> get colorIndexBV => $composableBuilder(
    column: $table.colorIndexBV,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$StarsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StarsTable,
          CatalogStarRow,
          $$StarsTableFilterComposer,
          $$StarsTableOrderingComposer,
          $$StarsTableAnnotationComposer,
          $$StarsTableCreateCompanionBuilder,
          $$StarsTableUpdateCompanionBuilder,
          (
            CatalogStarRow,
            BaseReferences<_$AppDatabase, $StarsTable, CatalogStarRow>,
          ),
          CatalogStarRow,
          PrefetchHooks Function()
        > {
  $$StarsTableTableManager(_$AppDatabase db, $StarsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> catalog = const Value.absent(),
                Value<int> starId = const Value.absent(),
                Value<int> tileIndex = const Value.absent(),
                Value<double> raDeg = const Value.absent(),
                Value<double> decDeg = const Value.absent(),
                Value<double> magnitude = const Value.absent(),
                Value<double?> colorIndexBV = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StarsCompanion(
                catalog: catalog,
                starId: starId,
                tileIndex: tileIndex,
                raDeg: raDeg,
                decDeg: decDeg,
                magnitude: magnitude,
                colorIndexBV: colorIndexBV,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String catalog,
                required int starId,
                required int tileIndex,
                required double raDeg,
                required double decDeg,
                required double magnitude,
                Value<double?> colorIndexBV = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StarsCompanion.insert(
                catalog: catalog,
                starId: starId,
                tileIndex: tileIndex,
                raDeg: raDeg,
                decDeg: decDeg,
                magnitude: magnitude,
                colorIndexBV: colorIndexBV,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StarsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StarsTable,
      CatalogStarRow,
      $$StarsTableFilterComposer,
      $$StarsTableOrderingComposer,
      $$StarsTableAnnotationComposer,
      $$StarsTableCreateCompanionBuilder,
      $$StarsTableUpdateCompanionBuilder,
      (
        CatalogStarRow,
        BaseReferences<_$AppDatabase, $StarsTable, CatalogStarRow>,
      ),
      CatalogStarRow,
      PrefetchHooks Function()
    >;
typedef $$DownloadedTilesTableCreateCompanionBuilder =
    DownloadedTilesCompanion Function({
      required String catalog,
      required int tileIndex,
      required String sha256,
      Value<int> rowid,
    });
typedef $$DownloadedTilesTableUpdateCompanionBuilder =
    DownloadedTilesCompanion Function({
      Value<String> catalog,
      Value<int> tileIndex,
      Value<String> sha256,
      Value<int> rowid,
    });

class $$DownloadedTilesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedTilesTable> {
  $$DownloadedTilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get catalog => $composableBuilder(
    column: $table.catalog,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tileIndex => $composableBuilder(
    column: $table.tileIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedTilesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedTilesTable> {
  $$DownloadedTilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get catalog => $composableBuilder(
    column: $table.catalog,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tileIndex => $composableBuilder(
    column: $table.tileIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedTilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedTilesTable> {
  $$DownloadedTilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get catalog =>
      $composableBuilder(column: $table.catalog, builder: (column) => column);

  GeneratedColumn<int> get tileIndex =>
      $composableBuilder(column: $table.tileIndex, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);
}

class $$DownloadedTilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedTilesTable,
          DownloadedTile,
          $$DownloadedTilesTableFilterComposer,
          $$DownloadedTilesTableOrderingComposer,
          $$DownloadedTilesTableAnnotationComposer,
          $$DownloadedTilesTableCreateCompanionBuilder,
          $$DownloadedTilesTableUpdateCompanionBuilder,
          (
            DownloadedTile,
            BaseReferences<
              _$AppDatabase,
              $DownloadedTilesTable,
              DownloadedTile
            >,
          ),
          DownloadedTile,
          PrefetchHooks Function()
        > {
  $$DownloadedTilesTableTableManager(
    _$AppDatabase db,
    $DownloadedTilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedTilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedTilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedTilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> catalog = const Value.absent(),
                Value<int> tileIndex = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedTilesCompanion(
                catalog: catalog,
                tileIndex: tileIndex,
                sha256: sha256,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String catalog,
                required int tileIndex,
                required String sha256,
                Value<int> rowid = const Value.absent(),
              }) => DownloadedTilesCompanion.insert(
                catalog: catalog,
                tileIndex: tileIndex,
                sha256: sha256,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedTilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedTilesTable,
      DownloadedTile,
      $$DownloadedTilesTableFilterComposer,
      $$DownloadedTilesTableOrderingComposer,
      $$DownloadedTilesTableAnnotationComposer,
      $$DownloadedTilesTableCreateCompanionBuilder,
      $$DownloadedTilesTableUpdateCompanionBuilder,
      (
        DownloadedTile,
        BaseReferences<_$AppDatabase, $DownloadedTilesTable, DownloadedTile>,
      ),
      DownloadedTile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StarsTableTableManager get stars =>
      $$StarsTableTableManager(_db, _db.stars);
  $$DownloadedTilesTableTableManager get downloadedTiles =>
      $$DownloadedTilesTableTableManager(_db, _db.downloadedTiles);
}
