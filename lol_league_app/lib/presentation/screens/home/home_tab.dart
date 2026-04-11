import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/stats_provider.dart';
import '../../../domain/providers/match_provider.dart';
import '../../widgets/common_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.backgroundDeep, AppColors.backgroundPrimary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              await context.read<StatsProvider>().loadPublicStats();
              await context.read<MatchProvider>().loadMatches();
            } catch (e) {
              debugPrint('Refresh error: $e');
            }
          },
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildStatsSection(context)),
              SliverToBoxAdapter(child: _buildQuickActions(context)),
              SliverToBoxAdapter(child: _buildRecentMatches(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppConstants.neonGlow(AppColors.neonBlue, 20),
            ),
            child: const Icon(Icons.sports_esports, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '英雄联盟',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '业余联赛平台',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, stats, _) {
        final data = stats.publicStats;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('平台数据'),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  GamingStatCard(title: '选手', value: '${data?.players ?? 0}', icon: Icons.person, color: AppColors.neonBlue, subtitle: 'REGISTERED'),
                  GamingStatCard(title: '战队', value: '${data?.teams ?? 0}', icon: Icons.groups, color: AppColors.neonGold, subtitle: 'TEAMS'),
                  GamingStatCard(title: '比赛', value: '${data?.totalMatches ?? 0}', icon: Icons.sports_esports, color: AppColors.neonPurple, subtitle: 'MATCHES'),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  GamingStatCard(title: '总击杀', value: '${data?.totalKills ?? 0}', icon: Icons.military_tech, color: AppColors.neonRed, subtitle: 'KILLS'),
                  GamingStatCard(title: '总助攻', value: '${data?.totalAssists ?? 0}', icon: Icons.thumb_up, color: AppColors.neonGreen, subtitle: 'ASSISTS'),
                  GamingStatCard(title: 'MVP', value: '${data?.totalMVP ?? 0}', icon: Icons.emoji_events, color: AppColors.neonGold, subtitle: 'AWARDS'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('快捷操作'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: QuickActionCard(icon: Icons.add_circle, label: '发布约战', color: AppColors.neonGreen, onTap: () => context.push('/match/create'))),
              const SizedBox(width: 12),
              Expanded(child: QuickActionCard(icon: Icons.search, label: '查看战队', color: AppColors.neonBlue, onTap: () => context.push('/team/list'))),
              const SizedBox(width: 12),
              Expanded(child: QuickActionCard(icon: Icons.leaderboard, label: '排行榜', color: AppColors.neonGold, onTap: () => context.go('/home/rankings'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatches(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('最新约战'),
              TextButton(
                onPressed: () => context.go('/home/matches'),
                child: const Text('查看更多', style: TextStyle(color: AppColors.neonBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<MatchProvider>(
            builder: (context, matchProvider, _) {
              final matches = matchProvider.matches.take(3).toList();
              if (matches.isEmpty) {
                return GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: const Center(child: Column(children: [
                    Icon(Icons.sports_esports, size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text('暂无约战', style: TextStyle(color: AppColors.textSecondary)),
                  ])),
                );
              }
              return Column(
                children: matches.map((match) {
                  return MatchCard(
                    teamName: match.team?.name ?? '战队',
                    opponentName: match.opponent?.name ?? '待应战',
                    mode: match.mode ?? '5v5',
                    time: _formatTime(match.time),
                    status: match.status,
                    onTap: () => context.push('/match/detail/${match.id}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neonBlue.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.analytics_outlined, color: AppColors.neonBlue, size: 18),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '待定';
    return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
