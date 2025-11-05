import 'package:docu_fill/data/src/entities/template_config_model.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatabase {
  static final IsarDatabase _instance = IsarDatabase._internal();

  static IsarDatabase get instance => _instance;

  late Isar _isar;

  Isar get isar => _isar;

  IsarDatabase._internal();

  /// Initialize the Isar database
  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TemplateConfigModelSchema],
      directory: dir.path,
      name: 'docu_fill',
    );
  }

  /// Close the database connection
  Future<void> close() async {
    await _isar.close();
  }
}
