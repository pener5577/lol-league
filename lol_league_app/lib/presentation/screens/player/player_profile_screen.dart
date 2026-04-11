import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/player_provider.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/player/edit'),
          ),
        ],
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, provider, _) {
          final player = provider.currentPlayer;

          if (player == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('您还没有创建选手信息'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/player/edit'),
                    child: const Text('创建选手'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    player.matchName.isNotEmpty ? player.matchName.substring(0, 1) : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(player.matchName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('${player.regionGroup} · ${player.position}'),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow('游戏ID', player.gameId),
                        _buildInfoRow('大区', player.regionGroup),
                        _buildInfoRow('小区', player.regionSmall),
                        _buildInfoRow('位置', player.position),
                        _buildInfoRow('在线时段', player.onlineTime.isNotEmpty ? player.onlineTime : '未设置'),
                        _buildInfoRow('个人简介', player.bio.isNotEmpty ? player.bio : '未设置'),
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
                        const Text('战绩统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat('胜率', '${player.winRate}%'),
                            _buildStat('KDA', player.kdaDisplay),
                            _buildStat('MVP', '${player.mvpCount}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat('胜场', '${player.wins}'),
                            _buildStat('负场', '${player.losses}'),
                            _buildStat('连胜', '${player.winStreak}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat('击杀', '${player.kills}'),
                            _buildStat('死亡', '${player.deaths}'),
                            _buildStat('助攻', '${player.assists}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
