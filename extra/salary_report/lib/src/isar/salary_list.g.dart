// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_list.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSalaryListCollection on Isar {
  IsarCollection<SalaryList> get salaryLists => this.collection();
}

const SalaryListSchema = CollectionSchema(
  name: r'SalaryList',
  id: 4086469189596365414,
  properties: {
    r'extraInfo': PropertySchema(
      id: 0,
      name: r'extraInfo',
      type: IsarType.string,
    ),
    r'month': PropertySchema(id: 1, name: r'month', type: IsarType.long),
    r'records': PropertySchema(
      id: 2,
      name: r'records',
      type: IsarType.objectList,

      target: r'SalaryListRecord',
    ),
    r'total': PropertySchema(id: 3, name: r'total', type: IsarType.string),
    r'year': PropertySchema(id: 4, name: r'year', type: IsarType.long),
  },

  estimateSize: _salaryListEstimateSize,
  serialize: _salaryListSerialize,
  deserialize: _salaryListDeserialize,
  deserializeProp: _salaryListDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'SalaryListRecord': SalaryListRecordSchema},

  getId: _salaryListGetId,
  getLinks: _salaryListGetLinks,
  attach: _salaryListAttach,
  version: '3.3.0-dev.3',
);

int _salaryListEstimateSize(
  SalaryList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.extraInfo.length * 3;
  bytesCount += 3 + object.records.length * 3;
  {
    final offsets = allOffsets[SalaryListRecord]!;
    for (var i = 0; i < object.records.length; i++) {
      final value = object.records[i];
      bytesCount += SalaryListRecordSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.total.length * 3;
  return bytesCount;
}

void _salaryListSerialize(
  SalaryList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.extraInfo);
  writer.writeLong(offsets[1], object.month);
  writer.writeObjectList<SalaryListRecord>(
    offsets[2],
    allOffsets,
    SalaryListRecordSchema.serialize,
    object.records,
  );
  writer.writeString(offsets[3], object.total);
  writer.writeLong(offsets[4], object.year);
}

SalaryList _salaryListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SalaryList();
  object.extraInfo = reader.readString(offsets[0]);
  object.id = id;
  object.month = reader.readLong(offsets[1]);
  object.records =
      reader.readObjectList<SalaryListRecord>(
        offsets[2],
        SalaryListRecordSchema.deserialize,
        allOffsets,
        SalaryListRecord(),
      ) ??
      [];
  object.total = reader.readString(offsets[3]);
  object.year = reader.readLong(offsets[4]);
  return object;
}

P _salaryListDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readObjectList<SalaryListRecord>(
                offset,
                SalaryListRecordSchema.deserialize,
                allOffsets,
                SalaryListRecord(),
              ) ??
              [])
          as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _salaryListGetId(SalaryList object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _salaryListGetLinks(SalaryList object) {
  return [];
}

void _salaryListAttach(IsarCollection<dynamic> col, Id id, SalaryList object) {
  object.id = id;
}

extension SalaryListQueryWhereSort
    on QueryBuilder<SalaryList, SalaryList, QWhere> {
  QueryBuilder<SalaryList, SalaryList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SalaryListQueryWhere
    on QueryBuilder<SalaryList, SalaryList, QWhereClause> {
  QueryBuilder<SalaryList, SalaryList, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SalaryList, SalaryList, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterWhereClause> idBetween(
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

extension SalaryListQueryFilter
    on QueryBuilder<SalaryList, SalaryList, QFilterCondition> {
  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> extraInfoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'extraInfo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  extraInfoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'extraInfo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> extraInfoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'extraInfo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> extraInfoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'extraInfo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  extraInfoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'extraInfo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> extraInfoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'extraInfo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> extraInfoContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'extraInfo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> extraInfoMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'extraInfo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  extraInfoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'extraInfo', value: ''),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  extraInfoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'extraInfo', value: ''),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> monthEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'month', value: value),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> monthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'month',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> monthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'month',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> monthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'month',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  recordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'records', length, true, length, true);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> recordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'records', 0, true, 0, true);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  recordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'records', 0, false, 999999, true);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  recordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'records', 0, true, length, include);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  recordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'records', length, include, 999999, true);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  recordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'records',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'total',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'total',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'total',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'total',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'total',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'total',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'total',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'total',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> totalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'total', value: ''),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition>
  totalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'total', value: ''),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> yearEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'year', value: value),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> yearGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'year',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> yearLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'year',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> yearBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'year',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SalaryListQueryObject
    on QueryBuilder<SalaryList, SalaryList, QFilterCondition> {
  QueryBuilder<SalaryList, SalaryList, QAfterFilterCondition> recordsElement(
    FilterQuery<SalaryListRecord> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'records');
    });
  }
}

