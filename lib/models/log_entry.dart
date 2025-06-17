import 'package:flutter/material.dart';

// Data model for log entries
class LogEntry {
  final String title;
  final String value;
  final String time;
  final IconData icon;
  final String id;
  final DateTime date;
  final String? note;

  LogEntry(
    this.title,
    this.value,
    this.time,
    this.icon,
    this.id,
    this.date, {
    this.note,
  });
}
