// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_history_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExportHistoryModelCollection on Isar {
  IsarCollection<ExportHistoryModel> get exportHistoryModels =>
      this.collection();
}

const ExportHistoryModelSchema = CollectionSchema(
  name: r'ExportHistoryModel',
  id: 2065856586466041255,
  properties: {
    r'baseFileName': PropertySchema(
      id: 0,
      name: r'baseFileName',
      type: IsarType.string,
    ),
    r'caseStudyStatus': PropertySchema(
      id: 1,
      name: r'caseStudyStatus',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'documentCount': PropertySchema(
      id: 3,
      name: r'documentCount',
      type: IsarType.long,
    ),
    r'errorMessage': PropertySchema(
      id: 4,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'exportDirectory': PropertySchema(
      id: 5,
      name: r'exportDirectory',
      type: IsarType.string,
    ),
    r'fieldValuesJson': PropertySchema(
      id: 6,
      name: r'fieldValuesJson',
      type: IsarType.string,
    ),
    r'outputFiles': PropertySchema(
      id: 7,
      name: r'outputFiles',
      type: IsarType.stringList,
    ),
    r'singleLineValuesJson': PropertySchema(
      id: 8,
      name: r'singleLineValuesJson',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 9, name: r'status', type: IsarType.string),
    r'templateIds': PropertySchema(
      id: 10,
      name: r'templateIds',
      type: IsarType.longList,
    ),
    r'templateSnapshotsJson': PropertySchema(
      id: 11,
      name: r'templateSnapshotsJson',
      type: IsarType.string,
    ),
  },

  estimateSize: _exportHistoryModelEstimateSize,
  serialize: _exportHistoryModelSerialize,
  deserialize: _exportHistoryModelDeserialize,
  deserializeProp: _exportHistoryModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _exportHistoryModelGetId,
  getLinks: _exportHistoryModelGetLinks,
  attach: _exportHistoryModelAttach,
  version: '3.3.2',
);

int _exportHistoryModelEstimateSize(
  ExportHistoryModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.baseFileName.length * 3;
  bytesCount += 3 + object.caseStudyStatus.length * 3;
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.exportDirectory.length * 3;
  bytesCount += 3 + object.fieldValuesJson.length * 3;
  bytesCount += 3 + object.outputFiles.length * 3;
  {
    for (var i = 0; i < object.outputFiles.length; i++) {
      final value = object.outputFiles[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.singleLineValuesJson.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.templateIds.length * 8;
  bytesCount += 3 + object.templateSnapshotsJson.length * 3;
  return bytesCount;
}

void _exportHistoryModelSerialize(
  ExportHistoryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.baseFileName);
  writer.writeString(offsets[1], object.caseStudyStatus);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.documentCount);
  writer.writeString(offsets[4], object.errorMessage);
  writer.writeString(offsets[5], object.exportDirectory);
  writer.writeString(offsets[6], object.fieldValuesJson);
  writer.writeStringList(offsets[7], object.outputFiles);
  writer.writeString(offsets[8], object.singleLineValuesJson);
  writer.writeString(offsets[9], object.status);
  writer.writeLongList(offsets[10], object.templateIds);
  writer.writeString(offsets[11], object.templateSnapshotsJson);
}

ExportHistoryModel _exportHistoryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExportHistoryModel(
    baseFileName: reader.readStringOrNull(offsets[0]) ?? '',
    caseStudyStatus: reader.readStringOrNull(offsets[1]) ?? 'none',
    createdAt: reader.readDateTimeOrNull(offsets[2]),
    documentCount: reader.readLongOrNull(offsets[3]) ?? 0,
    errorMessage: reader.readStringOrNull(offsets[4]),
    exportDirectory: reader.readStringOrNull(offsets[5]) ?? '',
    fieldValuesJson: reader.readStringOrNull(offsets[6]) ?? '{}',
    id: id,
    outputFiles: reader.readStringList(offsets[7]) ?? const [],
    singleLineValuesJson: reader.readStringOrNull(offsets[8]) ?? '{}',
    status: reader.readStringOrNull(offsets[9]) ?? 'success',
    templateIds: reader.readLongList(offsets[10]) ?? const [],
    templateSnapshotsJson: reader.readStringOrNull(offsets[11]) ?? '[]',
  );
  return object;
}

P _exportHistoryModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? 'none') as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 6:
      return (reader.readStringOrNull(offset) ?? '{}') as P;
    case 7:
      return (reader.readStringList(offset) ?? const []) as P;
    case 8:
      return (reader.readStringOrNull(offset) ?? '{}') as P;
    case 9:
      return (reader.readStringOrNull(offset) ?? 'success') as P;
    case 10:
      return (reader.readLongList(offset) ?? const []) as P;
    case 11:
      return (reader.readStringOrNull(offset) ?? '[]') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exportHistoryModelGetId(ExportHistoryModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exportHistoryModelGetLinks(
  ExportHistoryModel object,
) {
  return [];
}

void _exportHistoryModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  ExportHistoryModel object,
) {
  object.id = id;
}

extension ExportHistoryModelQueryWhereSort
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QWhere> {
  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExportHistoryModelQueryWhere
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QWhereClause> {
  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterWhereClause>
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

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterWhereClause>
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

extension ExportHistoryModelQueryFilter
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QFilterCondition> {
  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'baseFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'baseFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'baseFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'baseFileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'baseFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'baseFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'baseFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'baseFileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'baseFileName', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  baseFileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'baseFileName', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caseStudyStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caseStudyStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caseStudyStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caseStudyStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caseStudyStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caseStudyStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caseStudyStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caseStudyStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caseStudyStatus', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  caseStudyStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caseStudyStatus', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  createdAtGreaterThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  createdAtLessThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  documentCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'documentCount', value: value),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  documentCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'documentCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  documentCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'documentCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  documentCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'documentCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'errorMessage'),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'errorMessage'),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'errorMessage',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'errorMessage',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'errorMessage',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'errorMessage', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'errorMessage', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'exportDirectory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'exportDirectory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'exportDirectory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'exportDirectory',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'exportDirectory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'exportDirectory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'exportDirectory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'exportDirectory',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'exportDirectory', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  exportDirectoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'exportDirectory', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fieldValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fieldValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fieldValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fieldValuesJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fieldValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fieldValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fieldValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fieldValuesJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fieldValuesJson', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  fieldValuesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fieldValuesJson', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
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

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
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

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
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

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'outputFiles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outputFiles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outputFiles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outputFiles',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'outputFiles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'outputFiles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'outputFiles',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'outputFiles',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'outputFiles', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'outputFiles', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'outputFiles', length, true, length, true);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'outputFiles', 0, true, 0, true);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'outputFiles', 0, false, 999999, true);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'outputFiles', 0, true, length, include);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'outputFiles', length, include, 999999, true);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  outputFilesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'outputFiles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'singleLineValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'singleLineValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'singleLineValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'singleLineValuesJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'singleLineValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'singleLineValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'singleLineValuesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'singleLineValuesJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'singleLineValuesJson', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  singleLineValuesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'singleLineValuesJson',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'templateIds', value: value),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'templateIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'templateIds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'templateIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'templateIds', length, true, length, true);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'templateIds', 0, true, 0, true);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'templateIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'templateIds', 0, true, length, include);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'templateIds', length, include, 999999, true);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'templateIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'templateSnapshotsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'templateSnapshotsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'templateSnapshotsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'templateSnapshotsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'templateSnapshotsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'templateSnapshotsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'templateSnapshotsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'templateSnapshotsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'templateSnapshotsJson', value: ''),
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterFilterCondition>
  templateSnapshotsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'templateSnapshotsJson',
          value: '',
        ),
      );
    });
  }
}