extension SalaryListQueryLinks
    on QueryBuilder<SalaryList, SalaryList, QFilterCondition> {}

extension SalaryListQuerySortBy
    on QueryBuilder<SalaryList, SalaryList, QSortBy> {
  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> sortByExtraInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraInfo', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> sortByExtraInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraInfo', Sort.desc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension SalaryListQuerySortThenBy
    on QueryBuilder<SalaryList, SalaryList, QSortThenBy> {
  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByExtraInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraInfo', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByExtraInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraInfo', Sort.desc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension SalaryListQueryWhereDistinct
    on QueryBuilder<SalaryList, SalaryList, QDistinct> {
  QueryBuilder<SalaryList, SalaryList, QDistinct> distinctByExtraInfo({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extraInfo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QDistinct> distinctByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'month');
    });
  }

  QueryBuilder<SalaryList, SalaryList, QDistinct> distinctByTotal({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SalaryList, SalaryList, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension SalaryListQueryProperty
    on QueryBuilder<SalaryList, SalaryList, QQueryProperty> {
  QueryBuilder<SalaryList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SalaryList, String, QQueryOperations> extraInfoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extraInfo');
    });
  }

  QueryBuilder<SalaryList, int, QQueryOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'month');
    });
  }

  QueryBuilder<SalaryList, List<SalaryListRecord>, QQueryOperations>
  recordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'records');
    });
  }

  QueryBuilder<SalaryList, String, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }

  QueryBuilder<SalaryList, int, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const SalaryListRecordSchema = Schema(
  name: r'SalaryListRecord',
  id: 4045255543394294625,
  properties: {
    r'absence': PropertySchema(id: 0, name: r'absence', type: IsarType.string),
    r'actualPayDays': PropertySchema(
      id: 1,
      name: r'actualPayDays',
      type: IsarType.string,
    ),
    r'allowanceSalary': PropertySchema(
      id: 2,
      name: r'allowanceSalary',
      type: IsarType.string,
    ),
    r'attendance': PropertySchema(
      id: 3,
      name: r'attendance',
      type: IsarType.string,
    ),
    r'bank': PropertySchema(id: 4, name: r'bank', type: IsarType.string),
    r'bankAccount': PropertySchema(
      id: 5,
      name: r'bankAccount',
      type: IsarType.string,
    ),
    r'basicSalary': PropertySchema(
      id: 6,
      name: r'basicSalary',
      type: IsarType.string,
    ),
    r'comprehensiveSalary': PropertySchema(
      id: 7,
      name: r'comprehensiveSalary',
      type: IsarType.string,
    ),
    r'computerAllowance': PropertySchema(
      id: 8,
      name: r'computerAllowance',
      type: IsarType.string,
    ),
    r'contractType': PropertySchema(
      id: 9,
      name: r'contractType',
      type: IsarType.string,
    ),
    r'currentMonthAbsenceDeduction': PropertySchema(
      id: 10,
      name: r'currentMonthAbsenceDeduction',
      type: IsarType.string,
    ),
    r'currentMonthAllowance': PropertySchema(
      id: 11,
      name: r'currentMonthAllowance',
      type: IsarType.string,
    ),
    r'currentMonthBasic': PropertySchema(
      id: 12,
      name: r'currentMonthBasic',
      type: IsarType.string,
    ),
    r'currentMonthPerformance': PropertySchema(
      id: 13,
      name: r'currentMonthPerformance',
      type: IsarType.string,
    ),
    r'currentMonthPersonalLeaveDeduction': PropertySchema(
      id: 14,
      name: r'currentMonthPersonalLeaveDeduction',
      type: IsarType.string,
    ),
    r'currentMonthPosition': PropertySchema(
      id: 15,
      name: r'currentMonthPosition',
      type: IsarType.string,
    ),
    r'currentMonthSickDeduction': PropertySchema(
      id: 16,
      name: r'currentMonthSickDeduction',
      type: IsarType.string,
    ),
    r'currentMonthTruancyDeduction': PropertySchema(
      id: 17,
      name: r'currentMonthTruancyDeduction',
      type: IsarType.string,
    ),
    r'department': PropertySchema(
      id: 18,
      name: r'department',
      type: IsarType.string,
    ),
    r'financialAggregation': PropertySchema(
      id: 19,
      name: r'financialAggregation',
      type: IsarType.string,
    ),
    r'gender': PropertySchema(id: 20, name: r'gender', type: IsarType.string),
    r'hireDate': PropertySchema(
      id: 21,
      name: r'hireDate',
      type: IsarType.string,
    ),
    r'idNumber': PropertySchema(
      id: 22,
      name: r'idNumber',
      type: IsarType.string,
    ),
    r'jobLevel': PropertySchema(
      id: 23,
      name: r'jobLevel',
      type: IsarType.string,
    ),
    r'mealAllowance': PropertySchema(
      id: 24,
      name: r'mealAllowance',
      type: IsarType.string,
    ),
    r'monthlyPayrollSalary': PropertySchema(
      id: 25,
      name: r'monthlyPayrollSalary',
      type: IsarType.string,
    ),
    r'monthlyPersonalIncomeTax': PropertySchema(
      id: 26,
      name: r'monthlyPersonalIncomeTax',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 27, name: r'name', type: IsarType.string),
    r'netSalary': PropertySchema(
      id: 28,
      name: r'netSalary',
      type: IsarType.string,
    ),
    r'otherAdjustments': PropertySchema(
      id: 29,
      name: r'otherAdjustments',
      type: IsarType.string,
    ),
    r'payDays': PropertySchema(id: 30, name: r'payDays', type: IsarType.string),
    r'performanceSalary': PropertySchema(
      id: 31,
      name: r'performanceSalary',
      type: IsarType.string,
    ),
    r'performanceScore': PropertySchema(
      id: 32,
      name: r'performanceScore',
      type: IsarType.string,
    ),
    r'personalLeave': PropertySchema(
      id: 33,
      name: r'personalLeave',
      type: IsarType.string,
    ),
    r'personalMedical': PropertySchema(
      id: 34,
      name: r'personalMedical',
      type: IsarType.string,
    ),
    r'personalPension': PropertySchema(
      id: 35,
      name: r'personalPension',
      type: IsarType.string,
    ),
    r'personalProvidentFund': PropertySchema(
      id: 36,
      name: r'personalProvidentFund',
      type: IsarType.string,
    ),
    r'personalUnemployment': PropertySchema(
      id: 37,
      name: r'personalUnemployment',
      type: IsarType.string,
    ),
    r'position': PropertySchema(
      id: 38,
      name: r'position',
      type: IsarType.string,
    ),
    r'positionSalary': PropertySchema(
      id: 39,
      name: r'positionSalary',
      type: IsarType.string,
    ),
    r'postTaxAdjustments': PropertySchema(
      id: 40,
      name: r'postTaxAdjustments',
      type: IsarType.string,
    ),
    r'preTaxSalary': PropertySchema(
      id: 41,
      name: r'preTaxSalary',
      type: IsarType.string,
    ),
    r'providentFundBase': PropertySchema(
      id: 42,
      name: r'providentFundBase',
      type: IsarType.string,
    ),
    r'regularizationDate': PropertySchema(
      id: 43,
      name: r'regularizationDate',
      type: IsarType.string,
    ),
    r'secondaryDepartment': PropertySchema(
      id: 44,
      name: r'secondaryDepartment',
      type: IsarType.string,
    ),
    r'serialNumber': PropertySchema(
      id: 45,
      name: r'serialNumber',
      type: IsarType.string,
    ),
    r'severancePay': PropertySchema(
      id: 46,
      name: r'severancePay',
      type: IsarType.string,
    ),
    r'sickLeave': PropertySchema(
      id: 47,
      name: r'sickLeave',
      type: IsarType.string,
    ),
    r'socialSecurityBase': PropertySchema(
      id: 48,
      name: r'socialSecurityBase',
      type: IsarType.string,
    ),
    r'socialSecurityTax': PropertySchema(
      id: 49,
      name: r'socialSecurityTax',
      type: IsarType.string,
    ),
    r'terminationDate': PropertySchema(
      id: 50,
      name: r'terminationDate',
      type: IsarType.string,
    ),
    r'truancy': PropertySchema(id: 51, name: r'truancy', type: IsarType.string),
  },

  estimateSize: _salaryListRecordEstimateSize,
  serialize: _salaryListRecordSerialize,
  deserialize: _salaryListRecordDeserialize,
  deserializeProp: _salaryListRecordDeserializeProp,
);

