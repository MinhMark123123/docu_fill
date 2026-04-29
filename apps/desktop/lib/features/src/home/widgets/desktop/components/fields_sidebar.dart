import 'package:design/ui.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldsSidebar extends StatelessWidget {
  const FieldsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: context.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SidebarHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.sections.length,
              itemBuilder: (context, index) => _SidebarItem(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.size24),
      child: Text(
        AppLang.labelsConfigureTemplateFields.tr(),
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final int index;

  const _SidebarItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.currentSectionIndex,
      builder: (context, currentIndex) {
        final isSelected = currentIndex == index;
        final sectionKey = viewModel.sections[index];
        return InkWell(
          onTap: () => viewModel.updateCurrentSectionIndex(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.size24,
              vertical: Dimens.size16,
            ),
            decoration: _buildDecoration(context, isSelected),
            child: _SidebarItemContent(
              sectionKey: sectionKey,
              isSelected: isSelected,
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration(BuildContext context, bool isSelected) {
    return BoxDecoration(
      color: isSelected
          ? context.colorScheme.primaryContainer.withOpacity(0.3)
          : Colors.transparent,
      border: Border(
        left: BorderSide(
          color: isSelected ? context.colorScheme.primary : Colors.transparent,
          width: 4,
        ),
      ),
    );
  }
}

class _SidebarItemContent extends StatelessWidget {
  final String sectionKey;
  final bool isSelected;

  const _SidebarItemContent({
    required this.sectionKey,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getSectionIcon(sectionKey),
          size: Dimens.size20,
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurfaceVariant,
        ),
        Dimens.spacing.horizontal(Dimens.size16),
        Expanded(
          child: Text(
            sectionKey,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getSectionIcon(String sectionKey) {
    if (sectionKey == AppLang.labelsOverview.tr()) {
      return Icons.dashboard_outlined;
    }
    if (sectionKey == AppLang.labelsCommon.tr()) return Icons.layers;
    if (sectionKey == AppLang.labelsGeneral.tr()) return Icons.info_outline;
    if (sectionKey == AppLang.labelsGeneralInfo.tr()) return Icons.info_outline;
    return Icons.folder_open;
  }
}
