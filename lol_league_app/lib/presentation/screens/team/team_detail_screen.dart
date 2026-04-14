import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class TeamDetailScreen extends StatefulWidget {
  final int teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeam();
    });
  }

  void _loadTeam() async {
    if (!mounted) return;

    await context.read<PlayerProvider>().loadCurrentPlayer();
    if (!mounted) return;

    final player = context.read<PlayerProvider>().currentPlayer;
    if (player != null) {
      context.read<AuthProvider>().setCurrentPlayer(player);
    }

    await context.read<TeamProvider>().loadTeamById(widget.teamId);
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          '战队详情',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer<TeamProvider>(
            builder: (context, provider, _) {
              final team = provider.currentTeam;
              if (team == null) return const SizedBox();
              final currentPlayerId = context.read<AuthProvider>().currentPlayer?.id;
              final isCaptain = currentPlayerId == team.captainId;
              if (!isCaptain) return const SizedBox();
              return PopupMenuButton<String>(
                color: AppColors.backgroundCard,
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, team);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit, color: AppColors.neonBlue, size: 18),
                      SizedBox(width: 8),
                      Text('修改战队信息', style: TextStyle(color: AppColors.textPrimary)),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_forever, color: AppColors.neonRed, size: 18),
                      SizedBox(width: 8),
                      Text('解散战队', style: TextStyle(color: AppColors.neonRed)),
                    ]),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _isInitialLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.neonBlue),
                  const SizedBox(height: 16),
                  const Text('加载战队信息...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : Consumer<TeamProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator(color: AppColors.neonBlue));
                }

                final team = provider.currentTeam;
                if (team == null) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_off, size: 64, color: AppColors.textMuted),
                        SizedBox(height: 16),
                        Text('战队不存在', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return CyberBackground(
                  child: RefreshIndicator(
                    onRefresh: () async => _loadTeam(),
                    color: AppColors.neonBlue,
                    backgroundColor: AppColors.backgroundCard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTeamHeader(team),
                          const SizedBox(height: 20),
                          _buildTeamStats(team),
                          const SizedBox(height: 20),
                          _buildTeamInfo(team),
                          const SizedBox(height: 20),
                          _buildMembersList(context, team),
                          const SizedBox(height: 24),
                          _buildActionButtons(context, team.captainId),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTeamHeader(team) {
    final regionText = RegionData.isIndependentRegion(team.regionGroup)
        ? team.regionGroup
        : '${team.regionGroup}-${team.regionSmall}';

    return GlassCard(
      hasGlow: true,
      glowColor: AppColors.neonGold,
      borderColor: AppColors.neonGold.withOpacity(0.25),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 战队LOGO
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppConstants.goldGradient,
              shape: BoxShape.circle,
              boxShadow: AppConstants.neonGlow(AppColors.neonGold, 20),
            ),
            child: Center(
              child: Text(
                team.name.isNotEmpty ? team.name.substring(0, 1) : '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 战队名称
          Text(
            team.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // 大区信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonBlue.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonBlue.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.neonBlue),
                const SizedBox(width: 6),
                Text(
                  regionText,
                  style: const TextStyle(color: AppColors.neonBlue, fontSize: 13),
                ),
              ],
            ),
          ),
          if (team.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              team.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamStats(team) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('积分', '${team.score}', Icons.emoji_events, AppColors.neonGold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('胜场', '${team.wins}', Icons.check_circle, AppColors.neonGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('负场', '${team.losses}', Icons.cancel, AppColors.neonRed),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('连胜', '${team.winStreak}', Icons.local_fire_department, AppColors.neonOrange),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      hasGlow: false,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(team) {
    final regionText = RegionData.isIndependentRegion(team.regionGroup)
        ? team.regionGroup
        : '${team.regionGroup}-${team.regionSmall}';

    return GlassCard(
      hasGlow: false,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonBlue.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline, color: AppColors.neonBlue, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  '战队信息',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _buildInfoRow('队长', team.captain?.matchName ?? '未知', Icons.military_tech, AppColors.neonGold),
          const Divider(height: 1, color: AppColors.borderDefault, indent: 16, endIndent: 16),
          _buildInfoRow('大区', regionText, Icons.location_on, AppColors.neonBlue),
          const Divider(height: 1, color: AppColors.borderDefault, indent: 16, endIndent: 16),
          _buildInfoRow('等级', team.level.isNotEmpty ? team.level : '普通', Icons.star, AppColors.neonPurple),
          const Divider(height: 1, color: AppColors.borderDefault, indent: 16, endIndent: 16),
          _buildInfoRow('胜率', team.wins + team.losses > 0
              ? '${(team.wins / (team.wins + team.losses) * 100).toStringAsFixed(1)}%'
              : '0%',
              Icons.percent, AppColors.neonGreen),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, team) {
    final currentPlayerId = context.read<AuthProvider>().currentPlayer?.id;
    final isCurrentCaptain = currentPlayerId == team.captainId;

    return GlassCard(
      hasGlow: false,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people, color: AppColors.neonPurple, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  '成员 (${team.members.length}/5)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          if (team.members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.person_off, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('暂无成员', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          else
            ...team.members.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              final isCaptain = member.id == team.captainId;

              return Column(
                children: [
                  if (index > 0) const Divider(height: 1, color: AppColors.borderDefault, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // 头像
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: isCaptain ? AppConstants.goldGradient : AppConstants.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppConstants.neonGlow(isCaptain ? AppColors.neonGold : AppColors.neonBlue, 10),
                          ),
                          child: Center(
                            child: Text(
                              member.matchName.isNotEmpty ? member.matchName.substring(0, 1) : '?',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    member.matchName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (isCaptain) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.neonGold.withAlpha(40),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.neonGold.withAlpha(120)),
                                      ),
                                      child: const Text(
                                        '队长',
                                        style: TextStyle(color: AppColors.neonGold, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildMiniChip(member.position, AppColors.neonPurple),
                                  const SizedBox(width: 6),
                                  _buildMiniChip('胜率${member.winRate}%', AppColors.neonGreen),
                                  const SizedBox(width: 6),
                                  _buildMiniChip('KDA ${member.kdaDisplay}', AppColors.neonBlue),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 踢出按钮（队长才显示）
                        if (isCurrentCaptain && !isCaptain)
                          GestureDetector(
                            onTap: () => _showKickDialog(context, member),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.neonRed.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.neonRed.withAlpha(60)),
                              ),
                              child: const Icon(Icons.remove_circle_outline, color: AppColors.neonRed, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, int? captainId) {
    final authProvider = context.read<AuthProvider>();
    final isCaptain = authProvider.currentPlayer?.id == captainId;
    final hasTeam = authProvider.currentPlayer?.teamId != null;

    if (isCaptain) {
      return Row(
        children: [
          Expanded(
            child: NeonButton(
              text: '发布约战',
              icon: Icons.sports_esports,
              onPressed: () => context.push('/match/create'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NeonButton(
              text: '招募成员',
              isOutlined: true,
              color: AppColors.neonGold,
              icon: Icons.person_add,
              onPressed: () => context.push('/team/recruit/${widget.teamId}'),
            ),
          ),
        ],
      );
    }

    if (hasTeam && authProvider.currentPlayer?.teamId != widget.teamId) {
      return const Center(
        child: Text('您已在其他战队', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    if (hasTeam && authProvider.currentPlayer?.teamId == widget.teamId) {
      return NeonButton(
        text: '退出当前战队',
        isOutlined: true,
        color: AppColors.neonRed,
        icon: Icons.exit_to_app,
        onPressed: () => _showLeaveDialog(context),
      );
    }

    return NeonButton(
      text: '申请加入战队',
      icon: Icons.group_add,
      onPressed: () async {
        final success = await context.read<TeamProvider>().joinTeam(widget.teamId);
        if (success && context.mounted) {
          await context.read<PlayerProvider>().loadCurrentPlayer();
          if (context.mounted) {
            context.read<AuthProvider>().setCurrentPlayer(
              context.read<PlayerProvider>().currentPlayer,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('申请成功，请等待队长审核'), backgroundColor: Colors.green),
            );
          }
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<TeamProvider>().error ?? '申请失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showEditDialog(BuildContext context, team) {
    final nameController = TextEditingController(text: team.name);
    final descController = TextEditingController(text: team.description);

    String defaultRegionId = '艾欧尼亚';
    if (team.regionGroup is String) {
      final regionGroup = team.regionGroup as String;
      if (RegionData.isIndependentRegion(regionGroup)) {
        defaultRegionId = regionGroup;
      } else {
        final smallRegion = team.regionSmall?.toString() ?? '';
        defaultRegionId = '$regionGroup-$smallRegion';
      }
    }

    final exists = RegionData.allSmallRegions.any((r) => r['id'] == defaultRegionId);
    String selectedRegion = exists ? defaultRegionId : '艾欧尼亚';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: const Text('修改战队信息', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '战队名称',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  dropdownColor: AppColors.backgroundCard,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '服务器',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                  ),
                  items: RegionData.allSmallRegions.map((region) {
                    return DropdownMenuItem(
                      value: region['id'],
                      child: Text('${region['name']} (${region['group']})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedRegion = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '战队简介',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonBlue),
              onPressed: () async {
                Navigator.pop(ctx);
                String regionGroup;
                String regionSmall;
                if (selectedRegion.contains('-')) {
                  final parts = selectedRegion.split('-');
                  regionGroup = parts[0];
                  regionSmall = parts.sublist(1).join('-');
                } else {
                  regionGroup = selectedRegion;
                  regionSmall = '';
                }
                final success = await context.read<TeamProvider>().updateTeam(
                  widget.teamId,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  regionGroup: regionGroup,
                  regionSmall: regionSmall,
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('战队信息已更新'), backgroundColor: Colors.green),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.read<TeamProvider>().error ?? '更新失败'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('解散战队', style: TextStyle(color: AppColors.neonRed)),
        content: const Text('确定要解散战队吗？此操作不可恢复！', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<TeamProvider>().deleteTeam(widget.teamId);
              if (success && context.mounted) {
                await context.read<PlayerProvider>().loadCurrentPlayer();
                if (context.mounted) {
                  context.read<AuthProvider>().setCurrentPlayer(
                    context.read<PlayerProvider>().currentPlayer,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('战队已解散'), backgroundColor: Colors.green),
                  );
                  context.pop();
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<TeamProvider>().error ?? '解散失败'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('确认解散'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('退出战队', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('确定要退出当前战队吗？', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<TeamProvider>().leaveTeam(widget.teamId);
              if (success && context.mounted) {
                await context.read<PlayerProvider>().loadCurrentPlayer();
                if (context.mounted) {
                  context.read<AuthProvider>().setCurrentPlayer(
                    context.read<PlayerProvider>().currentPlayer,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已退出战队'), backgroundColor: Colors.green),
                  );
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<TeamProvider>().error ?? '退出失败'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
  }

  void _showKickDialog(BuildContext context, member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('移除队员', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('确定要将 ${member.matchName} 从战队中移除吗？', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<TeamProvider>().kickTeamMember(widget.teamId, member.id);
              if (success && context.mounted) {
                await context.read<PlayerProvider>().loadCurrentPlayer();
                if (context.mounted) {
                  context.read<AuthProvider>().setCurrentPlayer(
                    context.read<PlayerProvider>().currentPlayer,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已将 ${member.matchName} 移除'), backgroundColor: Colors.green),
                  );
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<TeamProvider>().error ?? '移除失败'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
  }
}
