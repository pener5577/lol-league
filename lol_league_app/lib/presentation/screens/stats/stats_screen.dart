import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/stats_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('平台统计'),
      ),
      body: Consumer<StatsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.overview;
          if (stats == null) {
            return const Center(child: Text('暂无统计数据'));
          }

          return RefreshIndicator(
            onRefresh: () async => provider.loadOverview(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatCard(
                    '选手统计',
                    Icons.person,
                    [
                      _buildStatRow('总选手数', '${stats.players}'),
                      _buildStatRow('总击杀', '${stats.totalKills}'),
                      _buildStatRow('总助攻', '${stats.totalAssists}'),
                      _buildStatRow('MVP次数', '${stats.totalMVP}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    '战队统计',
                    Icons.group,
                    [
                      _buildStatRow('总战队数', '${stats.teams}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    '比赛统计',
                    Icons.sports_esports,
                    [
                      _buildStatRow('总比赛数', '${stats.totalMatches}'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
