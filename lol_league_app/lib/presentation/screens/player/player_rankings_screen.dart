import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../widgets/common_widgets.dart';

class PlayerRankingsScreen extends StatefulWidget {
  const PlayerRankingsScreen({super.key});

  @override
  State<PlayerRankingsScreen> createState() => _PlayerRankingsScreenState();
}

class _PlayerRankingsScreenState extends State<PlayerRankingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    final provider = context.read<PlayerProvider>();
    provider.loadWinRateRanking();
    provider.loadKdaRanking();
    provider.loadMvpRanking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选手排行榜'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '胜率榜'),
            Tab(text: 'KDA榜'),
            Tab(text: 'MVP榜'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRankingList(
            (p) => p.winRateRanking,
            (v) => '${v}%',
          ),
          _buildRankingList(
            (p) => p.kdaRanking,
            (v) => v.toStringAsFixed(2),
          ),
          _buildRankingList(
            (p) => p.mvpRanking,
            (v) => '$v 次',
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(List<dynamic> Function(PlayerProvider) getList, String Function(dynamic) formatValue) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = getList(provider);
        if (list.isEmpty) {
          return const EmptyState(message: '暂无数据', icon: Icons.leaderboard);
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: RankCard(
                  rank: index + 1,
                  name: item.name,
                  value: formatValue(item.value),
                  subtitle: item.matchName ?? null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
