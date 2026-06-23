import 'package:data/data.dart';
import 'package:isar_community/isar.dart';

Future<void> performMigrationIfNeeded(Isar isar) async {
  final listItemsDeletedNull =
      await isar.templateConfigModels.filter().isDeletedIsNull().findAll();
  final migratesData =
      listItemsDeletedNull.map((e) => e.copyWith(isDeleted: false)).toList();
  await isar.writeTxn(() async {
    isar.templateConfigModels.putAll(migratesData);
  });
}
