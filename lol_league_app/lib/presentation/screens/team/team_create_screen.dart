import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../data/models/team_model.dart';
import '../../widgets/common_widgets.dart';

class TeamCreateScreen extends StatefulWidget {
  const TeamCreateScreen({super.key});

  @override
  State<TeamCreateScreen> createState() => _TeamCreateScreenState();
}

class _TeamCreateScreenState extends State<TeamCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedRegion = '艾欧尼亚';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPlayerStatus();
    });
  }

  void _checkPlayerStatus() async {
    await context.read<PlayerProvider>().loadCurrentPlayer();
    if (mounted) {
      String defaultRegion = '艾欧尼亚';
      final player = context.read<PlayerProvider>().currentPlayer;
      debugPrint('_checkPlayerStatus: player=${player?.matchName}, regionGroup=${player?.regionGroup}, regionSmall=${player?.regionSmall}');
      if (player != null) {
        // 设置默认大区为选手所在大区
        String defaultRegionId;
        if (RegionData.isIndependentRegion(player.regionGroup)) {
          // 独立大区
          defaultRegionId = player.regionGroup;
          debugPrint('_checkPlayerStatus: 独立大区 $defaultRegionId');
        } else {
          // 合并大区
          defaultRegionId = '${player.regionGroup}-${player.regionSmall}';
          debugPrint('_checkPlayerStatus: 合并大区 $defaultRegionId');
        }
        // 检查默认值是否存在于列表中
        final exists = RegionData.allSmallRegions.any((r) => r['id'] == defaultRegionId);
        debugPrint('_checkPlayerStatus: defaultRegionId=$defaultRegionId exists=$exists');
        defaultRegion = exists ? defaultRegionId : '艾欧尼亚';
      }
      setState(() {
        _selectedRegion = defaultRegion;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    // 解析大区：如果是 "大区-小区" 格式，提取大区部分
    String regionGroup = _selectedRegion;
    String regionSmall = '';
    if (_selectedRegion.contains('-')) {
      final parts = _selectedRegion.split('-');
      regionGroup = parts[0];
      regionSmall = parts.sublist(1).join('-'); // 防止小区名本身包含-
    }

    final teamProvider = context.read<TeamProvider>();
    final team = TeamModel(
      name: _nameController.text.trim(),
      regionGroup: regionGroup,
      regionSmall: regionSmall,
      description: _descriptionController.text.trim(),
    );

    final success = await teamProvider.createTeam(team);

    if (success && mounted) {
      // 同步 PlayerProvider 和 AuthProvider 的 currentPlayer
      await context.read<PlayerProvider>().loadCurrentPlayer();
      if (mounted) {
        context.read<AuthProvider>().setCurrentPlayer(
          context.read<PlayerProvider>().currentPlayer,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('创建成功'), backgroundColor: Colors.green),
      );
      context.pop();
    } else if (mounted && teamProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(teamProvider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 检查玩家是否已有战队
    final currentPlayer = context.read<PlayerProvider>().currentPlayer;
    if (currentPlayer?.teamId != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('创建战队'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_off, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                '您已经在战队中',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '战队ID: ${currentPlayer!.teamId}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/team/detail/${currentPlayer.teamId}'),
                child: const Text('查看我的战队'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('创建战队'),
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, _) {
          return LoadingOverlay(
            isLoading: provider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: '战队名称',
                      hint: '请输入战队名称',
                      controller: _nameController,
                      validator: (v) => v == null || v.isEmpty ? '请输入战队名称' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      decoration: const InputDecoration(
                        labelText: '服务器',
                        border: OutlineInputBorder(),
                      ),
                      items: RegionData.allSmallRegions.map((region) {
                        return DropdownMenuItem(
                          value: region['id'],
                          child: Text('${region['name']!} (${region['group']!})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedRegion = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: '战队简介',
                      hint: '介绍一下您的战队...',
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: '创建战队',
                      onPressed: _create,
                      isLoading: provider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
