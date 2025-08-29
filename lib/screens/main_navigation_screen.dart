import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'enhanced_mission_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import '../providers/app_providers.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _currentIndex = ref.read(mainTabIndexProvider);
    if (_currentIndex == 0 && widget.initialIndex != 0) {
      _currentIndex = widget.initialIndex;
      ref.read(mainTabIndexProvider.notifier).state = _currentIndex;
    }
    
    _tabController = TabController(length: 4, vsync: this, initialIndex: _currentIndex);
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController!.index;
      });
      ref.read(mainTabIndexProvider.notifier).state = _currentIndex;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentIndex = ref.watch(mainTabIndexProvider);
    final languageService = ref.watch(languageServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController != null && _tabController!.index != _currentIndex) {
        _tabController!.animateTo(_currentIndex);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: const [
              HomeScreen(),
              EnhancedMissionScreen(),
              LeaderboardScreen(),
              ProfileScreen(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(context).cardColor.withAlpha(220),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TabBar(
                  controller: _tabController,
                  indicator: const BoxDecoration(),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.transparent,
                  unselectedLabelColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    ref.read(mainTabIndexProvider.notifier).state = index;
                  },
                  tabs: <Widget>[
                    Container(
                      child: (_currentIndex == 0)
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  languageService.getLocalizedNavigationLabel('Home'),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(2.5))),
                                  height: 5,
                                  width: 5,
                                )
                              ],
                            )
                          : Icon(
                              Icons.home,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                    ),
                    Container(
                        child: (_currentIndex == 1)
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Missions',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      letterSpacing: -0.5,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.5))),
                                    height: 5,
                                    width: 5,
                                  )
                                ],
                              )
                            : Icon(
                                Icons.assignment,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                    Container(
                        child: (_currentIndex == 2)
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Ranking',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.5))),
                                    height: 5,
                                    width: 5,
                                  )
                                ],
                              )
                            : Icon(
                                Icons.leaderboard,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                    Container(
                        child: (_currentIndex == 3)
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    languageService.getLocalizedNavigationLabel('profile'),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2.5))),
                                    height: 5,
                                    width: 5,
                                  )
                                ],
                              )
                            : Icon(
                                Icons.person,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}




