import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: '账号',
            children: [
              _buildMenuItem(
                icon: Icons.person_outline,
                label: '账号信息',
                color: AppColors.neonBlue,
                onTap: () {
                  // 跳转到选手资料
                  context.push('/player/profile');
                },
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                label: '修改密码',
                color: AppColors.neonPurple,
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: '通用',
            children: [
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                label: '通知设置',
                color: AppColors.neonGreen,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通知设置功能开发中'), backgroundColor: Colors.orange),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.language,
                label: '语言',
                color: AppColors.neonGold,
                trailing: const Text(
                  '简体中文',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: '关于',
            children: [
              _buildMenuItem(
                icon: Icons.info_outline,
                label: '关于我们',
                color: AppColors.neonBlue,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              _buildMenuItem(
                icon: Icons.description_outlined,
                label: '用户协议',
                color: AppColors.textMuted,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('用户协议功能开发中'), backgroundColor: Colors.orange),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                label: '隐私政策',
                color: AppColors.textMuted,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('隐私政策功能开发中'), backgroundColor: Colors.orange),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.code,
                label: '版本',
                color: AppColors.textMuted,
                trailing: const Text(
                  '1.0.0',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1642).withAlpha(180),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            children: List.generate(children.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Divider(
                  height: 1,
                  indent: 56,
                  color: AppColors.borderDefault.withAlpha(128),
                );
              }
              return children[index ~/ 2];
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1642).withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1642),
              title: const Text('确认退出', style: TextStyle(color: AppColors.textPrimary)),
              content: const Text('确定要退出登录吗？', style: TextStyle(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<AuthProvider>().logout();
                    context.go('/login');
                  },
                  child: const Text('退出', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neonRed.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.logout, color: AppColors.neonRed, size: 20),
        ),
        title: const Text(
          '退出登录',
          style: TextStyle(color: AppColors.neonRed, fontSize: 15),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1642),
        title: const Text('修改密码', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: '原密码',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.neonBlue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: '新密码',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.neonBlue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: '确认新密码',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.neonBlue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现修改密码逻辑
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('修改密码功能开发中'), backgroundColor: Colors.orange),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1642),
        title: const Row(
          children: [
            Icon(Icons.sports_esports, color: AppColors.neonBlue, size: 28),
            SizedBox(width: 12),
            Text(
              '英雄联盟业余联赛平台',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '版本 1.0.0',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            Text(
              '为英雄联盟业余战队和选手提供赛事管理、招募、约战等功能的平台。',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
