import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/match_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../data/models/match_model.dart';
import '../../widgets/common_widgets.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatch();
      context.read<TeamProvider>().loadTeams();
    });
  }

  void _loadMatch() {
    context.read<MatchProvider>().loadMatchById(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('约战详情'),
      ),
      body: Consumer<MatchProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final match = provider.currentMatch;
          if (match == null) {
            return const EmptyState(message: '约战不存在', icon: Icons.sports_esports);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMatchHeader(match),
                const SizedBox(height: 24),
                _buildMatchInfo(match),
                const SizedBox(height: 24),
                if (match.status == '待审核') _buildReviewInfo(match),
                if (match.isRejected) _buildRejectInfo(match),
                const SizedBox(height: 24),
                _buildActionButtons(context, match),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchHeader(MatchModel match) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          match.team?.name.isNotEmpty == true
                              ? match.team!.name.substring(0, 1)
                              : '?',
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.team?.name ?? '未知战队',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('发起方', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    StatusBadge(status: match.status),
                    const SizedBox(height: 8),
                    Text(match.mode, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[400],
                        child: Text(
                          match.opponent?.name.isNotEmpty == true
                              ? match.opponent!.name.substring(0, 1)
                              : '?',
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.opponent?.name ?? '待应战',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('应战方', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchInfo(MatchModel match) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('约战信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow('比赛时间', match.time != null
                ? '${match.time!.year}-${match.time!.month}-${match.time!.day} ${match.time!.hour}:${match.time!.minute.toString().padLeft(2, '0')}'
                : '待定'),
            _buildInfoRow('比赛模式', match.mode),
            _buildInfoRow('大区', match.regionGroup ?? '未知'),
            if (match.note.isNotEmpty) _buildInfoRow('备注', match.note),
            if (match.creatorUsername != null) _buildInfoRow('发起人', match.creatorUsername!),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewInfo(MatchModel match) {
    if (match.reviewedByUsername == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('审核信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildInfoRow('审核人', match.reviewedByUsername!),
            if (match.reviewedAt != null) _buildInfoRow(
              '审核时间',
              '${match.reviewedAt!.year}-${match.reviewedAt!.month}-${match.reviewedAt!.day}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectInfo(MatchModel match) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.close, color: Colors.red),
                SizedBox(width: 8),
                Text('驳回原因', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const Divider(),
            Text(match.rejectReason.isNotEmpty ? match.rejectReason : '未说明'),
          ],
        ),
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

  Widget _buildActionButtons(BuildContext context, MatchModel match) {
    final authProvider = context.read<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    final isCreator = authProvider.user?.id == match.createdBy;

    if (isAdmin && match.isPending) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: '通过',
              color: Colors.green,
              onPressed: () => _reviewMatch('approve'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: '驳回',
              color: Colors.red,
              isOutlined: true,
              onPressed: () => _showRejectDialog(),
            ),
          ),
        ],
      );
    }

    if (isCreator && match.isPending) {
      return AppButton(
        text: '取消约战',
        color: Colors.red,
        isOutlined: true,
        onPressed: () => _cancelMatch(),
      );
    }

    if (match.isWaitingOpponent) {
      return AppButton(
        text: '应战',
        onPressed: () => _showAcceptDialog(),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _reviewMatch(String action) async {
    final success = await context.read<MatchProvider>().reviewMatch(
      widget.matchId,
      MatchReviewRequest(action: action),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action == 'approve' ? '已通过' : '已驳回'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('驳回原因'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: '请输入驳回原因',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<MatchProvider>().reviewMatch(
                widget.matchId,
                MatchReviewRequest(action: 'reject', rejectReason: reasonController.text),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已驳回'), backgroundColor: Colors.orange),
                );
              }
            },
            child: const Text('确认驳回'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelMatch() async {
    final success = await context.read<MatchProvider>().cancelMatch(widget.matchId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已取消'), backgroundColor: Colors.orange),
      );
      context.pop();
    }
  }

  void _showAcceptDialog() {
    final teamProvider = context.read<TeamProvider>();
    final teams = teamProvider.teams;

    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('您还没有加入任何战队'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择应战战队'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(team.name.isNotEmpty ? team.name.substring(0, 1) : '?'),
                ),
                title: Text(team.name),
                subtitle: Text('${team.regionGroup} · ${team.wins}胜 ${team.losses}负'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await context.read<MatchProvider>().acceptMatch(
                    widget.matchId,
                    team.id,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('应战成功'), backgroundColor: Colors.green),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
