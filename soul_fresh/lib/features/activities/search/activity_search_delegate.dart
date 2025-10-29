import 'package:flutter/material.dart';

import '../models/activity_view_model.dart';

class ActivitySearchDelegate extends SearchDelegate<WellnessActivity?> {
  ActivitySearchDelegate({
    required this.activities,
    required this.trendingTags,
  });

  final List<WellnessActivity> activities;
  final List<String> trendingTags;

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear search',
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildTrendingSuggestions();
    }
    return _buildSearchResults();
  }

  Widget _buildTrendingSuggestions() {
    if (trendingTags.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Popular tags',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (BuildContext context) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trendingTags.map((String tag) {
                  return FilterChip(
                    label: Text(tag),
                    onSelected: (_) {
                      query = tag;
                      showResults(context);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final String lowerQuery = query.toLowerCase().trim();
    final List<WellnessActivity> results = activities.where((WellnessActivity activity) {
      final bool matchesName = activity.name.toLowerCase().contains(lowerQuery);
      final bool matchesCategory = activity.category.toLowerCase().contains(lowerQuery);
      final bool matchesTag = activity.tags.any(
        (String tag) => tag.toLowerCase().contains(lowerQuery),
      );
      return lowerQuery.isEmpty || matchesName || matchesCategory || matchesTag;
    }).toList()
      ..sort((WellnessActivity a, WellnessActivity b) => b.rating.compareTo(a.rating));

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'No activities match "$query" yet.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try searching by mood, activity name, or tags like sleep, anxiety, or quick.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final WellnessActivity activity = results[index];
        return ListTile(
          leading: Text(activity.iconEmoji, style: const TextStyle(fontSize: 28)),
          title: Text(activity.name),
          subtitle: Text('${activity.durationMinutes} min • ${activity.category}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => close(context, activity),
        );
      },
    );
  }
}
