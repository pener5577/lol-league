import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/match_provider.dart';
import '../../../data/models/match_model.dart';
import '../../widgets/common_widgets.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  void _loadMatches() {
    context.read<MatchProvider>().loadMatches(status: '待审核');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('审核管理'),
      ),
      body: Consumer<MatchProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingMatches = provider.pendingMatches;

          if (pendingMatches.isEmpty) {
            return const EmptyState(
              message: '暂无待审核的约战',
              icon: Icons.check_circle_outline,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadMatches(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingMatches.length,
              itemBuilder: (context, index) {
                final match = pendingMatches[index];
                return _buildMatchCard(match);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.team?.name ?? '未知战队',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const Text('VS'),
                Expanded(
                  child: Text(
                    '待应战',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('模式: ${match.mode}'),
                    if (match.time != null)
                      Text('时间: ${match.time!.month}/${match.time!.day} ${match.time!.hour}:${match.time!.minute.toString().padLeft(2, '0')}'),
                    if (match.creatorUsername != null)
                      Text('发起人: ${match.creatorUsername}'),
                  ],
                ),
                StatusBadge(status: match.status),
              ],
            ),
            if (match.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('备注: ${match.note}', style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: '通过',
                    color: Colors.green,
                    onPressed: () => _reviewMatch(match.id, 'approve'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: '驳回',
                    color: Colors.red,
                    isOutlined: true,
                    onPressed: () => _showRejectDialog(match.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reviewMatch(int matchId, String action) async {
    final success = await context.read<MatchProvider>().reviewMatch(
      matchId,
      MatchReviewRequest(action: action),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action == 'approve' ? '已通过' : '已驳回'),
          backgroundColor: action == 'approve' ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  void _showRejectDialog(int matchId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('驳回约战'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '驳回原因',
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
              await _reviewMatch(matchId, 'reject');
            },
            child: const Text('确认驳回'),
          ),
        ],
      ),
    );
  }
}
