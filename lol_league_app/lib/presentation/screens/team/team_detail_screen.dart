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

    // 先确保加载了当前选手信息
    await context.read<PlayerProvider>().loadCurrentPlayer();
    if (!mounted) return;

    // 同步 AuthProvider 的 currentPlayer
    final player = context.read<PlayerProvider>().currentPlayer;
    if (player != null) {
      context.read<AuthProvider>().setCurrentPlayer(player);
    }

    // 加载战队详情
    await context.read<TeamProvider>().loadTeamById(widget.teamId);
    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 初始加载时显示加载画面
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('战队详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('战队详情'),
        actions: [
          Consumer<TeamProvider>(
            builder: (context, provider, _) {
              final team = provider.currentTeam;
              if (team == null) return const SizedBox();
              final currentPlayerId = context.read<AuthProvider>().currentPlayer?.id;
              final isCaptain = currentPlayerId == team.captainId;
              if (!isCaptain) return const SizedBox();
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, team);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('修改战队信息')),
                  const PopupMenuItem(value: 'delete', child: Text('解散战队', style: TextStyle(color: Colors.red))),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final team = provider.currentTeam;
          if (team == null) {
            return const EmptyState(message: '战队不存在', icon: Icons.group_off);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      team.name.isNotEmpty ? team.name.substring(0, 1) : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    team.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    RegionData.isIndependentRegion(team.regionGroup)
                        ? team.regionGroup
                        : '${team.regionGroup}-${team.regionSmall}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('战队信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        _buildInfoRow('队长', team.captain?.matchName ?? '未知'),
                        _buildInfoRow('大区', RegionData.isIndependentRegion(team.regionGroup)
                            ? team.regionGroup
                            : '${team.regionGroup}-${team.regionSmall}'),
                        _buildInfoRow('等级', team.level.isNotEmpty ? team.level : '普通'),
                        _buildInfoRow('积分', '${team.score}'),
                        _buildInfoRow('战绩', '${team.wins}胜 ${team.losses}负'),
                        _buildInfoRow('连胜', '${team.winStreak}'),
                        if (team.description.isNotEmpty) ...[
                          const Divider(),
                          _buildInfoRow('简介', team.description),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '成员 (${team.members.length})',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        if (team.members.isEmpty)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('暂无成员'),
                          ))
                        else
                          ...team.members.map((member) {
                            final isCaptain = member.id == team.captainId;
                            final currentPlayerId = context.read<AuthProvider>().currentPlayer?.id;
                            final isCurrentCaptain = currentPlayerId == team.captainId;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(child: Text(member.matchName.isNotEmpty ? member.matchName.substring(0, 1) : '?')),
                              title: Row(
                                children: [
                                  Text(member.matchName),
                                  if (isCaptain) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.neonGold.withAlpha(50),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.neonGold.withAlpha(128)),
                                      ),
                                      child: const Text(
                                        '队长',
                                        style: TextStyle(color: AppColors.neonGold, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(member.position),
                              trailing: isCurrentCaptain && !isCaptain
                                  ? IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.neonRed),
                                      onPressed: () => _showKickDialog(context, member),
                                    )
                                  : null,
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionButtons(context, team.captainId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
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
            child: AppButton(
              text: '发布约战',
              onPressed: () => context.push('/match/create'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: '招募成员',
              isOutlined: true,
              color: AppColors.neonGold,
              onPressed: () => context.push('/team/recruit/${widget.teamId}'),
            ),
          ),
        ],
      );
    }

    // 如果用户在其他战队（查看的战队不是自己的战队）
    if (hasTeam && authProvider.currentPlayer?.teamId != widget.teamId) {
      return const Center(
        child: Text('您已在其他战队', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    // 如果用户在自己的战队（且不是队长）
    if (hasTeam && authProvider.currentPlayer?.teamId == widget.teamId) {
      return Center(
        child: OutlinedButton(
          onPressed: () => _showLeaveDialog(context),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.neonRed),
          child: const Text('退出当前战队'),
        ),
      );
    }

    return AppButton(
      text: '申请加入',
      onPressed: () async {
        final success = await context.read<TeamProvider>().joinTeam(widget.teamId);
        if (success && context.mounted) {
          await context.read<PlayerProvider>().loadCurrentPlayer();
          if (context.mounted) {
            context.read<AuthProvider>().setCurrentPlayer(
              context.read<PlayerProvider>().currentPlayer,
            );
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('申请成功'), backgroundColor: Colors.green),
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

    // 设置默认大区值
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

    // 检查默认值是否存在
    final exists = RegionData.allSmallRegions.any((r) => r['id'] == defaultRegionId);
    String selectedRegion = exists ? defaultRegionId : '艾欧尼亚';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('修改战队信息'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '战队名称'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  decoration: const InputDecoration(
                    labelText: '服务器',
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
                  decoration: const InputDecoration(labelText: '战队简介'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);

                // 解析大区
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
        title: const Text('解散战队'),
        content: const Text('确定要解散战队吗？此操作不可恢复！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<TeamProvider>().deleteTeam(widget.teamId);
              if (success && context.mounted) {
                await context.read<PlayerProvider>().loadCurrentPlayer();
                if (context.mounted) {
                  context.read<AuthProvider>().setCurrentPlayer(
                    context.read<PlayerProvider>().currentPlayer,
                  );
                }
                if (context.mounted) {
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
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
        title: const Text('退出战队'),
        content: const Text('确定要退出当前战队吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<TeamProvider>().leaveTeam(widget.teamId);
              if (success && context.mounted) {
                await context.read<PlayerProvider>().loadCurrentPlayer();
                if (context.mounted) {
                  context.read<AuthProvider>().setCurrentPlayer(
                    context.read<PlayerProvider>().currentPlayer,
                  );
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已退出战队'), backgroundColor: Colors.green),
                  );
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.read<TeamProvider>().error ?? '退出失败'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
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
        title: const Text('移除队员'),
        content: Text('确定要将 ${member.matchName} 从战队中移除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<TeamProvider>().kickTeamMember(widget.teamId, member.id);
              if (success && context.mounted) {
                await context.read<PlayerProvider>().loadCurrentPlayer();
                if (context.mounted) {
                  context.read<AuthProvider>().setCurrentPlayer(
                    context.read<PlayerProvider>().currentPlayer,
                  );
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已将 ${member.matchName} 移除'), backgroundColor: Colors.green),
                  );
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.read<TeamProvider>().error ?? '移除失败'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
  }
}
