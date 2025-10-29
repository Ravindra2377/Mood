import 'package:flutter/material.dart';

/// Metadata describing an exercise for the info dialog.
class ExerciseInfo {
  final String id;
  final String name;
  final String category;
  final Duration estimatedDuration;
  final IconData icon;
  final Color color;
  final String howItWorks;
  final List<String> benefits;
  final String whenToUse;
  final List<String> steps;
  final String? warningNote;

  const ExerciseInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.estimatedDuration,
    required this.icon,
    required this.color,
    required this.howItWorks,
    required this.benefits,
    required this.whenToUse,
    required this.steps,
    this.warningNote,
  });
}
