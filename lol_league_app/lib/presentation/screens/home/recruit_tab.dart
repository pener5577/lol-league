import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../data/models/player_model.dart';
import '../../../data/models/team_model.dart';
import '../../widgets/common_widgets.dart';

class RecruitTab extends StatefulWidget {
  const RecruitTab({super.key});

  @override
  State<RecruitTab> createState() => _RecruitTabState();
}

class _RecruitTabState extends State<RecruitTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedRegion;
  String? _selectedPosition;
  String? _playerRegionGroup;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPlayerRegion();
    });
  }

  void _initPlayerRegion() {
    final currentPlayer = context.read<AuthProvider>().currentPlayer;
    if (currentPlayer != null) {
      setState(() {
        _playerRegionGroup = currentPlayer.regionGroup;
        _selectedRegion = currentPlayer.regionGroup;
      });
    }
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    _loadPlayers();
    _loadTeams();
  }

  void _loadPlayers() {
    context.read<PlayerProvider>().loadPlayers(
      region: _selectedRegion,
      position: _selectedPosition,
      teamless: true,
    );
  }

  void _loadTeams() {
    context.read<TeamProvider>().loadTeams(region: _selectedRegion);
  }

  @override
  Widget build(BuildContext context) {
    return CyberBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildFilterChips(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTeamRecruitSection(), // 战队招募选手
                  _buildPlayerRecruitSection(), // 选手找战队
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
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF6B35)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppConstants.neonGlow(AppColors.neonGold, 20),
            ),
            child: const Icon(
              Icons.person_add,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '招募大厅',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '寻找志同道合的队友',
                  style: TextStyle(
                    fontSize: 13,
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
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: AppConstants.goldGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: '战队招募选手'),
          Tab(text: '选手找战队'),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip(
            label: '全部大区',
            isSelected: _selectedRegion == null,
            onTap: () {
              setState(() => _selectedRegion = null);
              _loadData();
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _playerRegionGroup ?? '我的大区',
            isSelected: _selectedRegion == _playerRegionGroup,
            onTap: () {
              setState(() => _selectedRegion = _playerRegionGroup);
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonGold.withAlpha(30) : AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.neonGold : AppColors.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.neonGold : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 战队招募选手 Tab
  Widget _buildTeamRecruitSection() {
    return Consumer2<PlayerProvider, AuthProvider>(
      builder: (context, playerProvider, authProvider, _) {
        if (playerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final players = playerProvider.players;
        final currentPlayer = authProvider.currentPlayer;
        final myTeamId = currentPlayer?.teamId;

        if (players.isEmpty) {
          return PremiumEmptyState(
            message: '暂无待招募的选手',
            icon: Icons.person_search,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadPlayers(),
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              // 不显示自己
              if (player.id == currentPlayer?.id) {
                return const SizedBox.shrink();
              }
              return _PlayerRecruitCard(
                player: player,
                myTeamId: myTeamId,
              );
            },
          ),
        );
      },
    );
  }

  // 选手找战队 Tab
  Widget _buildPlayerRecruitSection() {
    return Consumer2<TeamProvider, AuthProvider>(
      builder: (context, teamProvider, authProvider, _) {
        if (teamProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final teams = teamProvider.teams;
        final currentPlayer = authProvider.currentPlayer;
        final myTeamId = currentPlayer?.teamId;

        // 如果玩家已经有战队，显示提示
        if (myTeamId != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text(
                  '您已在战队中',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.push('/team/detail/$myTeamId'),
                  child: const Text('查看我的战队'),
                ),
              ],
            ),
          );
        }

        if (teams.isEmpty) {
          return PremiumEmptyState(
            message: '暂无招募中的战队',
            icon: Icons.groups,
            actionText: '创建战队',
            onAction: () => context.push('/team/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadTeams(),
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return _TeamRecruitCard(team: team);
            },
          ),
        );
      },
    );
  }
}

// 选手卡片（战队招募选手）
class _PlayerRecruitCard extends StatelessWidget {
  final PlayerModel player;
  final int? myTeamId;

  const _PlayerRecruitCard({
    required this.player,
    this.myTeamId,
  });

  @override
  Widget build(BuildContext context) {
    final currentPlayer = context.read<AuthProvider>().currentPlayer;
    final isCaptain = currentPlayer?.id == player.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppConstants.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppConstants.neonGlow(AppColors.neonBlue, 12),
              ),
              child: Center(
                child: Text(
                  player.matchName.isNotEmpty ? player.matchName.substring(0, 1) : '?',
                  style: const TextStyle(
                    fontSize: 22,
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
                  Text(
                    player.matchName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.regionGroup} · ${player.position}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStatChip('胜率', '${player.winRate}%', AppColors.neonGreen),
                      const SizedBox(width: 8),
                      _buildStatChip('KDA', player.kdaDisplay, AppColors.neonBlue),
                    ],
                  ),
                ],
              ),
            ),
            if (myTeamId != null && !isCaptain)
              NeonButton(
                text: '邀请',
                color: AppColors.neonGold,
                icon: Icons.person_add,
                onPressed: () => _showInviteDialog(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('邀请加入战队'),
        content: Text('确定邀请 ${player.matchName} 加入您的战队吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (myTeamId == null) return;
              final success = await context.read<TeamProvider>().invitePlayer(myTeamId!, player.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已邀请 ${player.matchName} 加入战队'), backgroundColor: Colors.green),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<TeamProvider>().error ?? '邀请失败'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('确认邀请'),
          ),
        ],
      ),
    );
  }
}

// 战队卡片（选手找战队）
class _TeamRecruitCard extends StatelessWidget {
  final TeamModel team;

  const _TeamRecruitCard({required this.team});

  @override
  Widget build(BuildContext context) {
    final currentPlayer = context.read<AuthProvider>().currentPlayer;
    final hasTeam = currentPlayer?.teamId != null;

    return GestureDetector(
      onTap: () => context.push('/team/detail/${team.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: AppConstants.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppConstants.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppConstants.neonGlow(AppColors.neonGold, 12),
                ),
                child: Center(
                  child: Text(
                    team.name.isNotEmpty ? team.name.substring(0, 1) : '?',
                    style: const TextStyle(
                      fontSize: 22,
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
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${team.regionGroup} · ${team.wins}胜 ${team.losses}负',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatChip('积分', '${team.score}', AppColors.neonBlue),
                        const SizedBox(width: 8),
                        _buildStatChip('成员', '${team.members.length}/5', AppColors.neonPurple),
                      ],
                    ),
                  ],
                ),
              ),
              if (!hasTeam)
                NeonButton(
                  text: '申请',
                  color: AppColors.neonGreen,
                  icon: Icons.group_add,
                  onPressed: () => _showApplyDialog(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showApplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('申请加入战队'),
        content: Text('确定申请加入 ${team.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<TeamProvider>().joinTeam(team.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('申请成功，请等待队长审核'), backgroundColor: Colors.green),
                );
                // 重新加载选手数据
                context.read<PlayerProvider>().loadCurrentPlayer();
                context.read<AuthProvider>().setCurrentPlayer(context.read<PlayerProvider>().currentPlayer);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<TeamProvider>().error ?? '申请失败'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('确认申请'),
          ),
        ],
      ),
    );
  }
}
