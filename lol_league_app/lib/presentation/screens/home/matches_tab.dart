import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/match_provider.dart';
import '../../widgets/common_widgets.dart';

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  void _loadMatches() {
    context.read<MatchProvider>().loadMatches(region: _selectedRegion);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CyberBackground(
      child: SafeArea(
        child: Column(
          children: [
            // 标题
            _buildHeader(),
            // TabBar
            _buildTabBar(),
            // 筛选栏
            _buildFilterBar(),
            // 列表
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMatchList(null),
                  _buildMatchList('待审核'),
                  _buildMatchList('待应战'),
                  _buildMatchList('已约战'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppConstants.neonBlueGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppConstants.neonGlow(AppColors.neonBlue, 20),
            ),
            child: const Icon(
              Icons.sports_esports,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '约战大厅',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: AppConstants.neonBlueGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '待审核'),
          Tab(text: '待应战'),
          Tab(text: '已约战'),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('全部大区', null),
            const SizedBox(width: 10),
            _buildFilterChip('艾欧尼亚', '艾欧尼亚'),
            const SizedBox(width: 10),
            _buildFilterChip('比尔吉沃特', '比尔吉沃特'),
            const SizedBox(width: 10),
            _buildFilterChip('德玛西亚', '德玛西亚'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedRegion == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedRegion = value);
        _loadMatches();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonBlue.withOpacity(0.15)
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.neonBlue
                : AppColors.borderDefault,
          ),
          boxShadow: isSelected
              ? AppConstants.softGlow(AppColors.neonBlue)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.neonBlue
                : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchList(String? status) {
    return Consumer<MatchProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.neonBlue,
            ),
          );
        }

        var matches = provider.matches;
        if (status != null) {
          matches = matches.where((m) => m.status == status).toList();
        }

        if (matches.isEmpty) {
          return PremiumEmptyState(
            message: '暂无约战',
            icon: Icons.sports_esports,
            actionText: '发布约战',
            onAction: () => context.push('/match/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadMatches(),
          color: AppColors.neonBlue,
          backgroundColor: AppColors.backgroundCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return MatchCard(
                teamName: match.team?.name ?? '未知战队',
                opponentName: match.opponent?.name ?? '待应战',
                mode: match.mode ?? '5v5',
                time: _formatTime(match.time),
                status: match.status,
                onTap: () => context.push('/match/detail/${match.id}'),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '时间待定';
    return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
