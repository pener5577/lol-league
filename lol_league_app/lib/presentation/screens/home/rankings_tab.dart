import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../widgets/common_widgets.dart';

class RankingsTab extends StatefulWidget {
  const RankingsTab({super.key});

  @override
  State<RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<RankingsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final playerProvider = context.read<PlayerProvider>();
    final teamProvider = context.read<TeamProvider>();

    playerProvider.loadWinRateRanking();
    playerProvider.loadKdaRanking();
    playerProvider.loadMvpRanking();
    teamProvider.loadScoreRanking();
    teamProvider.loadWinStreakRanking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CyberBackground(
      child: SafeArea(
        child: Column(
          children: [
            // 标题区域
            _buildHeader(),
            // TabBar
            _buildTabBar(),
            // 排行榜内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlayerRanking(
                    (p) => p.winRateRanking,
                    (v) => '${v}%',
                    AppColors.neonBlue,
                  ),
                  _buildPlayerRanking(
                    (p) => p.kdaRanking,
                    (v) => v.toStringAsFixed(2),
                    AppColors.neonPurple,
                  ),
                  _buildPlayerRanking(
                    (p) => p.mvpRanking,
                    (v) => '${v}次',
                    AppColors.neonGold,
                  ),
                  _buildTeamRanking(
                    (t) => t.scoreRanking,
                    (v) => '$v分',
                    AppColors.neonBlue,
                  ),
                  _buildTeamRanking(
                    (t) => t.winStreakRanking,
                    (v) => '${v}连胜',
                    AppColors.neonGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppConstants.goldGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppConstants.neonGlow(AppColors.neonGold, 20),
            ),
            child: const Icon(
              Icons.leaderboard,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '排行榜',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: AppConstants.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: '选手胜率'),
          Tab(text: '选手KDA'),
          Tab(text: '选手MVP'),
          Tab(text: '战队积分'),
          Tab(text: '战队连胜'),
        ],
      ),
    );
  }

  Widget _buildPlayerRanking(
    List<dynamic> Function(PlayerProvider) getList,
    String Function(dynamic) formatValue,
    Color accentColor,
  ) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final list = getList(provider);
        if (list.isEmpty) {
          return const PremiumEmptyState(
            message: '暂无排行数据',
            icon: Icons.leaderboard,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return PremiumRankCard(
                rank: index + 1,
                name: item.name,
                value: formatValue(item.value),
                subtitle: item.matchName ?? null,
                accentColor: accentColor,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTeamRanking(
    List<dynamic> Function(TeamProvider) getList,
    String Function(dynamic) formatValue,
    Color accentColor,
  ) {
    return Consumer<TeamProvider>(
      builder: (context, provider, _) {
        final list = getList(provider);
        if (list.isEmpty) {
          return const PremiumEmptyState(
            message: '暂无排行数据',
            icon: Icons.leaderboard,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return PremiumRankCard(
                rank: index + 1,
                name: item.name,
                value: formatValue(item.value),
                accentColor: accentColor,
              );
            },
          ),
        );
      },
    );
  }
}
