import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/match_provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../data/models/match_model.dart';
import '../../widgets/common_widgets.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedMatchId;
  int? _winnerTeamId;
  int? _loserTeamId;
  int _winnerScore = 0;
  int _loserScore = 0;
  String _screenshot = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadMatches();
      context.read<TeamProvider>().loadTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据录入'),
      ),
      body: Consumer2<MatchProvider, TeamProvider>(
        builder: (context, matchProvider, teamProvider, _) {
          if (matchProvider.isLoading || teamProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 筛选出已约战但还未录入战绩的约战
          final availableMatches = matchProvider.matches
              .where((m) => m.status == '已约战')
              .toList();

          if (availableMatches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_esports, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无待录入的约战',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '请先发起约战并完成应战',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/match/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('发起约战'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 选择约战
                  GlassCard(
                    hasGlow: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '选择约战',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: _selectedMatchId,
                          decoration: const InputDecoration(
                            labelText: '约战',
                            prefixIcon: Icon(Icons.sports_esports),
                          ),
                          items: availableMatches.map((match) {
                            return DropdownMenuItem(
                              value: match.id,
                              child: Text(
                                '${match.team?.name ?? "战队"} vs ${match.opponent?.name ?? "待定"}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMatchId = value;
                              // 重置选择
                              _winnerTeamId = null;
                              _loserTeamId = null;
                              _winnerScore = 0;
                              _loserScore = 0;
                            });
                          },
                          validator: (value) => value == null ? '请选择约战' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_selectedMatchId != null) ...[
                    // 选择胜负
                    GlassCard(
                      hasGlow: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '录入结果',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: _winnerTeamId,
                            decoration: const InputDecoration(
                              labelText: '获胜战队',
                              prefixIcon: Icon(Icons.emoji_events, color: AppColors.neonGold),
                            ),
                            items: teamProvider.teams.map((team) {
                              return DropdownMenuItem(
                                value: team.id,
                                child: Text(team.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _winnerTeamId = value;
                                // 失败方自动设置为对手
                                final match = availableMatches.firstWhere((m) => m.id == _selectedMatchId);
                                if (value == match.team?.id) {
                                  _loserTeamId = match.opponentId;
                                } else {
                                  _loserTeamId = match.team?.id;
                                }
                              });
                            },
                            validator: (value) => value == null ? '请选择获胜战队' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _winnerScore.toString(),
                                  decoration: const InputDecoration(
                                    labelText: '获胜方得分',
                                    prefixIcon: Icon(Icons.score),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _winnerScore = int.tryParse(value) ?? 0;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return '请输入得分';
                                    final score = int.tryParse(value);
                                    if (score == null || score < 0) return '请输入有效分数';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.close, color: AppColors.textMuted),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _loserScore.toString(),
                                  decoration: const InputDecoration(
                                    labelText: '失败方得分',
                                    prefixIcon: Icon(Icons.score),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _loserScore = int.tryParse(value) ?? 0;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return '请输入得分';
                                    final score = int.tryParse(value);
                                    if (score == null || score < 0) return '请输入有效分数';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 战绩截图（可选）
                    GlassCard(
                      hasGlow: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '战绩截图（可选）',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: '截图URL',
                              prefixIcon: Icon(Icons.image),
                              hintText: '输入截图链接',
                            ),
                            onChanged: (value) {
                              _screenshot = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 提交按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitResult,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('提交战绩'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitResult() async {
    if (!_formKey.currentState!.validate()) return;
    if (_winnerTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择获胜战队'), backgroundColor: Colors.red),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认提交'),
        content: const Text('确定要提交这条战绩记录吗？提交后将更新战队和选手的排行榜数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final matchProvider = context.read<MatchProvider>();
    final success = await matchProvider.submitResult(
      _selectedMatchId!,
      MatchResultRequest(
        winnerId: _winnerTeamId!,
        loserId: _loserTeamId!,
        playerStats: [],
      ),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('战绩录入成功'), backgroundColor: Colors.green),
      );
      // 重置表单
      setState(() {
        _selectedMatchId = null;
        _winnerTeamId = null;
        _loserTeamId = null;
        _winnerScore = 0;
        _loserScore = 0;
        _screenshot = '';
      });
      // 重新加载约战列表
      context.read<MatchProvider>().loadMatches();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(matchProvider.error ?? '录入失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
