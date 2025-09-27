// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_generation_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReportGenerationRecordCollection on Isar {
  IsarCollection<ReportGenerationRecord> get reportGenerationRecords =>
      this.collection();
}

const ReportGenerationRecordSchema = CollectionSchema(
  name: r'ReportGenerationRecord',
  id: 4069542794227947867,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isDeleted': PropertySchema(
      id: 1,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'reportSaveFormat': PropertySchema(
      id: 2,
      name: r'reportSaveFormat',
      type: IsarType.byte,
      enumMap: _ReportGenerationRecordreportSaveFormatEnumValueMap,
    ),
    r'savePath': PropertySchema(
      id: 3,
      name: r'savePath',
      type: IsarType.string,
    ),
  },

  estimateSize: _reportGenerationRecordEstimateSize,
  serialize: _reportGenerationRecordSerialize,
  deserialize: _reportGenerationRecordDeserialize,
  deserializeProp: _reportGenerationRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _reportGenerationRecordGetId,
  getLinks: _reportGenerationRecordGetLinks,
  attach: _reportGenerationRecordAttach,
  version: '3.3.0-dev.3',
);

int _reportGenerationRecordEstimateSize(
  ReportGenerationRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.savePath.length * 3;
  return bytesCount;
}

void _reportGenerationRecordSerialize(
  ReportGenerationRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isDeleted);
  writer.writeByte(offsets[2], object.reportSaveFormat.index);
  writer.writeString(offsets[3], object.savePath);
}

ReportGenerationRecord _reportGenerationRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReportGenerationRecord();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.isDeleted = reader.readBool(offsets[1]);
  object.reportSaveFormat =
      _ReportGenerationRecordreportSaveFormatValueEnumMap[reader.readByteOrNull(
        offsets[2],
      )] ??
      ReportSaveFormat.docx;
  object.savePath = reader.readString(offsets[3]);
  return object;
}

P _reportGenerationRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (_ReportGenerationRecordreportSaveFormatValueEnumMap[reader
                  .readByteOrNull(offset)] ??
              ReportSaveFormat.docx)
          as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ReportGenerationRecordreportSaveFormatEnumValueMap = {
  'docx': 0,
  'image': 1,
};
const _ReportGenerationRecordreportSaveFormatValueEnumMap = {
  0: ReportSaveFormat.docx,
  1: ReportSaveFormat.image,
};

Id _reportGenerationRecordGetId(ReportGenerationRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reportGenerationRecordGetLinks(
  ReportGenerationRecord object,
) {
  return [];
}

void _reportGenerationRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  ReportGenerationRecord object,
) {
  object.id = id;
}

extension ReportGenerationRecordQueryWhereSort
    on QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QWhere> {
  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReportGenerationRecordQueryWhere
    on
        QueryBuilder<
          ReportGenerationRecord,
          ReportGenerationRecord,
          QWhereClause
        > {
  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ReportGenerationRecordQueryFilter
    on
        QueryBuilder<
          ReportGenerationRecord,
          ReportGenerationRecord,
          QFilterCondition
        > {
  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDeleted', value: value),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  reportSaveFormatEqualTo(ReportSaveFormat value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reportSaveFormat', value: value),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  reportSaveFormatGreaterThan(ReportSaveFormat value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reportSaveFormat',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  reportSaveFormatLessThan(ReportSaveFormat value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reportSaveFormat',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  reportSaveFormatBetween(
    ReportSaveFormat lower,
    ReportSaveFormat upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reportSaveFormat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'savePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'savePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'savePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'savePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'savePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'savePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'savePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'savePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'savePath', value: ''),
      );
    });
  }

  QueryBuilder<
    ReportGenerationRecord,
    ReportGenerationRecord,
    QAfterFilterCondition
  >
  savePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'savePath', value: ''),
      );
    });
  }
}

extension ReportGenerationRecordQueryObject
    on
        QueryBuilder<
          ReportGenerationRecord,
          ReportGenerationRecord,
          QFilterCondition
        > {}

extension ReportGenerationRecordQueryLinks
    on
        QueryBuilder<
          ReportGenerationRecord,
          ReportGenerationRecord,
          QFilterCondition
        > {}

extension ReportGenerationRecordQuerySortBy
    on QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QSortBy> {
  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  sortByReportSaveFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportSaveFormat', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  sortByReportSaveFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportSaveFormat', Sort.desc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  sortBySavePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savePath', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  sortBySavePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savePath', Sort.desc);
    });
  }
}

extension ReportGenerationRecordQuerySortThenBy
    on
        QueryBuilder<
          ReportGenerationRecord,
          ReportGenerationRecord,
          QSortThenBy
        > {
  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenByReportSaveFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportSaveFormat', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenByReportSaveFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportSaveFormat', Sort.desc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenBySavePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savePath', Sort.asc);
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QAfterSortBy>
  thenBySavePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savePath', Sort.desc);
    });
  }
}

extension ReportGenerationRecordQueryWhereDistinct
    on QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QDistinct> {
  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QDistinct>
  distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QDistinct>
  distinctByReportSaveFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reportSaveFormat');
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportGenerationRecord, QDistinct>
  distinctBySavePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savePath', caseSensitive: caseSensitive);
    });
  }
}

extension ReportGenerationRecordQueryProperty
    on
        QueryBuilder<
          ReportGenerationRecord,
          ReportGenerationRecord,
          QQueryProperty
        > {
  QueryBuilder<ReportGenerationRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReportGenerationRecord, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ReportGenerationRecord, bool, QQueryOperations>
  isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<ReportGenerationRecord, ReportSaveFormat, QQueryOperations>
  reportSaveFormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reportSaveFormat');
    });
  }

  QueryBuilder<ReportGenerationRecord, String, QQueryOperations>
  savePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savePath');
    });
  }
}
