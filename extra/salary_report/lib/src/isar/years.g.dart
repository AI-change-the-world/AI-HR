// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'years.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActivatedYearCollection on Isar {
  IsarCollection<ActivatedYear> get activatedYears => this.collection();
}

const ActivatedYearSchema = CollectionSchema(
  name: r'ActivatedYear',
  id: 4791605621210538910,
  properties: {
    r'year': PropertySchema(id: 0, name: r'year', type: IsarType.long),
  },

  estimateSize: _activatedYearEstimateSize,
  serialize: _activatedYearSerialize,
  deserialize: _activatedYearDeserialize,
  deserializeProp: _activatedYearDeserializeProp,
  idName: r'id',
  indexes: {
    r'year': IndexSchema(
      id: -875522826430421864,
      name: r'year',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'year',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _activatedYearGetId,
  getLinks: _activatedYearGetLinks,
  attach: _activatedYearAttach,
  version: '3.3.0-dev.2',
);

int _activatedYearEstimateSize(
  ActivatedYear object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _activatedYearSerialize(
  ActivatedYear object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.year);
}

ActivatedYear _activatedYearDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActivatedYear();
  object.id = id;
  object.year = reader.readLong(offsets[0]);
  return object;
}

P _activatedYearDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activatedYearGetId(ActivatedYear object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activatedYearGetLinks(ActivatedYear object) {
  return [];
}

void _activatedYearAttach(
  IsarCollection<dynamic> col,
  Id id,
  ActivatedYear object,
) {
  object.id = id;
}

extension ActivatedYearByIndex on IsarCollection<ActivatedYear> {
  Future<ActivatedYear?> getByYear(int year) {
    return getByIndex(r'year', [year]);
  }

  ActivatedYear? getByYearSync(int year) {
    return getByIndexSync(r'year', [year]);
  }

  Future<bool> deleteByYear(int year) {
    return deleteByIndex(r'year', [year]);
  }

  bool deleteByYearSync(int year) {
    return deleteByIndexSync(r'year', [year]);
  }

  Future<List<ActivatedYear?>> getAllByYear(List<int> yearValues) {
    final values = yearValues.map((e) => [e]).toList();
    return getAllByIndex(r'year', values);
  }

  List<ActivatedYear?> getAllByYearSync(List<int> yearValues) {
    final values = yearValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'year', values);
  }

  Future<int> deleteAllByYear(List<int> yearValues) {
    final values = yearValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'year', values);
  }

  int deleteAllByYearSync(List<int> yearValues) {
    final values = yearValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'year', values);
  }

  Future<Id> putByYear(ActivatedYear object) {
    return putByIndex(r'year', object);
  }

  Id putByYearSync(ActivatedYear object, {bool saveLinks = true}) {
    return putByIndexSync(r'year', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByYear(List<ActivatedYear> objects) {
    return putAllByIndex(r'year', objects);
  }

  List<Id> putAllByYearSync(
    List<ActivatedYear> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'year', objects, saveLinks: saveLinks);
  }
}

extension ActivatedYearQueryWhereSort
    on QueryBuilder<ActivatedYear, ActivatedYear, QWhere> {
  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhere> anyYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'year'),
      );
    });
  }
}

extension ActivatedYearQueryWhere
    on QueryBuilder<ActivatedYear, ActivatedYear, QWhereClause> {
  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> idBetween(
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

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> yearEqualTo(
    int year,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'year', value: [year]),
      );
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> yearNotEqualTo(
    int year,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'year',
                lower: [],
                upper: [year],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'year',
                lower: [year],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'year',
                lower: [year],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'year',
                lower: [],
                upper: [year],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> yearGreaterThan(
    int year, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'year',
          lower: [year],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> yearLessThan(
    int year, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'year',
          lower: [],
          upper: [year],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterWhereClause> yearBetween(
    int lowerYear,
    int upperYear, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'year',
          lower: [lowerYear],
          includeLower: includeLower,
          upper: [upperYear],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ActivatedYearQueryFilter
    on QueryBuilder<ActivatedYear, ActivatedYear, QFilterCondition> {
  QueryBuilder<ActivatedYear, ActivatedYear, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterFilterCondition>
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

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterFilterCondition> yearEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'year', value: value),
      );
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterFilterCondition>
  yearGreaterThan(int value, {bool include = false}) {
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

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterFilterCondition>
  yearLessThan(int value, {bool include = false}) {
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

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterFilterCondition> yearBetween(
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

extension ActivatedYearQueryObject
    on QueryBuilder<ActivatedYear, ActivatedYear, QFilterCondition> {}

extension ActivatedYearQueryLinks
    on QueryBuilder<ActivatedYear, ActivatedYear, QFilterCondition> {}

extension ActivatedYearQuerySortBy
    on QueryBuilder<ActivatedYear, ActivatedYear, QSortBy> {
  QueryBuilder<ActivatedYear, ActivatedYear, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension ActivatedYearQuerySortThenBy
    on QueryBuilder<ActivatedYear, ActivatedYear, QSortThenBy> {
  QueryBuilder<ActivatedYear, ActivatedYear, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<ActivatedYear, ActivatedYear, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension ActivatedYearQueryWhereDistinct
    on QueryBuilder<ActivatedYear, ActivatedYear, QDistinct> {
  QueryBuilder<ActivatedYear, ActivatedYear, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension ActivatedYearQueryProperty
    on QueryBuilder<ActivatedYear, ActivatedYear, QQueryProperty> {
  QueryBuilder<ActivatedYear, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActivatedYear, int, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}