int _salaryListRecordEstimateSize(
  SalaryListRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.absence;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.actualPayDays;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.allowanceSalary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.attendance;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.bank;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.bankAccount;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.basicSalary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.comprehensiveSalary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.computerAllowance;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contractType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMonthAbsenceDeduction;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMonthAllowance;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMonthBasic;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMonthPerformance;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMonthPersonalLeaveDeduction;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMonthPosition;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMonthSickDeduction;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMonthTruancyDeduction;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.department;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.financialAggregation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gender;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.hireDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.idNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.jobLevel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mealAllowance;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.monthlyPayrollSalary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.monthlyPersonalIncomeTax;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.netSalary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.otherAdjustments;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.payDays;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.performanceSalary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.performanceScore;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.personalLeave;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.personalMedical;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.personalPension;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.personalProvidentFund;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.personalUnemployment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.position;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.positionSalary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.postTaxAdjustments;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.preTaxSalary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.providentFundBase;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.regularizationDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.secondaryDepartment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.serialNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.severancePay;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sickLeave;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.socialSecurityBase;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.socialSecurityTax;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.terminationDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.truancy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _salaryListRecordSerialize(
  SalaryListRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.absence);
  writer.writeString(offsets[1], object.actualPayDays);
  writer.writeString(offsets[2], object.allowanceSalary);
  writer.writeString(offsets[3], object.attendance);
  writer.writeString(offsets[4], object.bank);
  writer.writeString(offsets[5], object.bankAccount);
  writer.writeString(offsets[6], object.basicSalary);
  writer.writeString(offsets[7], object.comprehensiveSalary);
  writer.writeString(offsets[8], object.computerAllowance);
  writer.writeString(offsets[9], object.contractType);
  writer.writeString(offsets[10], object.currentMonthAbsenceDeduction);
  writer.writeString(offsets[11], object.currentMonthAllowance);
  writer.writeString(offsets[12], object.currentMonthBasic);
  writer.writeString(offsets[13], object.currentMonthPerformance);
  writer.writeString(offsets[14], object.currentMonthPersonalLeaveDeduction);
  writer.writeString(offsets[15], object.currentMonthPosition);
  writer.writeString(offsets[16], object.currentMonthSickDeduction);
  writer.writeString(offsets[17], object.currentMonthTruancyDeduction);
  writer.writeString(offsets[18], object.department);
  writer.writeString(offsets[19], object.financialAggregation);
  writer.writeString(offsets[20], object.gender);
  writer.writeString(offsets[21], object.hireDate);
  writer.writeString(offsets[22], object.idNumber);
  writer.writeString(offsets[23], object.jobLevel);
  writer.writeString(offsets[24], object.mealAllowance);
  writer.writeString(offsets[25], object.monthlyPayrollSalary);
  writer.writeString(offsets[26], object.monthlyPersonalIncomeTax);
  writer.writeString(offsets[27], object.name);
  writer.writeString(offsets[28], object.netSalary);
  writer.writeString(offsets[29], object.otherAdjustments);
  writer.writeString(offsets[30], object.payDays);
  writer.writeString(offsets[31], object.performanceSalary);
  writer.writeString(offsets[32], object.performanceScore);
  writer.writeString(offsets[33], object.personalLeave);
  writer.writeString(offsets[34], object.personalMedical);
  writer.writeString(offsets[35], object.personalPension);
  writer.writeString(offsets[36], object.personalProvidentFund);
  writer.writeString(offsets[37], object.personalUnemployment);
  writer.writeString(offsets[38], object.position);
  writer.writeString(offsets[39], object.positionSalary);
  writer.writeString(offsets[40], object.postTaxAdjustments);
  writer.writeString(offsets[41], object.preTaxSalary);
  writer.writeString(offsets[42], object.providentFundBase);
  writer.writeString(offsets[43], object.regularizationDate);
  writer.writeString(offsets[44], object.secondaryDepartment);
  writer.writeString(offsets[45], object.serialNumber);
  writer.writeString(offsets[46], object.severancePay);
  writer.writeString(offsets[47], object.sickLeave);
  writer.writeString(offsets[48], object.socialSecurityBase);
  writer.writeString(offsets[49], object.socialSecurityTax);
  writer.writeString(offsets[50], object.terminationDate);
  writer.writeString(offsets[51], object.truancy);
}

