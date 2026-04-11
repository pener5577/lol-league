import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../data/models/player_model.dart';
import '../../widgets/common_widgets.dart';

class PlayerEditScreen extends StatefulWidget {
  const PlayerEditScreen({super.key});

  @override
  State<PlayerEditScreen> createState() => _PlayerEditScreenState();
}

class _PlayerEditScreenState extends State<PlayerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matchNameController = TextEditingController();
  final _gameIdController = TextEditingController();
  final _onlineTimeController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedRegion = '艾欧尼亚';
  String _selectedSmallRegion = '';
  String _selectedPosition = '全能';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentPlayer();
    });
  }

  // 位置名称映射（英文到中文）
  static const Map<String, String> _positionMap = {
    'top': '上单',
    'jungle': '打野',
    'mid': '中单',
    'adc': 'ADC',
    'support': '辅助',
    'fill': '全能',
  };

  String _mapPositionToChinese(String? englishPosition) {
    if (englishPosition == null) return '全能';
    return _positionMap[englishPosition.toLowerCase()] ?? '全能';
  }

  void _loadCurrentPlayer() async {
    if (!mounted) return;
    final provider = context.read<PlayerProvider>();
    await provider.loadCurrentPlayer();
    if (!mounted) return;
    final player = provider.currentPlayer;
    if (player != null) {
      // 解析当前大区/小区
      String region = player.regionGroup ?? '';
      String smallRegion = player.regionSmall ?? '';

      // 兼容处理：如果 region 包含 "MapEntry" 或格式不对，尝试修复
      if (region.contains('MapEntry') || region.contains('-')) {
        // 尝试找 "大区-小区" 格式的位置
        final dashIndex = region.lastIndexOf('-');
        if (dashIndex > 0) {
          final possibleRegion = region.substring(0, dashIndex);
          final possibleSmall = region.substring(dashIndex + 1);
          // 检查是否是有效的大区
          if (RegionData.allGroups.contains(possibleRegion)) {
            region = possibleRegion;
            smallRegion = possibleSmall;
          }
        }
      }

      // 如果是独立大区
      if (RegionData.isIndependentRegion(region)) {
        smallRegion = '';
      } else {
        // 合并大区，检查smallRegion是否有效
        if (!RegionData.getSmallRegionsByGroup(region).contains(smallRegion)) {
          smallRegion = '';
        }
      }

      // 构建完整的dropdown ID
      String selectedRegionId;
      if (RegionData.isIndependentRegion(region)) {
        selectedRegionId = region;
      } else {
        selectedRegionId = smallRegion.isNotEmpty ? '$region-$smallRegion' : region;
      }
      // 检查这个ID是否存在于列表中
      final exists = RegionData.allSmallRegions.any((r) => r['id'] == selectedRegionId);
      if (!exists) {
        selectedRegionId = '艾欧尼亚'; // 默认值
      }

      // 映射位置到中文
      final chinesePosition = _mapPositionToChinese(player.position);
      final positionExists = AppConstants.positions.contains(chinesePosition);

      setState(() {
        _matchNameController.text = player.matchName;
        _gameIdController.text = player.gameId;
        _onlineTimeController.text = player.onlineTime;
        _bioController.text = player.bio;
        _selectedRegion = selectedRegionId;
        _selectedSmallRegion = smallRegion;
        _selectedPosition = positionExists ? chinesePosition : '全能';
      });
    }
  }

  @override
  void dispose() {
    _matchNameController.dispose();
    _gameIdController.dispose();
    _onlineTimeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // 获取当前选择的服务器名称（用于显示和存储）
  String _getServerName() {
    if (RegionData.isIndependentRegion(_selectedRegion)) {
      return _selectedRegion;
    } else {
      return _selectedSmallRegion;
    }
  }

  // 根据选择的小区获取大区名称
  String _getRegionGroupName() {
    if (RegionData.isIndependentRegion(_selectedRegion)) {
      // 独立大区，小区名就是大区名
      return _selectedRegion;
    } else {
      // 合并大区，返回大区名称
      return _selectedRegion;
    }
  }

  // 查找匹配的服务器ID（防止值不存在于dropdown中）
  String _findMatchingServerId() {
    // 计算当前ID
    String targetId;
    if (RegionData.isIndependentRegion(_selectedRegion)) {
      targetId = _selectedRegion;
    } else {
      targetId = '$_selectedRegion-$_selectedSmallRegion';
    }
    // 检查是否存在
    for (var region in RegionData.allSmallRegions) {
      if (region['id'] == targetId) {
        return targetId;
      }
    }
    // 如果不存在，返回第一个（独立大区的第一个）
    return RegionData.allSmallRegions.first['id'] ?? '艾欧尼亚';
  }

  // 获取当前大区（用于显示）
  String _getDisplayRegion() {
    if (RegionData.isIndependentRegion(_selectedRegion)) {
      return _selectedRegion;
    } else {
      return _selectedSmallRegion.isNotEmpty
          ? _selectedRegion
          : '请选择小区';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // 解析大区：如果是 "大区-小区" 格式，提取大区和小区
    String regionGroup;
    String regionSmall;
    if (_selectedRegion.contains('-')) {
      final parts = _selectedRegion.split('-');
      regionGroup = parts[0];
      regionSmall = parts.sublist(1).join('-'); // 防止小区名本身包含-
    } else {
      regionGroup = _selectedRegion;
      regionSmall = '';
    }

    final playerProvider = context.read<PlayerProvider>();
    final player = PlayerModel(
      matchName: _matchNameController.text.trim(),
      gameId: _gameIdController.text.trim(),
      regionGroup: regionGroup,
      regionSmall: regionSmall,
      position: _selectedPosition,
      onlineTime: _onlineTimeController.text.trim(),
      bio: _bioController.text.trim(),
    );

    final success = await playerProvider.savePlayer(player);

    if (success && mounted) {
      if (mounted) {
        context.read<AuthProvider>().setCurrentPlayer(playerProvider.currentPlayer);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功'), backgroundColor: Colors.green),
      );
      context.pop();
    } else if (mounted && playerProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(playerProvider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑选手资料'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Consumer<PlayerProvider>(
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
                      label: '游戏昵称（召唤师名称）',
                      hint: '请输入您的游戏昵称',
                      controller: _matchNameController,
                      validator: (v) => v == null || v.isEmpty ? '请输入游戏昵称' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: '游戏ID',
                      hint: '如: 峡谷之巅#001',
                      controller: _gameIdController,
                      validator: (v) => v == null || v.isEmpty ? '请输入游戏ID' : null,
                    ),
                    const SizedBox(height: 16),
                    // 小区选择
                    DropdownButtonFormField<String>(
                      value: _findMatchingServerId(),
                      decoration: const InputDecoration(
                        labelText: '小区',
                        border: OutlineInputBorder(),
                      ),
                      items: RegionData.allSmallRegions.map((region) {
                        return DropdownMenuItem(
                          value: region['id'],
                          child: Text('${region['name']} (${region['group']})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          // 查找完整的小区信息
                          for (var region in RegionData.allSmallRegions) {
                            if (region['id'] == value) {
                              _selectedRegion = region['group'] ?? '';
                              _selectedSmallRegion = region['name'] ?? '';
                              return;
                            }
                          }
                          // 兼容处理：格式可能是 "独立大区名" 或 "大区-小区"
                          if (value.contains('-')) {
                            final parts = value.split('-');
                            if (parts.length >= 2) {
                              _selectedRegion = parts[0].trim();
                              _selectedSmallRegion = parts.sublist(1).join('-').trim();
                              return;
                            }
                          }
                          // 独立大区
                          _selectedRegion = value;
                          _selectedSmallRegion = '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // 大区显示（根据选择的小区自动显示）
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '大区',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _getRegionGroupName(),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      decoration: const InputDecoration(
                        labelText: '位置',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.positions.map((pos) {
                        return DropdownMenuItem(value: pos, child: Text(pos));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPosition = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: '在线时段',
                      hint: '如: 每天晚上8点后',
                      controller: _onlineTimeController,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: '个人简介',
                      hint: '介绍一下自己...',
                      controller: _bioController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: '保存',
                      onPressed: _save,
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
