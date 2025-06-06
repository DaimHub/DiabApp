import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
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
      print('Error loading overview data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimeSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Handle negative differences (future dates)
    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return 'Last updated ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Last updated ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Last updated ${difference.inDays}d ago';
    } else {
      return 'Last updated ${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Blood Glucose Card
                  Consumer<GlucoseDataProvider>(
                    builder: (context, glucoseProvider, child) {
                      return Container(
                        margin: const EdgeInsets.only(top: 20),
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
                                  FontAwesomeIcons.droplet,
                                  color: theme.colorScheme.primary,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Blood Glucose',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                glucoseProvider.isLoading &&
                                        !glucoseProvider.hasData
                                    ? Container(
                                        width: 80,
                                        height: 20,
                                        margin: const EdgeInsets.only(top: 4),
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
                                      )
                                    : Text(
                                        glucoseProvider.getGlucoseValueString(),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                              ],
                            ),
                            const Spacer(),
                            glucoseProvider.isLoading &&
                                    !glucoseProvider.hasData
                                ? Container(
                                    width: 120,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: theme.brightness == Brightness.dark
                                          ? const Color(0xFF3A3A3A)
                                          : const Color(0xFFF0F1F7),
                                      borderRadius: BorderRadius.circular(4),
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isPastDue
                                      ? (theme.brightness == Brightness.dark
                                            ? const Color(
                                                0xFF2A2A2A,
                                              ).withOpacity(0.5)
                                            : const Color(
                                                0xFFF0F1F7,
                                              ).withOpacity(0.7))
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isPastDue
                                      ? Border.all(
                                          color:
                                              theme.brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF3A3A3A)
                                              : Colors.grey[300]!,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: isPastDue
                                            ? (theme.brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF3A3A3A)
                                                  : Colors.grey[200])
                                            : (theme.brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF2A2A2A)
                                                  : const Color(0xFFF0F1F7)),
                                        borderRadius: BorderRadius.circular(10),
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
                                          const SizedBox(height: 2),
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
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.orange.withOpacity(
                                              0.3,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'PAST',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.schedule,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      } else {
                        // No medication reminders set up
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF0F1F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF3A3A3A)
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
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
                                    Text(
                                      'Set up reminders in Settings',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withOpacity(0.7),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.5),
                                size: 16,
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
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF0F1F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF3A3A3A)
                                  : Colors.grey[200]!,
                            ),
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
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Trigger the log bottom sheet via callback
                                  widget.onLogButtonPressed?.call();
                                },
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Log First Reading'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
    return Text(
      day,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 14,
      ),
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
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                Theme.of(context).colorScheme.primary,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
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
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                } else {
                  return LineTooltipItem(
                    'No data',
                    const TextStyle(
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
