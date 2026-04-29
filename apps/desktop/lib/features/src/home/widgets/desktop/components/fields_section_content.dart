import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/home/widgets/desktop/components/field_items.dart';
import 'package:docu_fill/features/src/home/widgets/desktop/components/fields_navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class FieldsSectionContent extends StatelessWidget {
  final String sectionTitle;
  final List<TemplateField> fields;

  const FieldsSectionContent({
    super.key,
    required this.sectionTitle,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimens.size32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: sectionTitle),
          Dimens.spacing.vertical(Dimens.size32),
          _FieldsList(fields: fields),
          Dimens.spacing.vertical(Dimens.size40),
          const FieldsNavigationButtons(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SectionIcon(title: title),
        Dimens.spacing.horizontal(Dimens.size16),
        _SectionTitle(title: title),
      ],
    );
  }
}

class _SectionIcon extends StatelessWidget {
  final String title;

  const _SectionIcon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.size12),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimens.size12),
      ),
      child: Icon(_getIcon(title), color: context.colorScheme.primary),
    );
  }

  IconData _getIcon(String title) {
    if (title == AppLang.labelsOverview.tr()) return Icons.dashboard_outlined;
    if (title == AppLang.labelsCommon.tr()) return Icons.layers;
    if (title == AppLang.labelsGeneral.tr()) return Icons.info_outline;
    if (title == AppLang.labelsGeneralInfo.tr()) return Icons.info_outline;
    return Icons.folder_open;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          AppLang.messagesFillInfoBelow.tr(),
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FieldsList extends StatelessWidget {
  final List<TemplateField> fields;

  const _FieldsList({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.size32),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withOpacity(0.1),
        borderRadius: Dimens.radii.borderLarge(),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        spacing: Dimens.size24,
        children: fields.map((e) => FieldItemBuilder(field: e)).toList(),
      ),
    );
  }
}
