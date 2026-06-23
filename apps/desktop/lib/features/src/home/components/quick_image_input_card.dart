import 'dart:io';

import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/home/view_model/quick_image_input_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class QuickImageInputCard extends StatelessWidget {
  final TemplateField field;
  final String? path;
  final bool isTargetHovered;
  final bool isFeedback;
  final QuickImageInputViewModel viewModel;

  const QuickImageInputCard({
    super.key,
    required this.field,
    required this.path,
    required this.isTargetHovered,
    this.isFeedback = false,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = path != null && path!.isNotEmpty;

    return Card(
      elevation: isFeedback ? 8 : (isTargetHovered ? 4 : 1),
      shadowColor:
          isTargetHovered ? context.colorScheme.primary.withOpacity(0.4) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isTargetHovered
                  ? context.colorScheme.primary
                  : (hasImage
                      ? context.colorScheme.outlineVariant.withOpacity(0.5)
                      : Colors.transparent),
          width: isTargetHovered ? 2.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(field: field, isTargetHovered: isTargetHovered),
          Expanded(
            child: _CardBody(
              field: field,
              path: path,
              hasImage: hasImage,
              isTargetHovered: isTargetHovered,
              isFeedback: isFeedback,
              viewModel: viewModel,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final TemplateField field;
  final bool isTargetHovered;

  const _CardHeader({required this.field, required this.isTargetHovered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color:
          isTargetHovered
              ? context.colorScheme.primaryContainer.withOpacity(0.4)
              : context.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              field.label,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (field.required)
            Text(
              " *",
              style: TextStyle(
                color: context.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final TemplateField field;
  final String? path;
  final bool hasImage;
  final bool isTargetHovered;
  final bool isFeedback;
  final QuickImageInputViewModel viewModel;

  const _CardBody({
    required this.field,
    required this.path,
    required this.hasImage,
    required this.isTargetHovered,
    required this.isFeedback,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (hasImage) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(path!), fit: BoxFit.cover),
          if (!isFeedback)
            Positioned(
              bottom: 8,
              left: 8,
              child: Tooltip(
                message: AppLang.labelsDragToReorder.tr(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.drag_indicator_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          if (!isFeedback)
            Positioned(
              top: 8,
              right: 8,
              child: Tooltip(
                message: AppLang.labelsRemoveImage.tr(),
                child: Material(
                  color: Colors.black.withOpacity(0.6),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => viewModel.clearFieldImage(field.key),
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return CustomPaint(
      painter: _DashedBorderPainter(
        color:
            isTargetHovered
                ? context.colorScheme.primary
                : context.colorScheme.outlineVariant.withOpacity(0.8),
      ),
      child: InkWell(
        onTap: () => viewModel.pickSingleImageForField(field.key),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color:
                  isTargetHovered
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              AppLang.actionsPickImage.tr(),
              style: context.textTheme.labelMedium?.copyWith(
                color:
                    isTargetHovered
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 4;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(0),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
