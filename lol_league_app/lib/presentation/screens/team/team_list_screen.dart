import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  bool _isInitialLoading = true;
  bool _hasTeam = false;
  int? _myTeamId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndCheckTeam();
    });
  }

  void _loadAndCheckTeam() async {
    if (!mounted) return;

    // 先加载当前选手信息
    await context.read<PlayerProvider>().loadCurrentPlayer();
    if (!mounted) return;

    final currentPlayer = context.read<PlayerProvider>().currentPlayer;
    _hasTeam = currentPlayer?.teamId != null;
    _myTeamId = currentPlayer?.teamId;

    // 更新 AuthProvider
    if (currentPlayer != null) {
      context.read<AuthProvider>().setCurrentPlayer(currentPlayer);
    }

    // 如果用户有战队，直接跳转到自己的战队详情页
    if (_hasTeam && _myTeamId != null && mounted) {
      context.push('/team/detail/$_myTeamId');
      return;
    }

    // 用户没有战队，不需要加载列表，直接显示没战队提示
    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('我的战队')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 如果用户有战队，已通过 push 跳转到详情页，不会渲染这个页面
    // 用户没有战队，显示提示
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的战队'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '您还没有战队',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/team/create'),
              icon: const Icon(Icons.add),
              label: const Text('创建战队'),
            ),
          ],
        ),
      ),
    );
  }
}