SalaryListRecord _salaryListRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SalaryListRecord();
  object.absence = reader.readStringOrNull(offsets[0]);
  object.actualPayDays = reader.readStringOrNull(offsets[1]);
  object.allowanceSalary = reader.readStringOrNull(offsets[2]);
  object.attendance = reader.readStringOrNull(offsets[3]);
  object.bank = reader.readStringOrNull(offsets[4]);
  object.bankAccount = reader.readStringOrNull(offsets[5]);
  object.basicSalary = reader.readStringOrNull(offsets[6]);
  object.comprehensiveSalary = reader.readStringOrNull(offsets[7]);
  object.computerAllowance = reader.readStringOrNull(offsets[8]);
  object.contractType = reader.readStringOrNull(offsets[9]);
  object.currentMonthAbsenceDeduction = reader.readStringOrNull(offsets[10]);
  object.currentMonthAllowance = reader.readStringOrNull(offsets[11]);
  object.currentMonthBasic = reader.readStringOrNull(offsets[12]);
  object.currentMonthPerformance = reader.readStringOrNull(offsets[13]);
  object.currentMonthPersonalLeaveDeduction = reader.readStringOrNull(
    offsets[14],
  );
  object.currentMonthPosition = reader.readStringOrNull(offsets[15]);
  object.currentMonthSickDeduction = reader.readStringOrNull(offsets[16]);
  object.currentMonthTruancyDeduction = reader.readStringOrNull(offsets[17]);
  object.department = reader.readStringOrNull(offsets[18]);
  object.financialAggregation = reader.readStringOrNull(offsets[19]);
  object.gender = reader.readStringOrNull(offsets[20]);
  object.hireDate = reader.readStringOrNull(offsets[21]);
  object.idNumber = reader.readStringOrNull(offsets[22]);
  object.jobLevel = reader.readStringOrNull(offsets[23]);
  object.mealAllowance = reader.readStringOrNull(offsets[24]);
  object.monthlyPayrollSalary = reader.readStringOrNull(offsets[25]);
  object.monthlyPersonalIncomeTax = reader.readStringOrNull(offsets[26]);
  object.name = reader.readStringOrNull(offsets[27]);
  object.netSalary = reader.readStringOrNull(offsets[28]);
  object.otherAdjustments = reader.readStringOrNull(offsets[29]);
  object.payDays = reader.readStringOrNull(offsets[30]);
  object.performanceSalary = reader.readStringOrNull(offsets[31]);
  object.performanceScore = reader.readStringOrNull(offsets[32]);
  object.personalLeave = reader.readStringOrNull(offsets[33]);
  object.personalMedical = reader.readStringOrNull(offsets[34]);
  object.personalPension = reader.readStringOrNull(offsets[35]);
  object.personalProvidentFund = reader.readStringOrNull(offsets[36]);
  object.personalUnemployment = reader.readStringOrNull(offsets[37]);
  object.position = reader.readStringOrNull(offsets[38]);
  object.positionSalary = reader.readStringOrNull(offsets[39]);
  object.postTaxAdjustments = reader.readStringOrNull(offsets[40]);
  object.preTaxSalary = reader.readStringOrNull(offsets[41]);
  object.providentFundBase = reader.readStringOrNull(offsets[42]);
  object.regularizationDate = reader.readStringOrNull(offsets[43]);
  object.secondaryDepartment = reader.readStringOrNull(offsets[44]);
  object.serialNumber = reader.readStringOrNull(offsets[45]);
  object.severancePay = reader.readStringOrNull(offsets[46]);
  object.sickLeave = reader.readStringOrNull(offsets[47]);
  object.socialSecurityBase = reader.readStringOrNull(offsets[48]);
  object.socialSecurityTax = reader.readStringOrNull(offsets[49]);
  object.terminationDate = reader.readStringOrNull(offsets[50]);
  object.truancy = reader.readStringOrNull(offsets[51]);
  return object;
}

