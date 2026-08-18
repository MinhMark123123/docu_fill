import 'dart:math';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class MonthlyExportChart extends StatelessWidget {
  final Map<int, int> dailyExports;
  final int daysInMonth;

  const MonthlyExportChart({
    super.key,
    required this.dailyExports,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = dailyExports.values.isNotEmpty
        ? dailyExports.values.reduce(max)
        : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: Dimens.radii.borderMedium(),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLang.labelsDailyExports.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Dimens.spacing.vertical(Dimens.size24),
            Expanded(
              child: maxCount == 0
                  ? _buildEmptyState(context)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = (constraints.maxWidth - (daysInMonth - 1) * 4) / daysInMonth;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(daysInMonth, (index) {
                            final day = index + 1;
                            final count = dailyExports[day] ?? 0;
                            final ratio = maxCount > 0 ? count / maxCount : 0.0;
                            // Ensure a minimum height if count > 0, so it's visible
                            final height = ratio * (constraints.maxHeight - 30);

                            return _BarItem(
                              day: day,
                              count: count,
                              height: height,
                              width: max(barWidth, Dimens.size8),
                            );
                          }),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No exports recorded for this period.',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _BarItem extends StatefulWidget {
  final int day;
  final int count;
  final double height;
  final double width;

  const _BarItem({
    required this.day,
    required this.count,
    required this.height,
    required this.width,
  });

  @override
  State<_BarItem> createState() => _BarItemState();
}

class _BarItemState extends State<_BarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final barColor = widget.count > 0
        ? (_isHovered
            ? context.colorScheme.primary
            : context.colorScheme.primary.withValues(alpha: 0.7))
        : context.colorScheme.outlineVariant.withValues(alpha: 0.3);

    return Tooltip(
      message: "Day ${widget.day}: ${widget.count} ${AppLang.labelsExports.tr()}",
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: max(widget.height, widget.count > 0 ? 4.0 : 0.0),
              width: widget.width,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(widget.width / 2),
                ),
              ),
            ),
            Dimens.spacing.vertical(Dimens.size8),
            SizedBox(
              width: widget.width,
              child: Text(
                widget.day % 5 == 0 || widget.day == 1 || widget.day == 31
                    ? "${widget.day}"
                    : "",
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
