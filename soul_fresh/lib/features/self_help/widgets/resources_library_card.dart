import 'package:flutter/material.dart';

class ResourcesLibraryCard extends StatefulWidget {
  const ResourcesLibraryCard({Key? key}) : super(key: key);

  @override
  State<ResourcesLibraryCard> createState() => _ResourcesLibraryCardState();
}

class _ResourcesLibraryCardState extends State<ResourcesLibraryCard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> resources = [
    {
      'title': 'Understanding Anxiety: A Complete Guide',
      'type': 'Article',
      'author': 'Dr. Sarah Johnson',
      'duration': '8 min read',
      'category': 'Anxiety',
      'icon': Icons.article,
      'color': Colors.blue,
    },
    {
      'title': 'Progressive Muscle Relaxation Technique',
      'type': 'Video',
      'author': 'Mindfulness Center',
      'duration': '12 min',
      'category': 'Relaxation',
      'icon': Icons.play_circle,
      'color': Colors.green,
    },
    {
      'title': 'Cognitive Behavioral Therapy Worksheet',
      'type': 'Worksheet',
      'author': 'Psychology Today',
      'duration': 'Interactive',
      'category': 'CBT',
      'icon': Icons.edit_document,
      'color': Colors.purple,
    },
    {
      'title': 'Sleep Hygiene: Building Better Habits',
      'type': 'Article',
      'author': 'Sleep Foundation',
      'duration': '6 min read',
      'category': 'Sleep',
      'icon': Icons.article,
      'color': Colors.indigo,
    },
    {
      'title': 'Mindfulness Meditation for Beginners',
      'type': 'Video',
      'author': 'Zen Center',
      'duration': '15 min',
      'category': 'Mindfulness',
      'icon': Icons.play_circle,
      'color': Colors.orange,
    },
    {
      'title': 'Depression Symptom Tracker',
      'type': 'Worksheet',
      'author': 'Mental Health Institute',
      'duration': 'Interactive',
      'category': 'Depression',
      'icon': Icons.edit_document,
      'color': Colors.red,
    },
  ];

  List<Map<String, dynamic>> get filteredResources {
    if (_searchQuery.isEmpty) {
      return resources;
    }
    return resources.where((resource) {
      final title = resource['title'].toString().toLowerCase();
      final author = resource['author'].toString().toLowerCase();
      final category = resource['category'].toString().toLowerCase();
      final type = resource['type'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return title.contains(query) ||
             author.contains(query) ||
             category.contains(query) ||
             type.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              hintText: 'Search resources, videos, podcasts',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        // Resource List
        ...filteredResources.map((resource) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (resource['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    resource['icon'] as IconData,
                    color: resource['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            resource['author'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (resource['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              resource['type'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: resource['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            resource['duration'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${resource['category']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          );
        }),

        // Category Chips
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: const Text('Anxiety'),
              onPressed: () => setState(() => _searchQuery = 'anxiety'),
            ),
            ActionChip(
              label: const Text('Sleep'),
              onPressed: () => setState(() => _searchQuery = 'sleep'),
            ),
            ActionChip(
              label: const Text('Stress'),
              onPressed: () => setState(() => _searchQuery = 'stress'),
            ),
            ActionChip(
              label: const Text('Mindfulness'),
              onPressed: () => setState(() => _searchQuery = 'mindfulness'),
            ),
            ActionChip(
              label: const Text('Depression'),
              onPressed: () => setState(() => _searchQuery = 'depression'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}