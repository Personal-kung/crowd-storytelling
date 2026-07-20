// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captured_page.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCapturedPageCollection on Isar {
  IsarCollection<CapturedPage> get capturedPages => this.collection();
}

const CapturedPageSchema = CollectionSchema(
  name: r'CapturedPage',
  id: 5612723601287406984,
  properties: {
    r'originalPath': PropertySchema(
      id: 0,
      name: r'originalPath',
      type: IsarType.string,
    ),
    r'pageNumber': PropertySchema(
      id: 1,
      name: r'pageNumber',
      type: IsarType.long,
    ),
    r'processedPath': PropertySchema(
      id: 2,
      name: r'processedPath',
      type: IsarType.string,
    ),
    r'submissionId': PropertySchema(
      id: 3,
      name: r'submissionId',
      type: IsarType.string,
    )
  },
  estimateSize: _capturedPageEstimateSize,
  serialize: _capturedPageSerialize,
  deserialize: _capturedPageDeserialize,
  deserializeProp: _capturedPageDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _capturedPageGetId,
  getLinks: _capturedPageGetLinks,
  attach: _capturedPageAttach,
  version: '3.1.0+1',
);

int _capturedPageEstimateSize(
  CapturedPage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.originalPath.length * 3;
  bytesCount += 3 + object.processedPath.length * 3;
  bytesCount += 3 + object.submissionId.length * 3;
  return bytesCount;
}

void _capturedPageSerialize(
  CapturedPage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.originalPath);
  writer.writeLong(offsets[1], object.pageNumber);
  writer.writeString(offsets[2], object.processedPath);
  writer.writeString(offsets[3], object.submissionId);
}

CapturedPage _capturedPageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CapturedPage(
    originalPath: reader.readString(offsets[0]),
    pageNumber: reader.readLong(offsets[1]),
    processedPath: reader.readString(offsets[2]),
    submissionId: reader.readString(offsets[3]),
  );
  object.id = id;
  return object;
}

P _capturedPageDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _capturedPageGetId(CapturedPage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _capturedPageGetLinks(CapturedPage object) {
  return [];
}

void _capturedPageAttach(
    IsarCollection<dynamic> col, Id id, CapturedPage object) {
  object.id = id;
}

extension CapturedPageQueryWhereSort
    on QueryBuilder<CapturedPage, CapturedPage, QWhere> {
  QueryBuilder<CapturedPage, CapturedPage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CapturedPageQueryWhere
    on QueryBuilder<CapturedPage, CapturedPage, QWhereClause> {
  QueryBuilder<CapturedPage, CapturedPage, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<CapturedPage, CapturedPage, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CapturedPageQueryFilter
    on QueryBuilder<CapturedPage, CapturedPage, QFilterCondition> {
  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      originalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      pageNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      pageNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      pageNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      pageNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processedPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processedPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processedPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'processedPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'processedPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'processedPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'processedPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      processedPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'processedPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submissionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'submissionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'submissionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'submissionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'submissionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'submissionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'submissionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'submissionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submissionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterFilterCondition>
      submissionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'submissionId',
        value: '',
      ));
    });
  }
}

extension CapturedPageQueryObject
    on QueryBuilder<CapturedPage, CapturedPage, QFilterCondition> {}

extension CapturedPageQueryLinks
    on QueryBuilder<CapturedPage, CapturedPage, QFilterCondition> {}

extension CapturedPageQuerySortBy
    on QueryBuilder<CapturedPage, CapturedPage, QSortBy> {
  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> sortByOriginalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPath', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy>
      sortByOriginalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPath', Sort.desc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> sortByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy>
      sortByPageNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.desc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> sortByProcessedPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedPath', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy>
      sortByProcessedPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedPath', Sort.desc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> sortBySubmissionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submissionId', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy>
      sortBySubmissionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submissionId', Sort.desc);
    });
  }
}

extension CapturedPageQuerySortThenBy
    on QueryBuilder<CapturedPage, CapturedPage, QSortThenBy> {
  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> thenByOriginalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPath', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy>
      thenByOriginalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPath', Sort.desc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> thenByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy>
      thenByPageNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageNumber', Sort.desc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> thenByProcessedPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedPath', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy>
      thenByProcessedPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedPath', Sort.desc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy> thenBySubmissionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submissionId', Sort.asc);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QAfterSortBy>
      thenBySubmissionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submissionId', Sort.desc);
    });
  }
}

extension CapturedPageQueryWhereDistinct
    on QueryBuilder<CapturedPage, CapturedPage, QDistinct> {
  QueryBuilder<CapturedPage, CapturedPage, QDistinct> distinctByOriginalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QDistinct> distinctByPageNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageNumber');
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QDistinct> distinctByProcessedPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processedPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CapturedPage, CapturedPage, QDistinct> distinctBySubmissionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submissionId', caseSensitive: caseSensitive);
    });
  }
}

extension CapturedPageQueryProperty
    on QueryBuilder<CapturedPage, CapturedPage, QQueryProperty> {
  QueryBuilder<CapturedPage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CapturedPage, String, QQueryOperations> originalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalPath');
    });
  }

  QueryBuilder<CapturedPage, int, QQueryOperations> pageNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageNumber');
    });
  }

  QueryBuilder<CapturedPage, String, QQueryOperations> processedPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processedPath');
    });
  }

  QueryBuilder<CapturedPage, String, QQueryOperations> submissionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submissionId');
    });
  }
}
