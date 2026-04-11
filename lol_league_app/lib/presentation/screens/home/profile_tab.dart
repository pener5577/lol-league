import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/notification_provider.dart';
import '../../widgets/common_widgets.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await context.read<PlayerProvider>().loadCurrentPlayer();
    await context.read<NotificationProvider>().loadUnreadCount();
    if (mounted) {
      context.read<AuthProvider>().setCurrentPlayer(
        context.read<PlayerProvider>().currentPlayer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CyberBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 标题
              SliverToBoxAdapter(child: _buildHeader()),
              // 用户信息
              SliverToBoxAdapter(child: _buildUserInfo()),
              // 选手信息
              SliverToBoxAdapter(child: _buildPlayerInfo()),
              // 战队信息
              SliverToBoxAdapter(child: _buildTeamInfo()),
              // 菜单操作
              SliverToBoxAdapter(child: _buildMenuActions(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
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
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '个人中心',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showSettings(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfo() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: UserAvatarCard(
            username: auth.user?.username ?? '未知用户',
            subtitle: '欢迎回来，召唤师',
            isAdmin: auth.isAdmin,
            accentColor: AppColors.neonBlue,
          ),
        );
      },
    );
  }

  Widget _buildPlayerInfo() {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final player = provider.currentPlayer;

        if (player == null) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: GlassCard(
              hasGlow: false,
              padding: const EdgeInsets.all(28),
              borderColor: AppColors.borderDefault,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '您还没有创建选手信息',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  NeonButton(
                    text: '创建选手',
                    icon: Icons.add,
                    onPressed: () => context.push('/player/edit'),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassCard(
                hasGlow: false,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // 标题栏
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person, color: AppColors.neonBlue, size: 20),
                              SizedBox(width: 10),
                              Text(
                                '选手信息',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          NeonButton(
                            text: '编辑',
                            isOutlined: true,
                            color: AppColors.neonBlue,
                            onPressed: () => context.push('/player/edit'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.borderDefault),
                    // 信息行
                    _buildInfoRow('游戏昵称', player.matchName, Icons.videogame_asset),
                    _buildInfoRow('游戏ID', player.gameId, Icons.tag),
                    _buildInfoRow('服务器', player.regionGroup, Icons.dns),
                    _buildInfoRow('大区', RegionData.getGroupBySmallRegion(player.regionGroup), Icons.map),
                    _buildInfoRow('位置', player.position, Icons.location_on),
                    const Divider(height: 1, color: AppColors.borderDefault),
                    // 统计
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('胜率', '${player.winRate}%', AppColors.neonGreen),
                          _buildStatColumn('KDA', player.kdaDisplay, AppColors.neonBlue),
                          _buildStatColumn('MVP', '${player.mvpCount}', AppColors.neonGold),
                        ],
                      ),
                    ),
                    // 战绩
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '战绩: ${player.wins}胜 ${player.losses}负',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neonBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.neonBlue),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamInfo() {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final player = provider.currentPlayer;
        final teamId = player?.teamId;

        if (teamId == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassCard(
              hasGlow: false,
              padding: const EdgeInsets.all(28),
              borderColor: AppColors.borderDefault,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: const Icon(
                      Icons.group_add,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '您还没有加入战队',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  NeonButton(
                    text: '加入战队',
                    isOutlined: true,
                    color: AppColors.neonGold,
                    icon: Icons.search,
                    onPressed: () => context.push('/team/list'),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => context.push('/team/detail/$teamId'),
            child: GlassCard(
              hasGlow: true,
              glowColor: AppColors.neonGold,
              borderColor: AppColors.neonGold.withOpacity(0.3),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppConstants.goldGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppConstants.neonGlow(AppColors.neonGold, 12),
                    ),
                    child: const Icon(
                      Icons.groups,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '战队成员',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '战队ID: $teamId',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        hasGlow: false,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Consumer<NotificationProvider>(
              builder: (context, notifProvider, _) {
                return _buildMenuItem(
                  icon: Icons.notifications,
                  label: '通知中心',
                  color: AppColors.neonPurple,
                  badge: notifProvider.unreadCount > 0 ? notifProvider.unreadCount : null,
                  onTap: () => context.push('/notifications'),
                );
              },
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            _buildMenuItem(
              icon: Icons.leaderboard,
              label: '选手排行榜',
              color: AppColors.neonBlue,
              onTap: () => context.push('/player/rankings'),
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            _buildMenuItem(
              icon: Icons.history,
              label: '约战历史',
              color: AppColors.neonPurple,
              onTap: () => context.push('/match/list'),
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            _buildMenuItem(
              icon: Icons.bar_chart,
              label: '平台统计',
              color: AppColors.neonGreen,
              onTap: () => context.push('/stats'),
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (!auth.isAdmin) return const SizedBox.shrink();
                return Column(
                  children: [
                    const Divider(height: 1, color: AppColors.borderDefault),
                    _buildMenuItem(
                      icon: Icons.verified,
                      label: '审核管理',
                      color: AppColors.neonGold,
                      onTap: () => context.push('/admin/review'),
                    ),
                    const Divider(height: 1, color: AppColors.borderDefault),
                    _buildMenuItem(
                      icon: Icons.people,
                      label: '用户管理',
                      color: AppColors.neonGold,
                      onTap: () => context.push('/admin/users'),
                    ),
                    const Divider(height: 1, color: AppColors.borderDefault),
                    _buildMenuItem(
                      icon: Icons.edit_note,
                      label: '数据录入',
                      color: AppColors.neonGreen,
                      onTap: () => context.push('/admin/data-entry'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int? badge,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neonRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
                context.go('/login');
              },
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.neonRed,
                ),
              ),
              title: const Text(
                '退出登录',
                style: TextStyle(
                  color: AppColors.neonRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
