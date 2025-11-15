import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../chat/screens/chat_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../journal/screens/journal_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/main_screen_index_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final PageController _pageController;
  ProviderSubscription<int>? _tabSubscription;

  static const List<Widget> _mainScreens = <Widget>[
    const DashboardScreen(),
    const JournalScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(mainScreenIndexProvider);
    _pageController = PageController(initialPage: initialIndex);
    _tabSubscription = ref.listenManual<int>(
      mainScreenIndexProvider,
      (previous, next) {
        if (!_pageController.hasClients) {
          return;
        }
        final current = _pageController.page?.round();
        if (current == next) {
          return;
        }
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _tabSubscription?.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainScreenIndexProvider);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          final controller = ref.read(mainScreenIndexProvider.notifier);
          if (controller.state != index) {
            controller.state = index;
          }
        },
        children: _mainScreens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(mainScreenIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Companion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
