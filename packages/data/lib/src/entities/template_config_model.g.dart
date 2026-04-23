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
    r'fields': PropertySchema(
      id: 0,
      name: r'fields',
      type: IsarType.objectList,

      target: r'TemplateFieldModel',
    ),
    r'pathTemplate': PropertySchema(
      id: 1,
      name: r'pathTemplate',
      type: IsarType.string,
    ),
    r'templateName': PropertySchema(
      id: 2,
      name: r'templateName',
      type: IsarType.string,
    ),
    r'version': PropertySchema(id: 3, name: r'version', type: IsarType.string),
  },

  estimateSize: _templateConfigModelEstimateSize,
  serialize: _templateConfigModelSerialize,
  deserialize: _templateConfigModelDeserialize,
  deserializeProp: _templateConfigModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'templateName': IndexSchema(
      id: -879412639570306553,
      name: r'templateName',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'templateName',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'TemplateFieldModel': TemplateFieldModelSchema},

  getId: _templateConfigModelGetId,
  getLinks: _templateConfigModelGetLinks,
  attach: _templateConfigModelAttach,
  version: '3.3.0-dev.3',
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
  writer.writeObjectList<TemplateFieldModel>(
    offsets[0],
    allOffsets,
    TemplateFieldModelSchema.serialize,
    object.fields,
  );
  writer.writeString(offsets[1], object.pathTemplate);
  writer.writeString(offsets[2], object.templateName);
  writer.writeString(offsets[3], object.version);
}

TemplateConfigModel _templateConfigModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TemplateConfigModel(
    fields:
        reader.readObjectList<TemplateFieldModel>(
          offsets[0],
          TemplateFieldModelSchema.deserialize,
          allOffsets,
          TemplateFieldModel(),
        ) ??
        const [],
    id: id,
    pathTemplate: reader.readStringOrNull(offsets[1]) ?? '',
    templateName: reader.readStringOrNull(offsets[2]) ?? '',
    version: reader.readStringOrNull(offsets[3]) ?? '',
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
      return (reader.readObjectList<TemplateFieldModel>(
                offset,
                TemplateFieldModelSchema.deserialize,
                allOffsets,
                TemplateFieldModel(),
              ) ??
              const [])
          as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 3:
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

extension TemplateConfigModelByIndex on IsarCollection<TemplateConfigModel> {
  Future<TemplateConfigModel?> getByTemplateName(String templateName) {
    return getByIndex(r'templateName', [templateName]);
  }

  TemplateConfigModel? getByTemplateNameSync(String templateName) {
    return getByIndexSync(r'templateName', [templateName]);
  }

  Future<bool> deleteByTemplateName(String templateName) {
    return deleteByIndex(r'templateName', [templateName]);
  }

  bool deleteByTemplateNameSync(String templateName) {
    return deleteByIndexSync(r'templateName', [templateName]);
  }

  Future<List<TemplateConfigModel?>> getAllByTemplateName(
    List<String> templateNameValues,
  ) {
    final values = templateNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'templateName', values);
  }

  List<TemplateConfigModel?> getAllByTemplateNameSync(
    List<String> templateNameValues,
  ) {
    final values = templateNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'templateName', values);
  }

  Future<int> deleteAllByTemplateName(List<String> templateNameValues) {
    final values = templateNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'templateName', values);
  }

  int deleteAllByTemplateNameSync(List<String> templateNameValues) {
    final values = templateNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'templateName', values);
  }

  Future<Id> putByTemplateName(TemplateConfigModel object) {
    return putByIndex(r'templateName', object);
  }

  Id putByTemplateNameSync(
    TemplateConfigModel object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'templateName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTemplateName(List<TemplateConfigModel> objects) {
    return putAllByIndex(r'templateName', objects);
  }

  List<Id> putAllByTemplateNameSync(
    List<TemplateConfigModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'templateName', objects, saveLinks: saveLinks);
  }
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

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterWhereClause>
  templateNameEqualTo(String templateName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'templateName',
          value: [templateName],
        ),
      );
    });
  }

  QueryBuilder<TemplateConfigModel, TemplateConfigModel, QAfterWhereClause>
  templateNameNotEqualTo(String templateName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateName',
                lower: [],
                upper: [templateName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateName',
                lower: [templateName],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateName',
                lower: [templateName],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'templateName',
                lower: [],
                upper: [templateName],
                includeUpper: false,
              ),
            );
      }
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

  QueryBuilder<TemplateConfigModel, List<TemplateFieldModel>, QQueryOperations>
  fieldsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fields');
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

  QueryBuilder<TemplateConfigModel, String, QQueryOperations>
  versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