P _salaryListRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readStringOrNull(offset)) as P;
    case 33:
      return (reader.readStringOrNull(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readStringOrNull(offset)) as P;
    case 36:
      return (reader.readStringOrNull(offset)) as P;
    case 37:
      return (reader.readStringOrNull(offset)) as P;
    case 38:
      return (reader.readStringOrNull(offset)) as P;
    case 39:
      return (reader.readStringOrNull(offset)) as P;
    case 40:
      return (reader.readStringOrNull(offset)) as P;
    case 41:
      return (reader.readStringOrNull(offset)) as P;
    case 42:
      return (reader.readStringOrNull(offset)) as P;
    case 43:
      return (reader.readStringOrNull(offset)) as P;
    case 44:
      return (reader.readStringOrNull(offset)) as P;
    case 45:
      return (reader.readStringOrNull(offset)) as P;
    case 46:
      return (reader.readStringOrNull(offset)) as P;
    case 47:
      return (reader.readStringOrNull(offset)) as P;
    case 48:
      return (reader.readStringOrNull(offset)) as P;
    case 49:
      return (reader.readStringOrNull(offset)) as P;
    case 50:
      return (reader.readStringOrNull(offset)) as P;
    case 51:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension SalaryListRecordQueryFilter
    on QueryBuilder<SalaryListRecord, SalaryListRecord, QFilterCondition> {
  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'absence'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'absence'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'absence',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'absence',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'absence',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'absence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'absence',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'absence',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'absence',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'absence',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'absence', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  absenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'absence', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'actualPayDays'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'actualPayDays'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'actualPayDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'actualPayDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'actualPayDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'actualPayDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'actualPayDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'actualPayDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'actualPayDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'actualPayDays',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'actualPayDays', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  actualPayDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'actualPayDays', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'allowanceSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'allowanceSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'allowanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'allowanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'allowanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'allowanceSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'allowanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'allowanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'allowanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'allowanceSalary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'allowanceSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  allowanceSalaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'allowanceSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'attendance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'attendance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'attendance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attendance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attendance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attendance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'attendance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'attendance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'attendance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'attendance',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attendance', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  attendanceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'attendance', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'bank'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'bank'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bank',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bank',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bank', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bank', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'bankAccount'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'bankAccount'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bankAccount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bankAccount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bankAccount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bankAccount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bankAccount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bankAccount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bankAccount',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bankAccount',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bankAccount', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  bankAccountIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bankAccount', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'basicSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'basicSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'basicSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'basicSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'basicSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'basicSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'basicSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'basicSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'basicSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'basicSalary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'basicSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  basicSalaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'basicSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'comprehensiveSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'comprehensiveSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'comprehensiveSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'comprehensiveSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'comprehensiveSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'comprehensiveSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'comprehensiveSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'comprehensiveSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'comprehensiveSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'comprehensiveSalary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'comprehensiveSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  comprehensiveSalaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'comprehensiveSalary',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'computerAllowance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'computerAllowance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'computerAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'computerAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'computerAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'computerAllowance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'computerAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'computerAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'computerAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'computerAllowance',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'computerAllowance', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  computerAllowanceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'computerAllowance', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'contractType'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'contractType'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contractType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contractType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contractType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contractType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contractType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contractType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contractType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contractType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contractType', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  contractTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contractType', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentMonthAbsenceDeduction'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'currentMonthAbsenceDeduction',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthAbsenceDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentMonthAbsenceDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentMonthAbsenceDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentMonthAbsenceDeduction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentMonthAbsenceDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentMonthAbsenceDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentMonthAbsenceDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentMonthAbsenceDeduction',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthAbsenceDeduction',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAbsenceDeductionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'currentMonthAbsenceDeduction',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentMonthAllowance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentMonthAllowance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentMonthAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentMonthAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentMonthAllowance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentMonthAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentMonthAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentMonthAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentMonthAllowance',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentMonthAllowance', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthAllowanceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'currentMonthAllowance',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentMonthBasic'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentMonthBasic'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthBasic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentMonthBasic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentMonthBasic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentMonthBasic',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentMonthBasic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentMonthBasic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentMonthBasic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentMonthBasic',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentMonthBasic', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthBasicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currentMonthBasic', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentMonthPerformance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentMonthPerformance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthPerformance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentMonthPerformance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentMonthPerformance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentMonthPerformance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentMonthPerformance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentMonthPerformance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentMonthPerformance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentMonthPerformance',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthPerformance',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPerformanceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'currentMonthPerformance',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(
          property: r'currentMonthPersonalLeaveDeduction',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'currentMonthPersonalLeaveDeduction',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthPersonalLeaveDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentMonthPersonalLeaveDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentMonthPersonalLeaveDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentMonthPersonalLeaveDeduction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentMonthPersonalLeaveDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentMonthPersonalLeaveDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentMonthPersonalLeaveDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentMonthPersonalLeaveDeduction',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthPersonalLeaveDeduction',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPersonalLeaveDeductionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'currentMonthPersonalLeaveDeduction',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentMonthPosition'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentMonthPosition'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthPosition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentMonthPosition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentMonthPosition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentMonthPosition',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentMonthPosition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentMonthPosition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentMonthPosition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentMonthPosition',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentMonthPosition', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthPositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'currentMonthPosition',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentMonthSickDeduction'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentMonthSickDeduction'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthSickDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentMonthSickDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentMonthSickDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentMonthSickDeduction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentMonthSickDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentMonthSickDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentMonthSickDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentMonthSickDeduction',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthSickDeduction',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthSickDeductionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'currentMonthSickDeduction',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentMonthTruancyDeduction'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'currentMonthTruancyDeduction',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthTruancyDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentMonthTruancyDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentMonthTruancyDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentMonthTruancyDeduction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentMonthTruancyDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentMonthTruancyDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentMonthTruancyDeduction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentMonthTruancyDeduction',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentMonthTruancyDeduction',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  currentMonthTruancyDeductionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'currentMonthTruancyDeduction',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'department'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'department'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'department',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'department',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'department',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'department',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'department',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'department',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'department',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'department',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'department', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  departmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'department', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'financialAggregation'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'financialAggregation'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'financialAggregation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'financialAggregation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'financialAggregation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'financialAggregation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'financialAggregation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'financialAggregation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'financialAggregation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'financialAggregation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'financialAggregation', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  financialAggregationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'financialAggregation',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'gender'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'gender'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gender',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'gender',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gender', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'gender', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'hireDate'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'hireDate'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hireDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hireDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hireDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hireDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'hireDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'hireDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'hireDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'hireDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hireDate', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  hireDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'hireDate', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'idNumber'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'idNumber'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'idNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'idNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'idNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'idNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'idNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'idNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'idNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'idNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idNumber', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  idNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'idNumber', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'jobLevel'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'jobLevel'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'jobLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'jobLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'jobLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'jobLevel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'jobLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'jobLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'jobLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'jobLevel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'jobLevel', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  jobLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'jobLevel', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mealAllowance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mealAllowance'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mealAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mealAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mealAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mealAllowance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mealAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mealAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mealAllowance',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mealAllowance',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mealAllowance', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  mealAllowanceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mealAllowance', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'monthlyPayrollSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'monthlyPayrollSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'monthlyPayrollSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'monthlyPayrollSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'monthlyPayrollSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'monthlyPayrollSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'monthlyPayrollSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'monthlyPayrollSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'monthlyPayrollSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'monthlyPayrollSalary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'monthlyPayrollSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPayrollSalaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'monthlyPayrollSalary',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'monthlyPersonalIncomeTax'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'monthlyPersonalIncomeTax'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'monthlyPersonalIncomeTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'monthlyPersonalIncomeTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'monthlyPersonalIncomeTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'monthlyPersonalIncomeTax',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'monthlyPersonalIncomeTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'monthlyPersonalIncomeTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'monthlyPersonalIncomeTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'monthlyPersonalIncomeTax',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'monthlyPersonalIncomeTax',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  monthlyPersonalIncomeTaxIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'monthlyPersonalIncomeTax',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'name'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'name'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'netSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'netSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'netSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'netSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'netSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'netSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'netSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'netSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'netSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'netSalary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'netSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  netSalaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'netSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'otherAdjustments'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'otherAdjustments'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'otherAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'otherAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'otherAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'otherAdjustments',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'otherAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'otherAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'otherAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'otherAdjustments',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'otherAdjustments', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  otherAdjustmentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'otherAdjustments', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'payDays'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'payDays'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'payDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payDays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'payDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'payDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'payDays',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'payDays',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payDays', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  payDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'payDays', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'performanceSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'performanceSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'performanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'performanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'performanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'performanceSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'performanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'performanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'performanceSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'performanceSalary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'performanceSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceSalaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'performanceSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'performanceScore'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'performanceScore'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'performanceScore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'performanceScore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'performanceScore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'performanceScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'performanceScore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'performanceScore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'performanceScore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'performanceScore',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'performanceScore', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  performanceScoreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'performanceScore', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'personalLeave'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'personalLeave'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'personalLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'personalLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'personalLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'personalLeave',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'personalLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'personalLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'personalLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'personalLeave',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'personalLeave', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalLeaveIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'personalLeave', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'personalMedical'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'personalMedical'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'personalMedical',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'personalMedical',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'personalMedical',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'personalMedical',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'personalMedical',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'personalMedical',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'personalMedical',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'personalMedical',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'personalMedical', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalMedicalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'personalMedical', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'personalPension'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'personalPension'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'personalPension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'personalPension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'personalPension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'personalPension',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'personalPension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'personalPension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'personalPension',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'personalPension',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'personalPension', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalPensionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'personalPension', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'personalProvidentFund'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'personalProvidentFund'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'personalProvidentFund',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'personalProvidentFund',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'personalProvidentFund',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'personalProvidentFund',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'personalProvidentFund',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'personalProvidentFund',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'personalProvidentFund',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'personalProvidentFund',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'personalProvidentFund', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalProvidentFundIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'personalProvidentFund',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'personalUnemployment'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'personalUnemployment'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'personalUnemployment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'personalUnemployment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'personalUnemployment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'personalUnemployment',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'personalUnemployment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'personalUnemployment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'personalUnemployment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'personalUnemployment',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'personalUnemployment', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  personalUnemploymentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'personalUnemployment',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'position'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'position'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'position',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'position',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'position', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'position', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'positionSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'positionSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'positionSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'positionSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'positionSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'positionSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'positionSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'positionSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'positionSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'positionSalary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  positionSalaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'positionSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'postTaxAdjustments'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'postTaxAdjustments'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'postTaxAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'postTaxAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'postTaxAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'postTaxAdjustments',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'postTaxAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'postTaxAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'postTaxAdjustments',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'postTaxAdjustments',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'postTaxAdjustments', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  postTaxAdjustmentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'postTaxAdjustments', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'preTaxSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'preTaxSalary'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'preTaxSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'preTaxSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'preTaxSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'preTaxSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'preTaxSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'preTaxSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'preTaxSalary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'preTaxSalary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'preTaxSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  preTaxSalaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'preTaxSalary', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'providentFundBase'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'providentFundBase'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'providentFundBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'providentFundBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'providentFundBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'providentFundBase',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'providentFundBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'providentFundBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'providentFundBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'providentFundBase',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'providentFundBase', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  providentFundBaseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'providentFundBase', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'regularizationDate'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'regularizationDate'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'regularizationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'regularizationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'regularizationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'regularizationDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'regularizationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'regularizationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'regularizationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'regularizationDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'regularizationDate', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  regularizationDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'regularizationDate', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'secondaryDepartment'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'secondaryDepartment'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'secondaryDepartment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'secondaryDepartment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'secondaryDepartment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'secondaryDepartment',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'secondaryDepartment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'secondaryDepartment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'secondaryDepartment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'secondaryDepartment',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'secondaryDepartment', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  secondaryDepartmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'secondaryDepartment',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'serialNumber'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'serialNumber'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'serialNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serialNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serialNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serialNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'serialNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'serialNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'serialNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'serialNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serialNumber', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  serialNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'serialNumber', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'severancePay'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'severancePay'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'severancePay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'severancePay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'severancePay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'severancePay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'severancePay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'severancePay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'severancePay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'severancePay',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'severancePay', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  severancePayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'severancePay', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sickLeave'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sickLeave'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sickLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sickLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sickLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sickLeave',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sickLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sickLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sickLeave',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sickLeave',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sickLeave', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  sickLeaveIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sickLeave', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'socialSecurityBase'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'socialSecurityBase'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'socialSecurityBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'socialSecurityBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'socialSecurityBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'socialSecurityBase',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'socialSecurityBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'socialSecurityBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'socialSecurityBase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'socialSecurityBase',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'socialSecurityBase', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityBaseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'socialSecurityBase', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'socialSecurityTax'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'socialSecurityTax'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'socialSecurityTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'socialSecurityTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'socialSecurityTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'socialSecurityTax',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'socialSecurityTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'socialSecurityTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'socialSecurityTax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'socialSecurityTax',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'socialSecurityTax', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  socialSecurityTaxIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'socialSecurityTax', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'terminationDate'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'terminationDate'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'terminationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'terminationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'terminationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'terminationDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'terminationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'terminationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'terminationDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'terminationDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'terminationDate', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  terminationDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'terminationDate', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'truancy'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'truancy'),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'truancy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'truancy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'truancy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'truancy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'truancy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'truancy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'truancy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'truancy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'truancy', value: ''),
      );
    });
  }

  QueryBuilder<SalaryListRecord, SalaryListRecord, QAfterFilterCondition>
  truancyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'truancy', value: ''),
      );
    });
  }
}

extension SalaryListRecordQueryObject
    on QueryBuilder<SalaryListRecord, SalaryListRecord, QFilterCondition> {}
