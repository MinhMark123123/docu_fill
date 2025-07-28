// Assuming your TemplateConfig and TemplateField from the prompt are in a shared location
// or you create separate domain entities. For this example, we use them directly.
import 'package:docu_fill/data/src/template_config.dart';

abstract class TemplateRepository {
  Future<List<TemplateConfig>> getAllTemplates();
  Future<TemplateConfig?> getTemplateByName(String name);
  Future<void> saveTemplate(TemplateConfig template);
  Future<void> deleteTemplateByName(String name);
  Stream<List<TemplateConfig>> watchAllTemplates();
  Stream<TemplateConfig?> watchTemplateByName(String name);
}
