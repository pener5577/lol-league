import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/stats_provider.dart';
import '../../../domain/providers/match_provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../data/models/match_model.dart';

// ==================== 首页 ====================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadPublicStats();
      context.read<MatchProvider>().loadMatches();
      context.read<PlayerProvider>().loadWinRateRanking();
      context.read<PlayerProvider>().loadKdaRanking();
      context.read<PlayerProvider>().loadMvpRanking();
      context.read<TeamProvider>().loadScoreRanking();
      context.read<TeamProvider>().loadWinStreakRanking();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF020208), Color(0xFF050510), Color(0xFF080818)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 高级背景效果
          _buildAdvancedBackground(),
          // 主内容
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<StatsProvider>().loadPublicStats();
                await context.read<MatchProvider>().loadMatches();
              },
              color: AppColors.neonBlue,
              backgroundColor: AppColors.backgroundCard,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildPlayerInfo()),
                  SliverToBoxAdapter(child: _buildStatsSection()),
                  SliverToBoxAdapter(child: _buildQuickActions()),
                  SliverToBoxAdapter(child: _buildRecentMatches()),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // 底部紫色渐变
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0x302E1060),
                    Colors.transparent,
                  ],
                  center: Alignment.bottomCenter,
                  radius: 1.5,
                ),
              ),
            ),
          ),
          // 右上角蓝色光晕
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0x201366FF).withAlpha(150),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 左下角粉色光晕
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0x20FF0099).withAlpha(100),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 装饰性水晶/宝石图案
          Positioned(
            top: 60,
            right: 30,
            child: _buildCrystalDecoration(),
          ),
          Positioned(
            top: 150,
            left: -20,
            child: _buildSmallCrystal(),
          ),
          // 网格
          Positioned.fill(
            child: CustomPaint(
              painter: _AdvancedGridPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrystalDecoration() {
    return Transform.rotate(
      angle: 0.3,
      child: Container(
        width: 80,
        height: 100,
        child: Stack(
          children: [
            // 主水晶
            Positioned(
              top: 0,
              left: 20,
              child: Container(
                width: 40,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B4DCA), Color(0xFF4A90D9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9B4DCA).withAlpha(128),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // 次水晶
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withAlpha(102),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCrystal() {
    return Transform.rotate(
      angle: -0.2,
      child: Container(
        width: 30,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4FF), Color(0xFF9146FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonBlue.withAlpha(76),
              blurRadius: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Row(
          children: [
            // LoL风格Logo
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A3E), Color(0xFF0D0D25)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.neonGold.withAlpha(76)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGold.withAlpha(51),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield,
                size: 32,
                color: AppColors.neonGold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppConstants.goldGradient.createShader(bounds),
                    child: const Text(
                      'LEAGUE OF LEGENDS',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '业余联赛平台',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1642).withAlpha(200),
                  const Color(0xFF0D0A20).withAlpha(230),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonGold.withAlpha(51)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(76),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // 召唤师图标
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonGold, width: 2),
                    boxShadow: AppConstants.neonGlow(AppColors.neonBlue, 15),
                  ),
                  child: Center(
                    child: Text(
                      (user?.username ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user?.username ?? '召唤师',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 段位徽章
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B6914), Color(0xFF5D4412)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.neonGold.withAlpha(102)),
                            ),
                            child: const Text(
                              '入门',
                              style: TextStyle(
                                color: AppColors.neonGold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '欢迎来到英雄联盟的世界',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // 快捷操作按钮
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neonGold.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neonGold.withAlpha(76)),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.neonGold,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer<StatsProvider>(
      builder: (context, stats, _) {
        final data = stats.publicStats;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('平台数据', Icons.analytics_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('选手', '${data?.players ?? 0}', _buildChampionIcon(), AppColors.neonBlue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('战队', '${data?.teams ?? 0}', _buildTeamIcon(), AppColors.neonPurple)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('比赛', '${data?.totalMatches ?? 0}', _buildMatchIcon(), AppColors.neonGold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard('击杀', '${data?.totalKills ?? 0}', _buildKillIcon(), AppColors.neonRed)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('助攻', '${data?.totalAssists ?? 0}', _buildAssistIcon(), AppColors.neonGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('MVP', '${data?.totalMVP ?? 0}', _buildMvpIcon(), AppColors.neonGold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChampionIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withAlpha(38),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person, color: AppColors.neonBlue, size: 20),
    );
  }

  Widget _buildTeamIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neonPurple.withAlpha(38),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.groups, color: AppColors.neonPurple, size: 20),
    );
  }

  Widget _buildMatchIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neonGold.withAlpha(38),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.sports_esports, color: AppColors.neonGold, size: 20),
    );
  }

  Widget _buildKillIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neonRed.withAlpha(38),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.military_tech, color: AppColors.neonRed, size: 20),
    );
  }

  Widget _buildAssistIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withAlpha(38),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.thumb_up, color: AppColors.neonGreen, size: 20),
    );
  }

  Widget _buildMvpIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neonGold.withAlpha(38),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.emoji_events, color: AppColors.neonGold, size: 20),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.neonGold.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neonGold.withAlpha(51)),
          ),
          child: Icon(icon, color: AppColors.neonGold, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Widget icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(20),
            color.withAlpha(5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('快捷操作', Icons.flash_on),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildActionCard('发布约战', Icons.add_circle, AppColors.neonGreen, () => context.push('/match/create'))),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard('查看战队', Icons.groups, AppColors.neonPurple, () => context.push('/team/list'))),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard('排行榜', Icons.leaderboard, AppColors.neonGold, () => context.go('/home/tab/1'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withAlpha(15),
              color.withAlpha(5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: color.withAlpha(76)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMatches() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('最新约战', Icons.sports_esports),
              TextButton(
                onPressed: () => context.go('/home/tab/2'),
                child: ShaderMask(
                  shaderCallback: (bounds) => AppConstants.goldGradient.createShader(bounds),
                  child: const Text(
                    '查看更多',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<MatchProvider>(
            builder: (context, matchProvider, _) {
              final matches = matchProvider.matches.take(3).toList();
              if (matches.isEmpty) {
                return _buildEmptyMatchCard();
              }
              return Column(
                children: matches.map((match) {
                  return _buildMatchItem(match);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMatchCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1642).withAlpha(128),
            const Color(0xFF0D0A20).withAlpha(179),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neonGold.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neonGold.withAlpha(51)),
              ),
              child: const Icon(Icons.sports_esports, size: 40, color: AppColors.neonGold),
            ),
            const SizedBox(height: 16),
            const Text(
              '暂无约战',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '成为第一个发布约战的战队吧',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchItem(match) {
    final statusColor = _getStatusColor(match.status);
    return GestureDetector(
      onTap: () => context.push('/match/detail/${match.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E1642).withAlpha(200),
              const Color(0xFF0D0A20).withAlpha(230),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTeamInfo(match.team?.name ?? '战队', AppColors.neonBlue),
                ),
                // VS标志
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B6914), Color(0xFF5D4412)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonGold),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGold.withAlpha(76),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        match.mode ?? '5v5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'VS',
                        style: TextStyle(
                          color: AppColors.neonGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildTeamInfo(match.opponent?.name ?? '待应战', AppColors.neonPurple),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    statusColor.withAlpha(76),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(match.time),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withAlpha(76)),
                  ),
                  child: Text(
                    match.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(102)),
          ),
          child: Icon(Icons.shield, size: 22, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case '待审核':
        return AppColors.neonOrange;
      case '待应战':
        return AppColors.neonBlue;
      case '已约战':
        return AppColors.neonGreen;
      case '已结束':
        return AppColors.textMuted;
      case '已取消':
      case '未通过':
        return AppColors.neonRed;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '待定';
    return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ==================== 排行榜 ====================
class RankingsTab extends StatefulWidget {
  const RankingsTab({super.key});

  @override
  State<RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<RankingsTab> {
  int _selectedFilter = 0;
  final _filters = ['胜率榜', 'KDA榜', 'MVP榜'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadWinRateRanking();
      context.read<PlayerProvider>().loadKdaRanking();
      context.read<PlayerProvider>().loadMvpRanking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0015), Color(0xFF05001A), Color(0xFF0D0A20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          _buildLoLBackgroundRankings(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilterTabs(),
                Expanded(child: _buildRankingList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoLBackgroundRankings() {
    return Positioned.fill(
      child: Stack(
        children: [
          // 左侧金色光晕
          Positioned(
            top: 100,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0x30FFD700),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _LoLGridPainter(),
            ),
          ),
        ],
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
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppConstants.neonGlow(AppColors.neonGold, 15),
            ),
            child: const Icon(Icons.emoji_events, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '排行榜',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '选手 & 战队排名',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1642).withAlpha(200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: List.generate(3, (index) {
            final isSelected = _selectedFilter == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppConstants.goldGradient : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? AppConstants.neonGlow(AppColors.neonGold, 8) : null,
                  ),
                  child: Text(
                    _filters[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRankingList() {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        List<dynamic> rankingList;
        String Function(dynamic) formatValue;

        switch (_selectedFilter) {
          case 0:
            rankingList = provider.winRateRanking;
            formatValue = (v) => '${v}%';
            break;
          case 1:
            rankingList = provider.kdaRanking;
            formatValue = (v) => v.toStringAsFixed(2);
            break;
          case 2:
            rankingList = provider.mvpRanking;
            formatValue = (v) => '${v}次';
            break;
          default:
            rankingList = provider.winRateRanking;
            formatValue = (v) => '${v}%';
        }

        if (rankingList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.leaderboard, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text('暂无排行数据', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.read<PlayerProvider>().loadWinRateRanking();
                    context.read<PlayerProvider>().loadKdaRanking();
                    context.read<PlayerProvider>().loadMvpRanking();
                  },
                  child: const Text('刷新'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<PlayerProvider>().loadWinRateRanking();
            await context.read<PlayerProvider>().loadKdaRanking();
            await context.read<PlayerProvider>().loadMvpRanking();
          },
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: rankingList.length,
            itemBuilder: (context, index) {
              final item = rankingList[index];
              return _buildRankingCard({
                'name': item.name,
                'value': formatValue(item.value),
                'subtitle': item.matchName ?? null,
                'rank': index + 1,
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> item) {
    final rank = item['rank'] as int;
    final isTopThree = rank <= 3;
    final rankColor = _getRankColor(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1642).withAlpha(isTopThree ? 230 : 128),
            const Color(0xFF0D0A20).withAlpha(isTopThree ? 230 : 179),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTopThree ? rankColor.withAlpha(102) : AppColors.borderDefault,
          width: isTopThree ? 1.5 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: rankColor.withAlpha(38),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          _buildRankBadge(rank, rankColor, isTopThree),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'] as String,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [rankColor, rankColor.withAlpha(178)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: rankColor.withAlpha(76), blurRadius: 8),
              ],
            ),
            child: Text(
              item['value'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank, Color color, bool isTopThree) {
    const emojis = ['🥇', '🥈', '🥉'];

    if (isTopThree) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withAlpha(153)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withAlpha(128), blurRadius: 12),
          ],
        ),
        child: Center(
          child: Text(
            emojis[rank - 1],
            style: const TextStyle(fontSize: 22),
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.neonGold;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.neonBlue;
    }
  }
}

// ==================== 约战大厅 ====================
class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  int _selectedFilter = 0;
  final _filters = ['全部', '待应战', '已约战', '已结束'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0015), Color(0xFF05001A), Color(0xFF0D0A20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          _buildLoLBackgroundMatches(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilterTabs(),
                Expanded(child: _buildMatchList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoLBackgroundMatches() {
    return Positioned.fill(
      child: Stack(
        children: [
          // 右侧蓝色光晕
          Positioned(
            top: 50,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0x251366FF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _LoLGridPainter(),
            ),
          ),
        ],
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
              gradient: const LinearGradient(
                colors: [Color(0xFF1366FF), Color(0xFF0D4BCD)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppConstants.neonGlow(const Color(0xFF1366FF), 15),
            ),
            child: const Icon(Icons.sports_esports, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '约战大厅',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '发起挑战 or 应战其他战队',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isSelected = _selectedFilter == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppConstants.neonBlueGradient : null,
                    color: isSelected ? null : const Color(0xFF1E1642).withAlpha(200),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.borderDefault,
                    ),
                    boxShadow: isSelected ? AppConstants.neonGlow(AppColors.neonBlue, 8) : null,
                  ),
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMatchList() {
    return Consumer<MatchProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<MatchModel> matches;
        switch (_selectedFilter) {
          case 1:
            matches = provider.waitingMatches;
            break;
          case 2:
            matches = provider.scheduledMatches;
            break;
          default:
            matches = provider.matches;
        }

        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_esports, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text('暂无约战', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<MatchProvider>().loadMatches(),
                  child: const Text('刷新'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => context.read<MatchProvider>().loadMatches(),
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return _buildMatchCard({
                'team': match.team?.name ?? '战队',
                'opponent': match.opponent?.name ?? '待应战',
                'mode': match.mode ?? '5v5',
                'time': _formatMatchTime(match.time),
                'status': match.status,
              });
            },
          ),
        );
      },
    );
  }

  String _formatMatchTime(DateTime? time) {
    if (time == null) return '待定';
    final now = DateTime.now();
    final diff = time.difference(now);
    if (diff.inDays == 0) {
      return '今天 ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '明天 ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 2) {
      return '后天 ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMatchCard(Map<String, String> match) {
    final statusColor = _getStatusColor(match['status']!);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1642).withAlpha(200),
            const Color(0xFF0D0A20).withAlpha(230),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTeamInfo(match['team']!, AppColors.neonBlue)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppConstants.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppConstants.neonGlow(AppColors.neonBlue, 12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            match['mode']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _buildTeamInfo(match['opponent']!, AppColors.neonPurple)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  statusColor.withAlpha(76),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1642),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.schedule, size: 18, color: AppColors.neonGold),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match['time']!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '比赛时间',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withAlpha(102)),
                    boxShadow: [
                      BoxShadow(color: statusColor.withAlpha(38), blurRadius: 8),
                    ],
                  ),
                  child: Text(
                    match['status']!,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(102), width: 2),
            boxShadow: [
              BoxShadow(color: color.withAlpha(38), blurRadius: 16),
            ],
          ),
          child: Icon(
            name == '待应战' ? Icons.hourglass_empty : Icons.shield,
            size: 28,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待应战':
        return AppColors.neonBlue;
      case '已约战':
        return AppColors.neonGreen;
      case '已结束':
        return AppColors.textMuted;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ==================== 个人中心 ====================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0015), Color(0xFF05001A), Color(0xFF0D0A20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _LoLGridPainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildMenuList(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1642).withAlpha(200),
                const Color(0xFF0D0A20).withAlpha(230),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.neonGold.withAlpha(76)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGold.withAlpha(38),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonGold, width: 3),
                      boxShadow: AppConstants.neonGlow(AppColors.neonBlue, 20),
                    ),
                    child: Center(
                      child: Text(
                        (user?.username ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user?.username ?? '召唤师',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (user?.isAdmin == true) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: AppConstants.goldGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      '管理员',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonGold.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.neonGold.withAlpha(51)),
                          ),
                          child: Text(
                            user?.isAdmin == true ? 'Level 99 管理员' : 'Level 1 召唤师',
                            style: const TextStyle(
                              color: AppColors.neonGold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.borderDefault,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('胜场', '0', AppColors.neonGreen),
                  Container(width: 1, height: 40, color: AppColors.borderDefault),
                  _buildStatItem('战队', '无', AppColors.neonPurple),
                  Container(width: 1, height: 40, color: AppColors.borderDefault),
                  _buildStatItem('段位', '入门', AppColors.neonGold),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1642).withAlpha(180),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: AppColors.neonGold, size: 20),
              SizedBox(width: 8),
              Text(
                '近期数据',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildQuickStatCard('本周战绩', '0W/0L', AppColors.neonGreen, Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickStatCard('本周MVP', '0次', AppColors.neonGold, Icons.emoji_events)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final baseMenus = [
      {'icon': Icons.notifications, 'label': '通知中心', 'color': AppColors.neonPurple, 'route': '/notifications'},
      {'icon': Icons.person_outline, 'label': '选手资料', 'color': AppColors.neonBlue, 'route': '/player/profile'},
      {'icon': Icons.groups, 'label': '我的战队', 'color': AppColors.neonPurple, 'route': '/team/list'},
      {'icon': Icons.history, 'label': '比赛记录', 'color': AppColors.neonGreen, 'route': '/match/list'},
      {'icon': Icons.bar_chart, 'label': '数据统计', 'color': AppColors.neonGold, 'route': '/stats'},
    ];

    final adminMenus = [
      {'icon': Icons.verified, 'label': '审核管理', 'color': AppColors.neonGold, 'route': '/admin/review'},
      {'icon': Icons.people, 'label': '用户管理', 'color': AppColors.neonGold, 'route': '/admin/users'},
      {'icon': Icons.edit_note, 'label': '数据管理', 'color': AppColors.neonGreen, 'route': '/admin/data-management'},
    ];

    final bottomMenus = [
      {'icon': Icons.settings, 'label': '设置', 'color': AppColors.textMuted, 'route': '/settings'},
      {'icon': Icons.logout, 'label': '退出登录', 'color': AppColors.neonRed, 'route': null},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1642).withAlpha(180),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 构建完整菜单
          final allMenus = <Map<String, dynamic>>[];
          allMenus.addAll(baseMenus);
          if (auth.isAdmin) {
            allMenus.addAll(adminMenus);
          }
          allMenus.addAll(bottomMenus);

          return Column(
            children: List.generate(allMenus.length, (index) {
              final menu = allMenus[index];
              final color = menu['color'] as Color;
              final isLast = index == allMenus.length - 1;

              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      if (menu['route'] != null) {
                        context.push(menu['route'] as String);
                      } else {
                        context.read<AuthProvider>().logout();
                        context.go('/login');
                      }
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(menu['icon'] as IconData, color: color, size: 22),
                    ),
                    title: Text(
                      menu['label'] as String,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 70,
                      color: AppColors.borderDefault.withAlpha(128),
                    ),
                ],
              );
            }),
          );
        },
      ),
    );
  }
}

// ==================== 高级网格背景画笔 ====================
class _AdvancedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 主网格
    final paint = Paint()
      ..color = const Color.fromRGBO(40, 40, 64, 0.12)
      ..strokeWidth = 0.5;

    const spacing = 50.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 辅助细网格
    final finePaint = Paint()
      ..color = const Color.fromRGBO(40, 40, 64, 0.05)
      ..strokeWidth = 0.3;

    const fineSpacing = 10.0;

    for (double x = 0; x < size.width; x += fineSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), finePaint);
    }

    for (double y = 0; y < size.height; y += fineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), finePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== LoL风格背景画笔 ====================
class _LoLGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(30, 22, 66, 0.3)
      ..strokeWidth = 0.5;

    const spacing = 60.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
