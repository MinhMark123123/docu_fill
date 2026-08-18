import 'package:design/ui.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/features/src/dashboard/components/dashboard_stat_card.dart';
import 'package:docu_fill/features/src/dashboard/components/monthly_export_chart.dart';
import 'package:docu_fill/features/src/dashboard/components/top_templates_panel.dart';
import 'package:docu_fill/features/src/dashboard/view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class DashboardPage extends BaseView<DashboardViewModel> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, DashboardViewModel viewModel) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLang.labelsDashboard.tr()),
        backgroundColor: context.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          _buildPeriodSelector(context, viewModel),
          Dimens.spacing.horizontal(Dimens.size24),
        ],
      ),
      body: Column(
        children: [
          _buildKPIs(context),
          Dimens.spacing.vertical(Dimens.size24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: StreamDataConsumer(
                    streamData: viewModel.dailyExports,
                    builder: (context, dailyExports) {
                      return MonthlyExportChart(
                        dailyExports: dailyExports,
                        daysInMonth: viewModel.daysInMonth,
                      );
                    },
                  ),
                ),
                Dimens.spacing.horizontal(Dimens.size24),
                Expanded(
                  child: StreamDataConsumer(
                    streamData: viewModel.topTemplates,
                    builder: (context, topTemplates) {
                      return TopTemplatesPanel(topTemplates: topTemplates);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIs(BuildContext context) {
    return Row(
      spacing: Dimens.size16,
      children: [
        Expanded(
          child: StreamDataConsumer(
            streamData: getViewModel<DashboardViewModel>().totalExportedFiles,
            builder: (context, totalFiles) {
              return DashboardStatCard(
                title: AppLang.labelsTotalExportedFiles.tr(),
                value: "$totalFiles",
                icon: Icons.insert_drive_file_outlined,
                color: context.colorScheme.primary,
              );
            },
          ),
        ),
        Expanded(
          child: StreamDataConsumer(
            streamData: getViewModel<DashboardViewModel>().totalExportActions,
            builder: (context, totalActions) {
              return DashboardStatCard(
                title: AppLang.labelsTotalExportActions.tr(),
                value: "$totalActions",
                icon: Icons.sync_outlined,
                color: context.colorScheme.secondary,
              );
            },
          ),
        ),
        Expanded(
          child: StreamDataConsumer(
            streamData: getViewModel<DashboardViewModel>().successRate,
            builder: (context, successRate) {
              return DashboardStatCard(
                title: AppLang.labelsSuccessRate.tr(),
                value: "${successRate.toStringAsFixed(1)}%",
                icon: Icons.check_circle_outline,
                color:
                    successRate >= 90
                        ? Colors.green
                        : (successRate >= 70 ? Colors.orange : Colors.red),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    return StreamDataConsumer(
      streamData: viewModel.selectedYear,
      builder: (context, selectedYear) {
        return StreamDataConsumer(
          streamData: viewModel.selectedMonth,
          builder: (context, selectedMonth) {
            final currentYear = DateTime.now().year;
            final years = List.generate(5, (index) => currentYear - index);
            final months = List.generate(12, (index) => index + 1);

            return Row(
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  onChanged: (val) {
                    if (val != null) {
                      viewModel.updatePeriod(selectedYear, val);
                    }
                  },
                  items:
                      months.map((m) {
                        return DropdownMenuItem<int>(
                          value: m,
                          child: Text("Month $m"),
                        );
                      }).toList(),
                ),
                Dimens.spacing.horizontal(Dimens.size12),
                DropdownButton<int>(
                  value: selectedYear,
                  onChanged: (val) {
                    if (val != null) {
                      viewModel.updatePeriod(val, selectedMonth);
                    }
                  },
                  items:
                      years.map((y) {
                        return DropdownMenuItem<int>(
                          value: y,
                          child: Text("$y"),
                        );
                      }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
