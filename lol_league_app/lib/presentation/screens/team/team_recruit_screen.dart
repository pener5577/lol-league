import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../data/models/player_model.dart';
import '../../widgets/common_widgets.dart';

class TeamRecruitScreen extends StatefulWidget {
  final int teamId;

  const TeamRecruitScreen({super.key, required this.teamId});

  @override
  State<TeamRecruitScreen> createState() => _TeamRecruitScreenState();
}

class _TeamRecruitScreenState extends State<TeamRecruitScreen> {
  String? _selectedRegion;
  String? _selectedPosition;
  String? _teamRegionGroup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeamAndPlayers();
    });
  }

  void _loadTeamAndPlayers() async {
    // 先加载战队信息获取大区
    await context.read<TeamProvider>().loadTeamById(widget.teamId);
    if (!mounted) return;
    final team = context.read<TeamProvider>().currentTeam;
    if (team != null) {
      setState(() {
        _teamRegionGroup = team.regionGroup;
      });
    }
    _loadPlayers();
  }

  void _loadPlayers() {
    // 默认使用战队的大区进行筛选，用户可以手动切换
    final regionToUse = _selectedRegion ?? _teamRegionGroup;
    context.read<PlayerProvider>().loadPlayers(
      region: regionToUse,
      position: _selectedPosition,
      teamless: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('招募选手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = provider.players;

          if (players.isEmpty) {
            return PremiumEmptyState(
              message: '暂无待招募的选手',
              icon: Icons.person_search,
              actionText: '刷新',
              onAction: _loadPlayers,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadPlayers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (context, index) {
                return _PlayerRecruitCard(
                  player: players[index],
                  teamId: widget.teamId,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(
        selectedRegion: _selectedRegion,
        selectedPosition: _selectedPosition,
        onApply: (region, position) {
          setState(() {
            _selectedRegion = region;
            _selectedPosition = position;
          });
          _loadPlayers();
        },
      ),
    );
  }
}

class _PlayerRecruitCard extends StatelessWidget {
  final PlayerModel player;
  final int teamId;

  const _PlayerRecruitCard({
    required this.player,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
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
      builder: (context) => AlertDialog(
        title: const Text('邀请加入战队'),
        content: Text('确定邀请 ${player.matchName} 加入您的战队吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<TeamProvider>().invitePlayer(teamId, player.id);
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

class _FilterSheet extends StatefulWidget {
  final String? selectedRegion;
  final String? selectedPosition;
  final Function(String?, String?) onApply;

  const _FilterSheet({
    this.selectedRegion,
    this.selectedPosition,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _region;
  String? _position;

  @override
  void initState() {
    super.initState();
    _region = widget.selectedRegion;
    _position = widget.selectedPosition;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '筛选选手',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _region = null;
                      _position = null;
                    });
                  },
                  child: const Text('重置'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _region,
              decoration: const InputDecoration(
                labelText: '服务器',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                ...RegionData.allSmallRegions.map((region) {
                  return DropdownMenuItem(
                    value: region['id'],
                    child: Text('${region['name']!} (${region['group']!})'),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _region = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _position,
              decoration: const InputDecoration(
                labelText: '位置',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                ...AppConstants.positions.map((pos) {
                  return DropdownMenuItem(value: pos, child: Text(pos));
                }),
              ],
              onChanged: (value) => setState(() => _position = value),
            ),
            const SizedBox(height: 24),
            NeonButton(
              text: '应用筛选',
              onPressed: () {
                widget.onApply(_region, _position);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
