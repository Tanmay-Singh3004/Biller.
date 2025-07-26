// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransactionItemCollection on Isar {
  IsarCollection<TransactionItem> get transactionItems => this.collection();
}

const TransactionItemSchema = CollectionSchema(
  name: r'TransactionItem',
  id: 4862152759336924711,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'itemId': PropertySchema(
      id: 1,
      name: r'itemId',
      type: IsarType.long,
    ),
    r'pricePerUnit': PropertySchema(
      id: 2,
      name: r'pricePerUnit',
      type: IsarType.double,
    ),
    r'quantity': PropertySchema(
      id: 3,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'totalPrice': PropertySchema(
      id: 4,
      name: r'totalPrice',
      type: IsarType.double,
    ),
    r'transactionId': PropertySchema(
      id: 5,
      name: r'transactionId',
      type: IsarType.long,
    )
  },
  estimateSize: _transactionItemEstimateSize,
  serialize: _transactionItemSerialize,
  deserialize: _transactionItemDeserialize,
  deserializeProp: _transactionItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'transactionId': IndexSchema(
      id: 8561542235958051982,
      name: r'transactionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transactionId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'itemId': IndexSchema(
      id: -5342806140158601489,
      name: r'itemId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'itemId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _transactionItemGetId,
  getLinks: _transactionItemGetLinks,
  attach: _transactionItemAttach,
  version: '3.1.0+1',
);

int _transactionItemEstimateSize(
  TransactionItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _transactionItemSerialize(
  TransactionItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.itemId);
  writer.writeDouble(offsets[2], object.pricePerUnit);
  writer.writeLong(offsets[3], object.quantity);
  writer.writeDouble(offsets[4], object.totalPrice);
  writer.writeLong(offsets[5], object.transactionId);
}

TransactionItem _transactionItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransactionItem();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.itemId = reader.readLong(offsets[1]);
  object.pricePerUnit = reader.readDouble(offsets[2]);
  object.quantity = reader.readLong(offsets[3]);
  object.transactionId = reader.readLong(offsets[5]);
  return object;
}

P _transactionItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transactionItemGetId(TransactionItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transactionItemGetLinks(TransactionItem object) {
  return [];
}

void _transactionItemAttach(
    IsarCollection<dynamic> col, Id id, TransactionItem object) {
  object.id = id;
}

extension TransactionItemQueryWhereSort
    on QueryBuilder<TransactionItem, TransactionItem, QWhere> {
  QueryBuilder<TransactionItem, TransactionItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhere>
      anyTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'transactionId'),
      );
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhere> anyItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'itemId'),
      );
    });
  }
}

extension TransactionItemQueryWhere
    on QueryBuilder<TransactionItem, TransactionItem, QWhereClause> {
  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
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

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      transactionIdEqualTo(int transactionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'transactionId',
        value: [transactionId],
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      transactionIdNotEqualTo(int transactionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionId',
              lower: [],
              upper: [transactionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionId',
              lower: [transactionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionId',
              lower: [transactionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionId',
              lower: [],
              upper: [transactionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      transactionIdGreaterThan(
    int transactionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'transactionId',
        lower: [transactionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      transactionIdLessThan(
    int transactionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'transactionId',
        lower: [],
        upper: [transactionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      transactionIdBetween(
    int lowerTransactionId,
    int upperTransactionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'transactionId',
        lower: [lowerTransactionId],
        includeLower: includeLower,
        upper: [upperTransactionId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      itemIdEqualTo(int itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'itemId',
        value: [itemId],
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      itemIdNotEqualTo(int itemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      itemIdGreaterThan(
    int itemId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'itemId',
        lower: [itemId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      itemIdLessThan(
    int itemId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'itemId',
        lower: [],
        upper: [itemId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterWhereClause>
      itemIdBetween(
    int lowerItemId,
    int upperItemId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'itemId',
        lower: [lowerItemId],
        includeLower: includeLower,
        upper: [upperItemId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TransactionItemQueryFilter
    on QueryBuilder<TransactionItem, TransactionItem, QFilterCondition> {
  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      itemIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      itemIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemId',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      itemIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemId',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      itemIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      pricePerUnitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pricePerUnit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      pricePerUnitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pricePerUnit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      pricePerUnitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pricePerUnit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      pricePerUnitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pricePerUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      totalPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      totalPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      totalPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      totalPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      transactionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      transactionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      transactionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterFilterCondition>
      transactionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TransactionItemQueryObject
    on QueryBuilder<TransactionItem, TransactionItem, QFilterCondition> {}

extension TransactionItemQueryLinks
    on QueryBuilder<TransactionItem, TransactionItem, QFilterCondition> {}

extension TransactionItemQuerySortBy
    on QueryBuilder<TransactionItem, TransactionItem, QSortBy> {
  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy> sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerUnit', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByPricePerUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerUnit', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByTotalPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      sortByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }
}

extension TransactionItemQuerySortThenBy
    on QueryBuilder<TransactionItem, TransactionItem, QSortThenBy> {
  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy> thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerUnit', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByPricePerUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerUnit', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByTotalPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.desc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.asc);
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QAfterSortBy>
      thenByTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionId', Sort.desc);
    });
  }
}

extension TransactionItemQueryWhereDistinct
    on QueryBuilder<TransactionItem, TransactionItem, QDistinct> {
  QueryBuilder<TransactionItem, TransactionItem, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QDistinct> distinctByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId');
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QDistinct>
      distinctByPricePerUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pricePerUnit');
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QDistinct>
      distinctByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPrice');
    });
  }

  QueryBuilder<TransactionItem, TransactionItem, QDistinct>
      distinctByTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionId');
    });
  }
}

extension TransactionItemQueryProperty
    on QueryBuilder<TransactionItem, TransactionItem, QQueryProperty> {
  QueryBuilder<TransactionItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransactionItem, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TransactionItem, int, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<TransactionItem, double, QQueryOperations>
      pricePerUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pricePerUnit');
    });
  }

  QueryBuilder<TransactionItem, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<TransactionItem, double, QQueryOperations> totalPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPrice');
    });
  }

  QueryBuilder<TransactionItem, int, QQueryOperations> transactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionId');
    });
  }
}
