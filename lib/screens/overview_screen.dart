import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../providers/glucose_data_provider.dart';
import '../providers/medication_data_provider.dart';
import '../providers/glucose_trend_data_provider.dart';

class OverviewScreenContent extends StatefulWidget {
  final VoidCallback? onLogButtonPressed;

  const OverviewScreenContent({super.key, this.onLogButtonPressed});

  @override
  State<OverviewScreenContent> createState() => _OverviewScreenContentState();
}

class _OverviewScreenContentState extends State<OverviewScreenContent> {
  // Keep loading state for overall screen
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get providers to fetch data
      final glucoseProvider = Provider.of<GlucoseDataProvider>(
        context,
        listen: false,
      );
      final medicationProvider = Provider.of<MedicationDataProvider>(
        context,
        listen: false,
      );
      final trendProvider = Provider.of<GlucoseTrendDataProvider>(
        context,
        listen: false,
      );

      // Load all data using providers
      await Future.wait([
        glucoseProvider.getLatestGlucoseData(),
        medicationProvider.getTodaysMedicationData(),
        trendProvider.getGlucoseTrendData(),
      ]);
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: LiquidPullToRefresh(
          onRefresh: () async {
            // Refresh both provider data and other data
            final glucoseProvider = Provider.of<GlucoseDataProvider>(
              context,
              listen: false,
            );
            final medicationProvider = Provider.of<MedicationDataProvider>(
              context,
              listen: false,
            );
            final trendProvider = Provider.of<GlucoseTrendDataProvider>(
              context,
              listen: false,
            );
            await Future.wait([
              glucoseProvider.refreshData(),
              medicationProvider.refreshData(),
              trendProvider.refreshData(),
            ]);
          },
          color: theme.colorScheme.primary,
          backgroundColor: theme.scaffoldBackgroundColor,
          height: 80,
          animSpeedFactor: 6,
          showChildOpacityTransition: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Icon Testing Section

                  // Blood Glucose Card
                  Consumer<GlucoseDataProvider>(
                    builder: (context, glucoseProvider, child) {
                      return Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: ShapeDecoration(
                          color: theme.scaffoldBackgroundColor,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 16,
                              cornerSmoothing: 0.6,
                            ),
                            side: BorderSide(
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF3A3A3A)
                                  : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          shadows: [
                            BoxShadow(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: ShapeDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF3A3A3A)
                                    : Colors.white,
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 16,
                                    cornerSmoothing: 0.6,
                                  ),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.droplet,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Blood Glucose',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  glucoseProvider.isLoading &&
                                          !glucoseProvider.hasData
                                      ? Container(
                                          width: 80,
                                          height: 20,
                                          decoration: ShapeDecoration(
                                            color:
                                                theme.brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF3A3A3A)
                                                : const Color(0xFFF0F1F7),
                                            shape: SmoothRectangleBorder(
                                              borderRadius: SmoothBorderRadius(
                                                cornerRadius: 6,
                                                cornerSmoothing: 0.6,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          glucoseProvider
                                              .getGlucoseValueString(),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                ],
                              ),
                            ),
                            glucoseProvider.isLoading &&
                                    !glucoseProvider.hasData
                                ? Container(
                                    width: 120,
                                    height: 16,
                                    decoration: ShapeDecoration(
                                      color: theme.brightness == Brightness.dark
                                          ? const Color(0xFF3A3A3A)
                                          : const Color(0xFFF0F1F7),
                                      shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: 6,
                                          cornerSmoothing: 0.6,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    glucoseProvider.getTimeSinceLastReading(),
                                    style: theme.textTheme.bodySmall,
                                  ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Upcoming Section
                  Text(
                    'Upcoming',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medication Reminder Card
                  Consumer<MedicationDataProvider>(
                    builder: (context, medicationProvider, child) {
                      if (medicationProvider.isLoading &&
                          !medicationProvider.hasData) {
                        // Skeleton loading for medication reminder
                        return Skeletonizer(
                          enabled: true,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: theme.brightness == Brightness.dark
                                        ? const Color(0xFF2A2A2A)
                                        : const Color(0xFFF0F1F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.pills,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 140,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color:
                                              theme.brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF3A3A3A)
                                              : const Color(0xFFF0F1F7),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 80,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color:
                                              theme.brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF3A3A3A)
                                              : const Color(0xFFF0F1F7),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: theme.brightness == Brightness.dark
                                        ? const Color(0xFF3A3A3A)
                                        : const Color(0xFFF0F1F7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (medicationProvider
                          .todaysMedications
                          .isNotEmpty) {
                        // Today's medications list
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Build medication list
                            ...medicationProvider.todaysMedications.map((
                              medication,
                            ) {
                              final isPastDue = medication['isPastDue'] as bool;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: ShapeDecoration(
                                  color: isPastDue
                                      ? theme.scaffoldBackgroundColor
                                            .withOpacity(0.5)
                                      : theme.scaffoldBackgroundColor,
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 16,
                                      cornerSmoothing: 0.6,
                                    ),
                                    side: BorderSide(
                                      color: isPastDue
                                          ? (theme.brightness == Brightness.dark
                                                ? const Color(0xFF3A3A3A)
                                                : Colors.grey[300]!)
                                          : (theme.brightness == Brightness.dark
                                                ? const Color(0xFF3A3A3A)
                                                : Colors.grey[200]!),
                                      width: 1,
                                    ),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.black.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: ShapeDecoration(
                                        color: isPastDue
                                            ? (theme.brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF3A3A3A)
                                                  : Colors.grey[200])
                                            : (theme.brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF3A3A3A)
                                                  : Colors.white),
                                        shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: 14,
                                            cornerSmoothing: 0.6,
                                          ),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.pills,
                                          color: isPastDue
                                              ? theme.colorScheme.primary
                                                    .withOpacity(0.4)
                                              : theme.colorScheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medication['name'],
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isPastDue
                                                      ? theme
                                                            .textTheme
                                                            .titleMedium
                                                            ?.color
                                                            ?.withOpacity(0.6)
                                                      : theme
                                                            .textTheme
                                                            .titleMedium
                                                            ?.color,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Show dosage if available
                                          if (medication['dosage'] != null &&
                                              medication['dosage']
                                                  .toString()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 4,
                                              ),
                                              child: Text(
                                                medication['dosage'],
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: isPastDue
                                                          ? theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.color
                                                                ?.withOpacity(
                                                                  0.5,
                                                                )
                                                          : theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.color,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      decoration: isPastDue
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                    ),
                                              ),
                                            ),
                                          Text(
                                            (medication['time'] as TimeOfDay)
                                                .format(context),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: isPastDue
                                                      ? theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color
                                                            ?.withOpacity(0.5)
                                                      : theme
                                                            .colorScheme
                                                            .primary,
                                                  fontWeight: FontWeight.w500,
                                                  decoration: isPastDue
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isPastDue)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          shape: SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: 8,
                                              cornerSmoothing: 0.6,
                                            ),
                                            side: BorderSide(
                                              color: Colors.orange.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Past',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          shape: SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: 8,
                                              cornerSmoothing: 0.6,
                                            ),
                                            side: BorderSide(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Incoming',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      } else {
                        // No medication reminders set up
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: ShapeDecoration(
                            color: theme.scaffoldBackgroundColor,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 16,
                                cornerSmoothing: 0.6,
                              ),
                              side: BorderSide(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF3A3A3A)
                                    : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: ShapeDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFF3A3A3A)
                                      : Colors.white,
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 16,
                                      cornerSmoothing: 0.6,
                                    ),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.pills,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.5),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No Medication Reminders',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Set up medication reminders in settings',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 30),

                  // Check if we have any actual glucose data (not just empty structure)
                  Consumer2<GlucoseDataProvider, GlucoseTrendDataProvider>(
                    builder: (context, glucoseProvider, trendProvider, child) {
                      final hasLatestGlucose = glucoseProvider.hasData;
                      final hasWeeklyData = trendProvider.weeklyAverage != null;
                      final hasDailyData = trendProvider.hasChartData;

                      if (!hasLatestGlucose &&
                          !hasWeeklyData &&
                          !hasDailyData &&
                          !_isLoading) {
                        // Complete empty state for glucose data
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: ShapeDecoration(
                            color: theme.scaffoldBackgroundColor,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 16,
                                cornerSmoothing: 0.6,
                              ),
                              side: BorderSide(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF3A3A3A)
                                    : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bloodtype,
                                size: 64,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Glucose Data',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.headlineSmall?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start tracking your glucose levels to see trends and insights here.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: ShapeDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 12,
                                      cornerSmoothing: 0.6,
                                    ),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      widget.onLogButtonPressed?.call();
                                    },
                                    customBorder: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                        cornerRadius: 12,
                                        cornerSmoothing: 0.6,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.add,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Log First Reading',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Show glucose trend section
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 7-Day Glucose Trend (only show when we have data)
                            Text(
                              '7-Day Glucose Trend',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Average display and percentage change
                            Skeletonizer(
                              enabled:
                                  trendProvider.isLoading &&
                                  !trendProvider.hasData,
                              child: Text(
                                trendProvider.isLoading &&
                                        !trendProvider.hasData
                                    ? '000 mg/dL' // Skeleton placeholder
                                    : trendProvider.getWeeklyAverageString(),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Skeletonizer(
                              enabled:
                                  trendProvider.isLoading &&
                                  !trendProvider.hasData,
                              child: Row(
                                children: [
                                  if ((trendProvider.isLoading &&
                                          !trendProvider.hasData) ||
                                      (trendProvider.weeklyAverage != null &&
                                          trendProvider.percentageChange !=
                                              null)) ...[
                                    Text(
                                      'Avg',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      (trendProvider.isLoading &&
                                              !trendProvider.hasData)
                                          ? '+0.0%' // Skeleton placeholder
                                          : trendProvider.percentageChange!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            (trendProvider.isLoading &&
                                                !trendProvider.hasData)
                                            ? theme.colorScheme.primary
                                            : trendProvider
                                                  .getPercentageChangeColor(
                                                    context,
                                                  ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Graph Container
                            Container(
                              height: 180,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Skeletonizer(
                                enabled:
                                    trendProvider.isLoading &&
                                    !trendProvider.hasData,
                                child:
                                    (trendProvider.isLoading &&
                                        !trendProvider.hasData)
                                    ? _buildSkeletonChart(theme)
                                    : !trendProvider.hasChartData
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.bar_chart,
                                              size: 48,
                                              color: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withOpacity(0.5),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No glucose data available',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Log some glucose readings to see trends',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : _buildGlucoseChart(
                                        context,
                                        trendProvider,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Day labels (only show when we have data)
                            Skeletonizer(
                              enabled:
                                  trendProvider.isLoading &&
                                  !trendProvider.hasData,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children:
                                    (trendProvider.isLoading &&
                                        !trendProvider.hasData)
                                    ? [
                                            'Mon',
                                            'Tue',
                                            'Wed',
                                            'Thu',
                                            'Fri',
                                            'Sat',
                                            'Sun',
                                          ]
                                          .map(
                                            (day) =>
                                                _buildDayLabel(context, day),
                                          )
                                          .toList()
                                    : _getChartDayLabelsFromProvider(
                                            trendProvider,
                                          )
                                          .map(
                                            (day) =>
                                                _buildDayLabel(context, day),
                                          )
                                          .toList(),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(
                    height: 100,
                  ), // Extra space at bottom for safety
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayLabel(BuildContext context, String day) {
    final theme = Theme.of(context);
    return Text(
      day,
      style: TextStyle(color: theme.colorScheme.primary, fontSize: 14),
    );
  }

  Widget _buildSkeletonChart(ThemeData theme) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 4,
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 2.0),
              FlSpot(1, 2.2),
              FlSpot(2, 1.8),
              FlSpot(3, 2.4),
              FlSpot(4, 2.1),
              FlSpot(5, 2.3),
              FlSpot(6, 2.0),
            ],
            isCurved: true,
            color: theme.colorScheme.primary.withOpacity(0.3),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.05),
            ),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  Widget _buildGlucoseChart(
    BuildContext context,
    GlucoseTrendDataProvider trendProvider,
  ) {
    final theme = Theme.of(context);
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 4,
        lineBarsData: [
          LineChartBarData(
            spots: _buildChartSpots(trendProvider.dailyAverages),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => theme.colorScheme.primary,
            tooltipRoundedRadius: 16,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            tooltipMargin: 8,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final dayLabels = _getChartDayLabelsFromProvider(trendProvider);
                final tooltipValues = _getChartTooltipValues(
                  trendProvider.dailyAverages,
                );
                final index = touchedSpot.spotIndex;

                // Bounds checking
                if (index >= 0 &&
                    index < dayLabels.length &&
                    index < tooltipValues.length) {
                  final dayLabel = dayLabels[index];
                  final value = tooltipValues[index];
                  final displayText = value > 0 ? '$value mg/dL' : 'No data';

                  return LineTooltipItem(
                    '$dayLabel\n$displayText',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                } else {
                  return LineTooltipItem(
                    'No data',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  List<FlSpot> _buildChartSpots(List<Map<String, dynamic>> dailyAverages) {
    if (dailyAverages.isEmpty) {
      // Return default spots if no data
      return [
        FlSpot(0, 2.0),
        FlSpot(1, 2.0),
        FlSpot(2, 2.0),
        FlSpot(3, 2.0),
        FlSpot(4, 2.0),
        FlSpot(5, 2.0),
        FlSpot(6, 2.0),
      ];
    }

    return dailyAverages.asMap().entries.map((entry) {
      final index = entry.key;
      final dayData = entry.value;
      final average = dayData['average'] as double?;

      // Convert glucose values to chart scale (roughly 0-4 range)
      // Assuming normal glucose range is 70-180 mg/dL
      double yValue = 2.0; // Default middle value
      if (average != null) {
        // Scale glucose values to fit chart (70-180 mg/dL -> 0.5-3.5 range)
        yValue = ((average - 70) / 110) * 3.0 + 0.5;
        yValue = yValue.clamp(0.2, 3.8); // Keep within chart bounds
      }

      return FlSpot(index.toDouble(), yValue);
    }).toList();
  }

  List<String> _getChartDayLabelsFromProvider(
    GlucoseTrendDataProvider trendProvider,
  ) {
    if (trendProvider.dailyAverages.isEmpty) {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
    return trendProvider.dailyAverages
        .map((day) => day['dayName'] as String)
        .toList();
  }

  List<int> _getChartTooltipValues(List<Map<String, dynamic>> dailyAverages) {
    if (dailyAverages.isEmpty) {
      return [0, 0, 0, 0, 0, 0, 0];
    }
    return dailyAverages.map((day) {
      final average = day['average'] as double?;
      return average?.round() ?? 0;
    }).toList();
  }
}
