import 'package:design/ui.dart';
import 'package:docu_fill/core/src/base_view.dart';
import 'package:docu_fill/features/src/tool/view_model/tool_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class ToolPage extends BaseView<ToolViewModel> {
  const ToolPage({super.key});

  @override
  Widget build(BuildContext context, ToolViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.labelsTools.tr()), centerTitle: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLang.labelsQuickActions.tr(),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Dimens.size24),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800 ? 3 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: Dimens.size16,
                  crossAxisSpacing: Dimens.size16,
                  childAspectRatio: 1.5,
                  children: [
                    _ToolCard(
                      title: AppLang.actionsExtractImages.tr(),
                      description: AppLang.messagesExtractImagesDesc.tr(),
                      icon: Icons.image_search_outlined,
                      onTap: () => viewModel.extractImagesFromDocument(),
                      color: Colors.blue,
                    ),
                    // Add more tool cards here in the future
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ToolCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.size16),
        side: BorderSide(color: context.colorScheme.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(Dimens.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(Dimens.size8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimens.size8),
                ),
                child: Icon(icon, color: color, size: Dimens.size24),
              ),
              const Spacer(),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Dimens.size4),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
