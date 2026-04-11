import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/notification_provider.dart';
import '../../widgets/common_widgets.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final provider = context.read<NotificationProvider>();
    await provider.loadNotifications();
    await provider.loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return CyberBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            '通知中心',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                if (provider.unreadCount == 0) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: const Text(
                    '全部已读',
                    style: TextStyle(color: AppColors.neonBlue),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.neonBlue),
              );
            }

            if (provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: AppColors.textMuted.withOpacity(0.5),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '暂无通知',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: AppColors.neonBlue,
              backgroundColor: AppColors.backgroundCard,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return _buildNotificationCard(notification, provider);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(notification, NotificationProvider provider) {
    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case 'team_invite':
        typeColor = AppColors.neonBlue;
        typeIcon = Icons.group_add;
        break;
      case 'team_apply':
        typeColor = AppColors.neonGold;
        typeIcon = Icons.person_add;
        break;
      case 'match_invite':
        typeColor = AppColors.neonPurple;
        typeIcon = Icons.sports_esports;
        break;
      case 'match_accept':
        typeColor = AppColors.neonGreen;
        typeIcon = Icons.check_circle;
        break;
      case 'match_reject':
        typeColor = AppColors.neonRed;
        typeIcon = Icons.cancel;
        break;
      default:
        typeColor = AppColors.textSecondary;
        typeIcon = Icons.notifications;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        hasGlow: !notification.read,
        glowColor: typeColor.withOpacity(0.3),
        borderColor: notification.read
            ? AppColors.borderDefault
            : typeColor.withOpacity(0.5),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.typeDisplayName,
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.statusDisplayName,
                        style: TextStyle(
                          color: notification.isPending
                              ? AppColors.textMuted
                              : notification.isAccepted
                                  ? AppColors.neonGreen
                                  : AppColors.neonRed,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.read)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: typeColor.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 消息内容
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.message,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 时间
            if (notification.createdAt != null)
              Text(
                _formatTime(notification.createdAt!),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            // 操作按钮
            if (notification.isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      final success = await provider.rejectNotification(notification.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('已拒绝'),
                            backgroundColor: AppColors.backgroundCard,
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.neonRed,
                    ),
                    child: const Text('拒绝'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await provider.acceptNotification(notification.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('已接受'),
                            backgroundColor: AppColors.backgroundCard,
                          ),
                        );
                        // 如果是战队相关，跳转到战队页面
                        if (notification.type == 'team_invite' || notification.type == 'team_apply') {
                          if (notification.teamId != null) {
                            context.push('/team/detail/${notification.teamId}');
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('接受'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}