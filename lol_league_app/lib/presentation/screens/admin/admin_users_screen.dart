import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiClient _client = ApiClient();
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _client.get('/users');
      if (!mounted) return;
      if (response.success && response.listData != null) {
        _users = response.listData!.map((json) => UserModel.fromJson(json)).toList();
      } else {
        _error = response.message;
      }
    } catch (e) {
      if (!mounted) return;
      _error = '加载用户列表失败';
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _confirmDeleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1642),
        title: const Text('确认删除', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '确定要删除用户 "${user.username}" 吗？该操作不可恢复。',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _client.delete('/users/${user.id}');
      if (response.success) {
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('用户 "${user.username}" 已删除'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除用户失败'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleAdmin(UserModel user) async {
    try {
      final response = await _client.put('/users/${user.id}/admin', data: {
        'isAdmin': !user.isAdmin,
      });

      if (response.success) {
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.username} 已${user.isAdmin ? '取消' : '设为'}管理员'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('操作失败'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户管理'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return EmptyState(
        message: _error!,
        icon: Icons.error_outline,
        actionText: '重试',
        onAction: _loadUsers,
      );
    }

    if (_users.isEmpty) {
      return const EmptyState(message: '暂无用户', icon: Icons.people);
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user.isAdmin ? Colors.orange : Colors.grey,
                child: Text(
                  user.username.isNotEmpty ? user.username.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Row(
                children: [
                  Text(user.username),
                  if (user.isAdmin) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('管理员', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ],
              ),
              subtitle: Text('ID: ${user.id}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: user.isAdmin,
                    onChanged: (_) => _toggleAdmin(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.neonRed),
                    onPressed: () => _confirmDeleteUser(user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
