import 'package:design/ui.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/route/routers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import '../mobile/field_input_mobile.dart';
import 'field_input_desktop.dart';

class InputPage extends BaseView<FieldsInputViewModel> {
  final List<int>? ids;

  const InputPage({super.key, this.ids});

  static String pathCompose(List<int>? ids) {
    final params = <String, String>{"ids": ids?.join(",") ?? ""};
    return "${RoutesPath.home}?${Uri(queryParameters: params).query}";
  }

  static List<int>? parseIds(GoRouterState state) {
    final idsString = state.uri.queryParameters['ids'];
    if (idsString == null) {
      return null;
    }
    return idsString.split(',').map((id) => int.parse(id.trim())).toList();
  }

  @override
  void awake(WrapperContext wrapperContext, FieldsInputViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    viewModel.performInit(ids);
  }

  @override
  Widget build(BuildContext context, FieldsInputViewModel viewModel) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: context.appColors?.containerBackground,
      appBar:
          !isDesktop
              ? AppBar(title: Text(AppLang.labelsTemplateFill.tr()))
              : null,
      body: isDesktop ? const FieldInputDesktop() : const FieldInputMobile(),
    );
  }

  @override
  AlertDialog alertDialogBuilder(
    ShowDialogEvent<dynamic> event,
    BuildContext dialogContext,
  ) {
    if (event.options != null &&
        event.title == AppLang.messagesSelectFromAiResults.tr()) {
      return AlertDialog(
        title: Text(event.title ?? ""),
        content: SizedBox(
          width: 600, // Wider for AI results
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: event.options!.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final fileName = event.options![index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _getFormattedDateFromFileName(fileName),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      leading: const Icon(
                        Icons.description_outlined,
                        color: Colors.blue,
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => Navigator.pop(dialogContext, index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLang.actionsCancel.tr()),
          ),
        ],
      );
    }
    return super.alertDialogBuilder(event, dialogContext);
  }

  String _getFormattedDateFromFileName(String fileName) {
    try {
      // Expecting format: ai_res_filename_timestamp.json
      final parts = fileName.split('_');
      if (parts.length >= 3) {
        final timestampStr = parts.last.split('.').first;
        final timestamp = int.tryParse(timestampStr);
        if (timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
        }
      }
    } catch (_) {}
    return "";
  }
}
