import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../domain/providers/auth_provider.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/main_screen.dart';
import '../presentation/screens/home/recruit_tab.dart';
import '../presentation/screens/player/player_profile_screen.dart';
import '../presentation/screens/player/player_edit_screen.dart';
import '../presentation/screens/player/player_rankings_screen.dart';
import '../presentation/screens/team/team_list_screen.dart';
import '../presentation/screens/team/team_detail_screen.dart';
import '../presentation/screens/team/team_create_screen.dart';
import '../presentation/screens/team/team_recruit_screen.dart';
import '../presentation/screens/match/match_list_screen.dart';
import '../presentation/screens/match/match_detail_screen.dart';
import '../presentation/screens/match/match_create_screen.dart';
import '../presentation/screens/stats/stats_screen.dart';
import '../presentation/screens/admin/admin_review_screen.dart';
import '../presentation/screens/admin/admin_users_screen.dart';
import '../presentation/screens/admin/data_entry_screen.dart';
import '../presentation/screens/admin/data_management_screen.dart';
import '../presentation/screens/notification/notification_list_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => _HomeShell(child: child),
          routes: [
            GoRoute(path: '/home', redirect: (context, state) => '/home/tab/0'),
            GoRoute(
              path: '/home/tab/:index',
              pageBuilder: (context, state) {
                final index = int.tryParse(state.pathParameters['index'] ?? '0') ?? 0;
                return NoTransitionPage(
                  child: MainScreenWithTab(initialIndex: index),
                );
              },
            ),
          ],
        ),
        GoRoute(path: '/player/profile', builder: (context, state) => const PlayerProfileScreen()),
        GoRoute(path: '/player/edit', builder: (context, state) => const PlayerEditScreen()),
        GoRoute(path: '/player/rankings', builder: (context, state) => const PlayerRankingsScreen()),
        GoRoute(path: '/team/list', builder: (context, state) => const TeamListScreen()),
        GoRoute(path: '/team/detail/:id', builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TeamDetailScreen(teamId: id);
        }),
        GoRoute(path: '/team/create', builder: (context, state) => const TeamCreateScreen()),
        GoRoute(path: '/team/recruit/:id', builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TeamRecruitScreen(teamId: id);
        }),
        GoRoute(path: '/match/list', builder: (context, state) => const MatchListScreen()),
        GoRoute(path: '/match/detail/:id', builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MatchDetailScreen(matchId: id);
        }),
        GoRoute(path: '/match/create', builder: (context, state) => const MatchCreateScreen()),
        GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
        GoRoute(path: '/admin/review', builder: (context, state) => const AdminReviewScreen()),
        GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
        GoRoute(path: '/admin/data-entry', builder: (context, state) => const DataEntryScreen()),
        GoRoute(path: '/admin/data-management', builder: (context, state) => const DataManagementScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationListScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
    );
  }
}

// 首页 Shell - 包装 MainScreen
class _HomeShell extends StatefulWidget {
  final Widget child;

  const _HomeShell({required this.child});

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// 带 Tab 索引的 MainScreen
class MainScreenWithTab extends StatefulWidget {
  final int initialIndex;

  const MainScreenWithTab({super.key, this.initialIndex = 0});

  @override
  State<MainScreenWithTab> createState() => _MainScreenWithTabState();
}

class _MainScreenWithTabState extends State<MainScreenWithTab> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(MainScreenWithTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex && widget.initialIndex != _currentIndex) {
      _pageController.animateToPage(
        widget.initialIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          // 同步 URL
          context.go('/home/tab/$index');
        },
        children: const [
          HomeTab(),
          RankingsTab(),
          MatchesTab(),
          RecruitTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded, '首页', Color(0xFF00E5FF)),
      (Icons.leaderboard_rounded, '排行', Color(0xFFFFCC00)),
      (Icons.sports_esports_rounded, '约战', Color(0xFFAA44FF)),
      (Icons.group_add_rounded, '招募', Color(0xFF00FF99)),
      (Icons.person_rounded, '我的', Color(0xFFFF0099)),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xF0080818), Color(0xF0101020)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(
          top: BorderSide(color: Color(0xFF252540), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(153),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Color(0xFF00E5FF).withAlpha(13),
            blurRadius: 60,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final isSelected = _currentIndex == index;
              final color = items[index].$3;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(20) : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected
                        ? Border.all(color: color.withAlpha(100), width: 1)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withAlpha(50),
                              blurRadius: 20,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          items[index].$1,
                          color: isSelected ? color : const Color(0xFF505068),
                          size: isSelected ? 28 : 26,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          color: isSelected ? color : const Color(0xFF505068),
                          fontSize: isSelected ? 12 : 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          letterSpacing: isSelected ? 0.5 : 0,
                        ),
                        child: Text(items[index].$2),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
