import 'package:data/data.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/features/src/home/widgets/desktop/components/fields_section_content.dart';
import 'package:docu_fill/features/src/home/widgets/desktop/components/fields_sidebar.dart';
import 'package:docu_fill/features/src/home/widgets/desktop/components/fields_summary.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FiledInputBox extends StatelessWidget {
  const FiledInputBox({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.composedTemplateUI,
      builder: (context, data) {
        if (data.isEmpty) return const SizedBox.shrink();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldsSidebar(),
            Expanded(
              child: StreamDataConsumer(
                streamData: viewModel.showSummary,
                builder: (context, showSummary) {
                  return IndexedStack(
                    index: showSummary ? 1 : 0,
                    children: [
                      _SectionContentSwitcher(data: data),
                      const FieldsSummary(),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionContentSwitcher extends StatelessWidget {
  final Map<String, List<dynamic>> data; // TemplateField list

  const _SectionContentSwitcher({required this.data});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.currentSectionIndex,
      builder: (context, index) {
        final sectionKey = viewModel.sections[index];
        final fields = (data[sectionKey] ?? []).cast<TemplateField>();
        return FieldsSectionContent(sectionTitle: sectionKey, fields: fields);
      },
    );
  }
}
