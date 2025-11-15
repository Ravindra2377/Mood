import 'package:flutter/material.dart';
import '../models/app_models.dart';

class TimeFilterPills extends StatelessWidget {
  final TimeFilter selectedFilter;
  final Function(TimeFilter) onFilterSelected;

  const TimeFilterPills({
    required this.selectedFilter,
    required this.onFilterSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterPill(
          label: 'Today',
          isSelected: selectedFilter == TimeFilter.today,
          onTap: () => onFilterSelected(TimeFilter.today),
        ),
        const SizedBox(width: 8),
        _FilterPill(
          label: 'Next week',
          isSelected: selectedFilter == TimeFilter.nextWeek,
          onTap: () => onFilterSelected(TimeFilter.nextWeek),
        ),
        const SizedBox(width: 8),
        _FilterPill(
          label: 'Next month',
          isSelected: selectedFilter == TimeFilter.nextMonth,
          onTap: () => onFilterSelected(TimeFilter.nextMonth),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
