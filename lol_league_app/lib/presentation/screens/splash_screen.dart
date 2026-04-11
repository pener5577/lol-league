import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 使用 postFrameCallback 确保 widget 完全挂载后再跳转
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    // 使用 go_router 直接跳转，不等待 auth 初始化
    // auth 会在主页里后台加载
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundDeep, AppColors.backgroundPrimary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: AppConstants.neonGlow(AppColors.neonBlue, 30),
                ),
                child: const Icon(Icons.sports_esports, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 40),
              // 标题
              const Text(
                '英雄联盟',
                style: TextStyle(fontSize: 16, color: AppColors.textMuted, letterSpacing: 6),
              ),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ).createShader(bounds),
                child: const Text(
                  '业余联赛平台',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3),
                ),
              ),
              const SizedBox(height: 80),
              // 加载指示器
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(color: AppColors.neonBlue, strokeWidth: 3),
              ),
              const SizedBox(height: 24),
              const Text('正在连接服务器...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
