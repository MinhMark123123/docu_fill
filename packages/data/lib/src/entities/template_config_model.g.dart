// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_config_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTemplateConfigModelCollection on Isar {
  IsarCollection<TemplateConfigModel> get templateConfigModels =>
      this.collection();
}

const TemplateConfigModelSchema = CollectionSchema(
  name: r'TemplateConfigModel',
  id: 8002399659655026230,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'fields': PropertySchema(
      id: 2,
      name: r'fields',
      type: IsarType.objectList,

      target: r'TemplateFieldModel',
    ),
    r'isDeleted': PropertySchema(
      id: 3,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'pathTemplate': PropertySchema(
      id: 4,
      name: r'pathTemplate',
      type: IsarType.string,
    ),
    r'templateName': PropertySchema(
      id: 5,
      name: r'templateName',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(id: 7, name: r'version', type: IsarType.string),
  },

  estimateSize: _templateConfigModelEstimateSize,
  serialize: _templateConfigModelSerialize,
  deserialize: _templateConfigModelDeserialize,
  deserializeProp: _templateConfigModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'TemplateFieldModel': TemplateFieldModelSchema},

  getId: _templateConfigModelGetId,
  getLinks: _templateConfigModelGetLinks,
  attach: _templateConfigModelAttach,
  version: '3.3.2',
);

int _templateConfigModelEstimateSize(
  TemplateConfigModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fields.length * 3;
  {
    final offsets = allOffsets[TemplateFieldModel]!;
    for (var i = 0; i < object.fields.length; i++) {
      final value = object.fields[i];
      bytesCount += TemplateFieldModelSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.pathTemplate.length * 3;
  bytesCount += 3 + object.templateName.length * 3;
  bytesCount += 3 + object.version.length * 3;
  return bytesCount;
}

void _templateConfigModelSerialize(
  TemplateConfigModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeObjectList<TemplateFieldModel>(
    offsets[2],
    allOffsets,
    TemplateFieldModelSchema.serialize,
    object.fields,
  );
  writer.writeBool(offsets[3], object.isDeleted);
  writer.writeString(offsets[4], object.pathTemplate);
  writer.writeString(offsets[5], object.templateName);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeString(offsets[7], object.version);
}

TemplateConfigModel _templateConfigModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TemplateConfigModel(
    createdAt: reader.readDateTimeOrNull(offsets[0]),
    deletedAt: reader.readDateTimeOrNull(offsets[1]),
    fields:
        reader.readObjectList<TemplateFieldModel>(
          offsets[2],
          TemplateFieldModelSchema.deserialize,
          allOffsets,
          TemplateFieldModel(),
        ) ??
        const [],
    id: id,
    isDeleted: reader.readBoolOrNull(offsets[3]),
    pathTemplate: reader.readStringOrNull(offsets[4]) ?? '',
    templateName: reader.readStringOrNull(offsets[5]) ?? '',
    updatedAt: reader.readDateTimeOrNull(offsets[6]),
    version: reader.readStringOrNull(offsets[7]) ?? '',
  );
  return object;
}

P _templateConfigModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readObjectList<TemplateFieldModel>(
                offset,
                TemplateFieldModelSchema.deserialize,
                allOffsets,
                TemplateFieldModel(),
              ) ??
              const [])
          as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _templateConfigModelGetId(TemplateConfigModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _templateConfigModelGetLinks(
  TemplateConfigModel object,
) {
  return [];
}

void _templateConfigModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  TemplateConfigModel object,
) {
  object.id = id;
}

extension TemplateConfigModelQueryWhereSort
    on QueryBuilder<TemplateConfigModel, TemplateConfigModel, QWhere> {
  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TemplateConfigModelQueryWhere
    on QueryBuilder<TemplateConfigModel, TemplateConfigModel, QWhereClause> {
  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterWhereClause>
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

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterWhereClause>
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

extension TemplateConfigModelQueryFilter
    on
        QueryBuilder<
          TemplateConfigModel,
          TemplateConfigModel,
          QFilterCondition
        > {
  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
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

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
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

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
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

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  deletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  deletedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  fieldsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fields', length, true, length, true);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  fieldsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fields', 0, true, 0, true);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  fieldsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fields', 0, false, 999999, true);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  fieldsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fields', 0, true, length, include);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  fieldsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fields', length, include, 999999, true);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  fieldsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fields',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
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

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
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

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
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

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  isDeletedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'isDeleted'),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  isDeletedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'isDeleted'),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  isDeletedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDeleted', value: value),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pathTemplate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pathTemplate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pathTemplate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pathTemplate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'pathTemplate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'pathTemplate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'pathTemplate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'pathTemplate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pathTemplate', value: ''),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  pathTemplateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pathTemplate', value: ''),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'templateName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'templateName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'templateName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'templateName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'templateName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'templateName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'templateName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'templateName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'templateName', value: ''),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  templateNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'templateName', value: ''),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'version',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'version',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'version',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'version', value: ''),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'version', value: ''),
      );
    });
  }
}

extension TemplateConfigModelQueryObject
    on
        QueryBuilder<
          TemplateConfigModel,
          TemplateConfigModel,
          QFilterCondition
        > {
  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterFilterCondition>
  fieldsElement(FilterQuery<TemplateFieldModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'fields');
    });
  }
}

extension TemplateConfigModelQueryLinks
    on
        QueryBuilder<
          TemplateConfigModel,
          TemplateConfigModel,
          QFilterCondition
        > {}

extension TemplateConfigModelQuerySortBy
    on QueryBuilder<TemplateConfigModel, TemplateConfigModel, QSortBy> {
  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByPathTemplate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathTemplate', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByPathTemplateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathTemplate', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByTemplateName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateName', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByTemplateNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateName', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension TemplateConfigModelQuerySortThenBy
    on QueryBuilder<TemplateConfigModel, TemplateConfigModel, QSortThenBy> {
  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByPathTemplate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathTemplate', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByPathTemplateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathTemplate', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByTemplateName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateName', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByTemplateNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateName', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterSortBy>
  thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension TemplateConfigModelQueryWhereDistinct
    on QueryBuilder<TemplateConfigModel, TemplateConfigModel, QDistinct> {
  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QDistinct>
  distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QDistinct>
  distinctByPathTemplate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pathTemplate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QDistinct>
  distinctByTemplateName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QDistinct>
  distinctByVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version', caseSensitive: caseSensitive);
    });
  }
}

extension TemplateConfigModelQueryProperty
    on QueryBuilder<TemplateConfigModel, TemplateConfigModel, QQueryProperty> {
  QueryBuilder<TemplateConfigModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TemplateConfigModel, DateTime?, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TemplateConfigModel, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<TemplateConfigModel, List<TemplateFieldModel>, QQueryOperations>
  fieldsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fields');
    });
  }

  QueryBuilder<TemplateConfigModel, bool?, QQueryOperations>
  isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<TemplateConfigModel, String, QQueryOperations>
  pathTemplateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pathTemplate');
    });
  }

  QueryBuilder<TemplateConfigModel, String, QQueryOperations>
  templateNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateName');
    });
  }

  QueryBuilder<TemplateConfigModel, DateTime?, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<TemplateConfigModel, String, QQueryOperations>
  versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