extension ExportHistoryModelQueryObject
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QFilterCondition> {}

extension ExportHistoryModelQueryLinks
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QFilterCondition> {}

extension ExportHistoryModelQuerySortBy
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QSortBy> {
  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByBaseFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseFileName', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByBaseFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseFileName', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByCaseStudyStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseStudyStatus', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByCaseStudyStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseStudyStatus', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByDocumentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentCount', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByDocumentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentCount', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByExportDirectory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportDirectory', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByExportDirectoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportDirectory', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByFieldValuesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldValuesJson', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByFieldValuesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldValuesJson', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortBySingleLineValuesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'singleLineValuesJson', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortBySingleLineValuesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'singleLineValuesJson', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByTemplateSnapshotsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateSnapshotsJson', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  sortByTemplateSnapshotsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateSnapshotsJson', Sort.desc);
    });
  }
}

extension ExportHistoryModelQuerySortThenBy
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QSortThenBy> {
  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByBaseFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseFileName', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByBaseFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseFileName', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByCaseStudyStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseStudyStatus', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByCaseStudyStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caseStudyStatus', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByDocumentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentCount', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByDocumentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentCount', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByExportDirectory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportDirectory', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByExportDirectoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exportDirectory', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByFieldValuesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldValuesJson', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByFieldValuesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldValuesJson', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenBySingleLineValuesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'singleLineValuesJson', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenBySingleLineValuesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'singleLineValuesJson', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByTemplateSnapshotsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateSnapshotsJson', Sort.asc);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QAfterSortBy>
  thenByTemplateSnapshotsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateSnapshotsJson', Sort.desc);
    });
  }
}

extension ExportHistoryModelQueryWhereDistinct
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct> {
  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByBaseFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseFileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByCaseStudyStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'caseStudyStatus',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByDocumentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentCount');
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByErrorMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByExportDirectory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'exportDirectory',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByFieldValuesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'fieldValuesJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByOutputFiles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputFiles');
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctBySingleLineValuesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'singleLineValuesJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByTemplateIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateIds');
    });
  }

  QueryBuilder<ExportHistoryModel, ExportHistoryModel, QDistinct>
  distinctByTemplateSnapshotsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'templateSnapshotsJson',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension ExportHistoryModelQueryProperty
    on QueryBuilder<ExportHistoryModel, ExportHistoryModel, QQueryProperty> {
  QueryBuilder<ExportHistoryModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExportHistoryModel, String, QQueryOperations>
  baseFileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseFileName');
    });
  }

  QueryBuilder<ExportHistoryModel, String, QQueryOperations>
  caseStudyStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caseStudyStatus');
    });
  }

  QueryBuilder<ExportHistoryModel, DateTime?, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ExportHistoryModel, int, QQueryOperations>
  documentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentCount');
    });
  }

  QueryBuilder<ExportHistoryModel, String?, QQueryOperations>
  errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<ExportHistoryModel, String, QQueryOperations>
  exportDirectoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exportDirectory');
    });
  }

  QueryBuilder<ExportHistoryModel, String, QQueryOperations>
  fieldValuesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fieldValuesJson');
    });
  }

  QueryBuilder<ExportHistoryModel, List<String>, QQueryOperations>
  outputFilesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputFiles');
    });
  }

  QueryBuilder<ExportHistoryModel, String, QQueryOperations>
  singleLineValuesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'singleLineValuesJson');
    });
  }

  QueryBuilder<ExportHistoryModel, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ExportHistoryModel, List<int>, QQueryOperations>
  templateIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateIds');
    });
  }

  QueryBuilder<ExportHistoryModel, String, QQueryOperations>
  templateSnapshotsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateSnapshotsJson');
    });
  }
}
