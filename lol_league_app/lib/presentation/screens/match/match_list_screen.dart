import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/match_provider.dart';
import '../../widgets/common_widgets.dart';

class MatchListScreen extends StatefulWidget {
  const MatchListScreen({super.key});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  void _loadMatches() {
    context.read<MatchProvider>().loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('约战列表'),
      ),
      body: Consumer<MatchProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.matches.isEmpty) {
            return EmptyState(
              message: '暂无约战',
              icon: Icons.sports_esports,
              actionText: '发布约战',
              onAction: () => context.push('/match/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadMatches(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.matches.length,
              itemBuilder: (context, index) {
                final match = provider.matches[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      Icons.sports_esports,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text('${match.team?.name ?? "战队"} vs ${match.opponent?.name ?? "待定"}'),
                    subtitle: Text('${match.mode} · ${match.regionGroup ?? ""}'),
                    trailing: StatusBadge(status: match.status),
                    onTap: () => context.push('/match/detail/${match.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/match/create'),
        icon: const Icon(Icons.add),
        label: const Text('发布约战'),
      ),
    );
  }
}
