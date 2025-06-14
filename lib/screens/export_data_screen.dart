import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:toastification/toastification.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;
import '../theme/app_colors.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  String _selectedFormat = 'CSV';
  bool _isExporting = false;

  final List<String> _exportFormats = ['CSV', 'PDF'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    decoration: ShapeDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF0F1F7),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 12,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Text(
                      'Export Data',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.headlineMedium?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 56,
                  ), // Same width as back button to center title
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range Section
                    Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Range Picker
                    _buildDateRangePicker(theme),

                    const SizedBox(height: 30),

                    // Export Format Section
                    Text(
                      'Export Format',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Format Selection
                    Container(
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
                        children: _exportFormats.map((format) {
                          return _buildFormatOption(
                            format: format,
                            isSelected: format == _selectedFormat,
                            onTap: () =>
                                setState(() => _selectedFormat = format),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Export Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isExporting ? null : _exportData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 16,
                              cornerSmoothing: 0.6,
                            ),
                          ),
                        ),
                        child: _isExporting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Export Data',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(ThemeData theme) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectDateRange,
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
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
                      FontAwesomeIcons.calendarDays,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMM d, yyyy').format(_selectedDateRange.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange.end)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) =>
          _DateRangePickerDialog(initialDateRange: _selectedDateRange),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Widget _buildFormatOption({
    required String format,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF3A3A3A)
                    : Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: ShapeDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
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
                    format == 'CSV'
                        ? FontAwesomeIcons.table
                        : FontAwesomeIcons.file,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      format,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      format == 'CSV'
                          ? 'Comma-separated values file'
                          : 'Portable Document Format',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Fix date range to include entire end day
      final startDate = _selectedDateRange.start;
      final endDate = DateTime(
        _selectedDateRange.end.year,
        _selectedDateRange.end.month,
        _selectedDateRange.end.day,
        23,
        59,
        59,
        999,
      );

      // Fetch glucose readings within the date range
      final glucoseReadings = await FirestoreService.getEvents(
        startDate: startDate,
        endDate: endDate,
        type: 'glucose',
        limit: 1000, // Increase limit for export
      );

      if (glucoseReadings.isEmpty) {
        if (mounted) {
          final theme = Theme.of(context);
          toastification.show(
            context: context,
            type: ToastificationType.warning,
            style: ToastificationStyle.flat,
            title: Text(
              'No Data Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            description: Text(
              'No glucose readings found in the selected date range',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.black54,
              ),
            ),
            alignment: Alignment.topCenter,
            autoCloseDuration: const Duration(seconds: 4),
            showProgressBar: false,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 0.6,
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: Colors.orange[600],
            borderSide: BorderSide(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            icon: Icon(Icons.search_off, color: Colors.orange[600], size: 24),
          );
        }
        return;
      }

      // Generate export based on selected format
      if (_selectedFormat == 'CSV') {
        await _generateAndShareCSV(glucoseReadings);
      } else {
        // PDF functionality
        await _generateAndSharePDF(glucoseReadings);
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: Text(
            'Export Failed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          description: Text(
            'Error exporting data: $e',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.black54,
            ),
          ),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          showProgressBar: false,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
          borderRadius: SmoothBorderRadius(
            cornerRadius: 12,
            cornerSmoothing: 0.6,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: Colors.red[600],
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          icon: Icon(Icons.error_outline, color: Colors.red[600], size: 24),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _generateAndShareCSV(List<Map<String, dynamic>> readings) async {
    try {
      // Get patient information
      final userData = await FirestoreService.getUserData();

      // Create CSV data with patient info header
      List<List<dynamic>> csvData = [];

      // Patient Information Header
      csvData.add(['Patient Information']);
      csvData.add([
        'Name',
        '${userData?['firstName'] ?? 'N/A'} ${userData?['lastName'] ?? 'N/A'}',
      ]);
      csvData.add(['Diabetes Type', userData?['diabetesType'] ?? 'N/A']);
      csvData.add([
        'Export Date',
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      ]);
      csvData.add([
        'Date Range',
        '${DateFormat('yyyy-MM-dd').format(_selectedDateRange.start)} to ${DateFormat('yyyy-MM-dd').format(_selectedDateRange.end)}',
      ]);
      csvData.add(['Total Readings', readings.length.toString()]);

      // Add empty row for separation
      csvData.add([]);

      // Glucose Readings Header
      csvData.add(['Glucose Readings']);
      csvData.add(['Date', 'Time', 'Glucose (mg/dL)', 'Notes']);

      // Add data rows
      for (final reading in readings) {
        final date = reading['date'] as DateTime?;
        final measure = reading['measure'] as num?;
        final notes = reading['notes'] as String? ?? '';

        if (date != null && measure != null) {
          csvData.add([
            DateFormat('yyyy-MM-dd').format(date),
            DateFormat('HH:mm:ss').format(date),
            measure.toInt(),
            notes,
          ]);
        }
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Create filename with date range
      final dateRange =
          '${DateFormat('yyyy-MM-dd').format(_selectedDateRange.start)}_to_${DateFormat('yyyy-MM-dd').format(_selectedDateRange.end)}';
      final patientName =
          '${userData?['firstName'] ?? 'Patient'}_${userData?['lastName'] ?? 'Export'}';
      final fileName = '${patientName}_glucose_readings_$dateRange.csv';

      // Convert CSV string to bytes
      final bytes = utf8.encode(csvString);

      // Share the CSV content directly
      final result = await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(bytes),
            name: fileName,
            mimeType: 'text/csv',
          ),
        ],
        text:
            'Glucose readings for ${userData?['firstName'] ?? 'Patient'} ${userData?['lastName'] ?? ''} from ${DateFormat('MMM d, yyyy').format(_selectedDateRange.start)} to ${DateFormat('MMM d, yyyy').format(_selectedDateRange.end)}',
        subject:
            'Glucose Readings Export - ${userData?['firstName'] ?? 'Patient'} ${userData?['lastName'] ?? ''}',
      );

      // Only show success toast if the user didn't dismiss/cancel the share dialog
      if (mounted && result.status == ShareResultStatus.success) {
        final theme = Theme.of(context);
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: Text(
            'Export Successful',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          description: Text(
            'CSV file exported successfully! (${readings.length} readings)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.black54,
            ),
          ),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 4),
          showProgressBar: false,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
          borderRadius: SmoothBorderRadius(
            cornerRadius: 12,
            cornerSmoothing: 0.6,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.colorScheme.primary,
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          icon: Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: Text(
            'Export Failed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          description: Text(
            'Error generating CSV: $e',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.black54,
            ),
          ),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          showProgressBar: false,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
          borderRadius: SmoothBorderRadius(
            cornerRadius: 12,
            cornerSmoothing: 0.6,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: Colors.red[600],
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          icon: Icon(Icons.error_outline, color: Colors.red[600], size: 24),
        );
      }
    }
  }

  Future<void> _generateAndSharePDF(List<Map<String, dynamic>> readings) async {
    try {
      // Get patient information
      final userData = await FirestoreService.getUserData();

      // Create PDF document
      final pdf = pw.Document();

      // Load fonts for better Unicode support
      final fontRegular = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();

      // Generate chart image if we have readings
      pw.ImageProvider? chartImage;
      if (readings.isNotEmpty) {
        chartImage = await _generateChartImage(readings);
      }

      // Add page with content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header with app-style design
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#617AFA'), // App primary blue
                  borderRadius: pw.BorderRadius.circular(16),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Glucose Readings Report',
                      style: pw.TextStyle(
                        fontSize: 28,
                        font: fontBold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated on ${DateFormat('MMMM d, yyyy \'at\' h:mm a').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        font: fontRegular,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Patient Information Section with app-style card
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(16),
                  border: pw.Border.all(
                    color: PdfColor.fromHex('#DFE1E5'), // App border color
                    width: 1,
                  ),
                  boxShadow: [
                    pw.BoxShadow(
                      color: PdfColor.fromHex(
                        '#00000008',
                      ), // Black with 5% opacity
                      blurRadius: 8,
                      offset: const PdfPoint(0, 2),
                    ),
                  ],
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Patient Information',
                      style: pw.TextStyle(
                        fontSize: 18,
                        font: fontBold,
                        color: PdfColor.fromHex('#303030'), // App text color
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildInfoRow(
                            'Name',
                            '${userData?['firstName'] ?? 'N/A'} ${userData?['lastName'] ?? 'N/A'}',
                            fontRegular,
                            fontBold,
                          ),
                        ),
                        pw.Expanded(
                          child: _buildInfoRow(
                            'Diabetes Type',
                            userData?['diabetesType'] ?? 'N/A',
                            fontRegular,
                            fontBold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildInfoRow(
                            'Date Range',
                            '${DateFormat('MMM d, yyyy').format(_selectedDateRange.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange.end)}',
                            fontRegular,
                            fontBold,
                          ),
                        ),
                        pw.Expanded(
                          child: _buildInfoRow(
                            'Total Readings',
                            '${readings.length}',
                            fontRegular,
                            fontBold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Summary Statistics with app-style card
              if (readings.isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors
                        .white, // White background for better readability
                    borderRadius: pw.BorderRadius.circular(16),
                    border: pw.Border.all(
                      color: PdfColor.fromHex(
                        '#617AFA',
                      ), // App primary blue border
                      width: 1,
                    ),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromHex(
                          '#00000008',
                        ), // Black with 5% opacity
                        blurRadius: 8,
                        offset: const PdfPoint(0, 2),
                      ),
                    ],
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Summary Statistics',
                        style: pw.TextStyle(
                          fontSize: 18,
                          font: fontBold,
                          color: PdfColor.fromHex(
                            '#617AFA',
                          ), // App primary blue
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: _buildStatRow(
                              'Average',
                              '${_calculateAverage(readings).toStringAsFixed(0)} mg/dL',
                              fontRegular,
                              fontBold,
                            ),
                          ),
                          pw.Expanded(
                            child: _buildStatRow(
                              'Minimum',
                              '${_findMinimum(readings)} mg/dL',
                              fontRegular,
                              fontBold,
                            ),
                          ),
                          pw.Expanded(
                            child: _buildStatRow(
                              'Maximum',
                              '${_findMaximum(readings)} mg/dL',
                              fontRegular,
                              fontBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Glucose Trend Chart with app-style card
              if (chartImage != null) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(16),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#DFE1E5'), // App border color
                      width: 1,
                    ),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromHex(
                          '#00000008',
                        ), // Black with 5% opacity
                        blurRadius: 8,
                        offset: const PdfPoint(0, 2),
                      ),
                    ],
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Glucose Trend Chart',
                        style: pw.TextStyle(
                          fontSize: 18,
                          font: fontBold,
                          color: PdfColor.fromHex('#303030'), // App text color
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      pw.Container(
                        height: 300,
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Image(chartImage, fit: pw.BoxFit.contain),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Readings Table
              pw.Text(
                'Glucose Readings',
                style: pw.TextStyle(fontSize: 16, font: fontBold),
              ),
              pw.SizedBox(height: 12),

              if (readings.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'No glucose readings found in the selected date range',
                      style: pw.TextStyle(
                        fontSize: 14,
                        font: fontRegular,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1.5),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        _buildTableCell(
                          'Date',
                          fontRegular,
                          fontBold,
                          isHeader: true,
                        ),
                        _buildTableCell(
                          'Time',
                          fontRegular,
                          fontBold,
                          isHeader: true,
                        ),
                        _buildTableCell(
                          'Glucose (mg/dL)',
                          fontRegular,
                          fontBold,
                          isHeader: true,
                        ),
                        _buildTableCell(
                          'Notes',
                          fontRegular,
                          fontBold,
                          isHeader: true,
                        ),
                      ],
                    ),
                    // Data rows
                    ...readings.map((reading) {
                      final date = reading['date'] as DateTime?;
                      final measure = reading['measure'] as num?;
                      final notes = reading['notes'] as String? ?? '';

                      return pw.TableRow(
                        children: [
                          _buildTableCell(
                            date != null
                                ? DateFormat('MMM d, yyyy').format(date)
                                : 'N/A',
                            fontRegular,
                            fontBold,
                          ),
                          _buildTableCell(
                            date != null
                                ? DateFormat('h:mm a').format(date)
                                : 'N/A',
                            fontRegular,
                            fontBold,
                          ),
                          _buildTableCell(
                            measure?.toInt().toString() ?? 'N/A',
                            fontRegular,
                            fontBold,
                          ),
                          _buildTableCell(
                            notes.isEmpty ? '-' : notes,
                            fontRegular,
                            fontBold,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
            ];
          },
        ),
      );

      // Generate PDF bytes
      final pdfBytes = await pdf.save();

      // Create filename
      final dateRange =
          '${DateFormat('yyyy-MM-dd').format(_selectedDateRange.start)}_to_${DateFormat('yyyy-MM-dd').format(_selectedDateRange.end)}';
      final patientName =
          '${userData?['firstName'] ?? 'Patient'}_${userData?['lastName'] ?? 'Export'}';
      final fileName = '${patientName}_glucose_readings_$dateRange.pdf';

      // Show preview with forced settings
      final bool wasSuccessful = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: fileName,
        format: PdfPageFormat.a4,
        usePrinterSettings: false,
        dynamicLayout: false,
      );

      // Only show success toast if the user actually printed (not cancelled)
      if (mounted && wasSuccessful) {
        final theme = Theme.of(context);
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: Text(
            'PDF Printed Successfully',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          description: Text(
            'PDF report printed with ${readings.length} readings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.black54,
            ),
          ),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 4),
          showProgressBar: false,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
          borderRadius: SmoothBorderRadius(
            cornerRadius: 12,
            cornerSmoothing: 0.6,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.colorScheme.primary,
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          icon: Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: Text(
            'PDF Generation Failed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          description: Text(
            'Error generating PDF: $e',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[300]
                  : Colors.black54,
            ),
          ),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
          showProgressBar: false,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
          borderRadius: SmoothBorderRadius(
            cornerRadius: 12,
            cornerSmoothing: 0.6,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: Colors.red[600],
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          icon: Icon(Icons.error_outline, color: Colors.red[600], size: 24),
        );
      }
    }
  }

  // Helper methods for PDF generation
  pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            font: fontBold,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, font: fontRegular)),
      ],
    );
  }

  pw.Widget _buildStatRow(
    String label,
    String value,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            font: fontBold,
            color: PdfColor.fromHex('#617AFA'), // App primary blue
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            font: fontBold,
            color: PdfColor.fromHex(
              '#303030',
            ), // App text color for readability
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text,
    pw.Font fontRegular,
    pw.Font fontBold, {
    bool isHeader = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          font: isHeader ? fontBold : fontRegular,
        ),
      ),
    );
  }

  // Statistics calculation methods
  double _calculateAverage(List<Map<String, dynamic>> readings) {
    if (readings.isEmpty) return 0;
    final total = readings.fold<double>(0, (sum, reading) {
      final measure = reading['measure'] as num?;
      return sum + (measure?.toDouble() ?? 0);
    });
    return total / readings.length;
  }

  int _findMinimum(List<Map<String, dynamic>> readings) {
    if (readings.isEmpty) return 0;
    return readings.fold<int>(999, (min, reading) {
      final measure = reading['measure'] as num?;
      final value = measure?.toInt() ?? 999;
      return value < min ? value : min;
    });
  }

  int _findMaximum(List<Map<String, dynamic>> readings) {
    if (readings.isEmpty) return 0;
    return readings.fold<int>(0, (max, reading) {
      final measure = reading['measure'] as num?;
      final value = measure?.toInt() ?? 0;
      return value > max ? value : max;
    });
  }

  Future<pw.ImageProvider> _generateChartImage(
    List<Map<String, dynamic>> readings,
  ) async {
    // Sort readings by date
    final sortedReadings = List<Map<String, dynamic>>.from(readings);
    sortedReadings.sort((a, b) {
      final dateA = a['date'] as DateTime?;
      final dateB = b['date'] as DateTime?;
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });

    // Create chart using Canvas drawing
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const double width = 800;
    const double height = 400;
    const double padding = 60;
    const double chartWidth = width - (padding * 2);
    const double chartHeight = height - (padding * 2);

    // Draw background with app-style
    final backgroundPaint = Paint()
      ..color = const Color(0xFFFAFAFA); // Light background
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    if (sortedReadings.isNotEmpty) {
      final maxValue = _findMaximum(readings).toDouble();
      final minValue = _findMinimum(readings).toDouble();
      final valueRange = maxValue - minValue;

      // Ensure we have a reasonable range
      final adjustedMaxValue = valueRange < 50 ? maxValue + 25 : maxValue;
      final adjustedMinValue = valueRange < 50 ? minValue - 25 : minValue;
      final adjustedRange = adjustedMaxValue - adjustedMinValue;

      // Draw grid lines with app colors
      final gridPaint = Paint()
        ..color =
            const Color(0xFFDFE1E5) // App border color
        ..strokeWidth = 1;

      // Horizontal grid lines (glucose levels)
      for (int i = 0; i <= 5; i++) {
        final y = padding + (i * chartHeight / 5);
        canvas.drawLine(
          Offset(padding, y),
          Offset(width - padding, y),
          gridPaint,
        );

        // Draw glucose level labels with app colors
        final value = adjustedMaxValue - (i * adjustedRange / 5);
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${value.toInt()}',
            style: const TextStyle(
              color: Color(0xFF303030), // App text color
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(padding - 40, y - 6));
      }

      // Vertical grid lines (dates)
      final dateStep = sortedReadings.length > 7
          ? sortedReadings.length ~/ 7
          : 1;
      for (int i = 0; i < sortedReadings.length; i += dateStep) {
        final x = padding + (i * chartWidth / (sortedReadings.length - 1));
        canvas.drawLine(
          Offset(x, padding),
          Offset(x, height - padding),
          gridPaint,
        );

        // Draw date labels
        final reading = sortedReadings[i];
        final date = reading['date'] as DateTime?;
        if (date != null) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: DateFormat('MM/dd').format(date),
              style: const TextStyle(
                color: Color(0xFF6E6E6E), // App secondary text color
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            textDirection: ui.TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(x - 15, height - padding + 10));
        }
      }

      // Draw chart border with app colors
      final borderPaint = Paint()
        ..color =
            const Color(0xFFDFE1E5) // App border color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawRect(
        Rect.fromLTWH(padding, padding, chartWidth, chartHeight),
        borderPaint,
      );

      // Draw chart line and points with app colors
      final linePaint = Paint()
        ..color =
            const Color(0xFF617AFA) // App primary blue
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final pointPaint = Paint()
        ..color =
            const Color(0xFF617AFA) // App primary blue
        ..style = PaintingStyle.fill;

      final pointBorderPaint = Paint()
        ..color =
            const Color(0xFFFAFAFA) // Light background
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      final points = <Offset>[];

      for (int i = 0; i < sortedReadings.length; i++) {
        final reading = sortedReadings[i];
        final measure = reading['measure'] as num?;
        final value = measure?.toDouble() ?? adjustedMinValue;

        final x = padding + (i * chartWidth / (sortedReadings.length - 1));
        final y =
            padding +
            chartHeight -
            ((value - adjustedMinValue) / adjustedRange * chartHeight);

        points.add(Offset(x, y));

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Draw the line
      canvas.drawPath(path, linePaint);

      // Draw points
      for (final point in points) {
        canvas.drawCircle(point, 6, pointPaint);
        canvas.drawCircle(point, 6, pointBorderPaint);
      }

      // Draw area under the curve with app colors
      final areaPaint = Paint()
        ..color = const Color(0xFF617AFA)
            .withOpacity(0.1) // App primary blue with opacity
        ..style = PaintingStyle.fill;

      final areaPath = Path.from(path);
      if (points.isNotEmpty) {
        areaPath.lineTo(points.last.dx, height - padding);
        areaPath.lineTo(points.first.dx, height - padding);
        areaPath.close();
      }
      canvas.drawPath(areaPath, areaPaint);
    }

    // Add title with app styling
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'Glucose Levels Over Time',
        style: TextStyle(
          color: Color(0xFF303030), // App text color
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset((width - titlePainter.width) / 2, 20));

    // Add axis labels with app styling
    final yAxisPainter = TextPainter(
      text: const TextSpan(
        text: 'Glucose (mg/dL)',
        style: TextStyle(
          color: Color(0xFF6E6E6E), // App secondary text color
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    yAxisPainter.layout();
    canvas.save();
    canvas.translate(15, height / 2 + yAxisPainter.width / 2);
    canvas.rotate(-1.5708); // -90 degrees
    yAxisPainter.paint(canvas, Offset.zero);
    canvas.restore();

    final xAxisPainter = TextPainter(
      text: const TextSpan(
        text: 'Date',
        style: TextStyle(
          color: Color(0xFF6E6E6E), // App secondary text color
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    xAxisPainter.layout();
    xAxisPainter.paint(
      canvas,
      Offset((width - xAxisPainter.width) / 2, height - 20),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    return pw.MemoryImage(pngBytes);
  }
}

class _DateRangePickerDialog extends StatefulWidget {
  final DateTimeRange initialDateRange;

  const _DateRangePickerDialog({required this.initialDateRange});

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  late PickerDateRange _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = PickerDateRange(
      widget.initialDateRange.start,
      widget.initialDateRange.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: ShapeDecoration(
          color: theme.scaffoldBackgroundColor,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.6,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                      ),
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF0F1F7),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.close,
                            color: theme.iconTheme.color,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Date Range Picker
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 16,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                ),
                child: SfDateRangePicker(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: _selectedRange,
                  minDate: DateTime(2020),
                  maxDate: DateTime.now(),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                        if (args.value is PickerDateRange) {
                          setState(() {
                            _selectedRange = args.value;
                          });
                        }
                      },
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1, // Monday
                    dayFormat: 'EEE',
                    viewHeaderStyle: DateRangePickerViewHeaderStyle(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  yearCellStyle: DateRangePickerYearCellStyle(
                    textStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    todayTextStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    todayTextStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    disabledDatesTextStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.3,
                      ),
                      fontSize: 16,
                    ),
                    weekendTextStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selectionTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  rangeTextStyle: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  selectionColor: theme.colorScheme.primary,
                  startRangeSelectionColor: theme.colorScheme.primary,
                  endRangeSelectionColor: theme.colorScheme.primary,
                  rangeSelectionColor: theme.colorScheme.primary.withOpacity(
                    0.15,
                  ),
                  todayHighlightColor: theme.colorScheme.primary.withOpacity(
                    0.3,
                  ),
                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineSmall?.color,
                    ),
                  ),
                  navigationDirection:
                      DateRangePickerNavigationDirection.horizontal,
                  allowViewNavigation: true,
                  enablePastDates: true,
                  showNavigationArrow: true,
                  navigationMode: DateRangePickerNavigationMode.snap,
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedRange.startDate != null &&
                        _selectedRange.endDate != null) {
                      Navigator.pop(
                        context,
                        DateTimeRange(
                          start: _selectedRange.startDate!,
                          end: _selectedRange.endDate!,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 16,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
