import 'package:flutter/material.dart';

class AppColors {
  // 极深黑背景 - 赛博朋克风格
  static const Color backgroundDeep = Color(0xFF020208);
  static const Color backgroundPrimary = Color(0xFF08080F);
  static const Color backgroundSecondary = Color(0xFF0D0D18);
  static const Color backgroundCard = Color(0xFF111120);
  static const Color backgroundElevated = Color(0xFF181828);

  // 边框色 - 更细腻
  static const Color borderSubtle = Color(0xFF181828);
  static const Color borderDefault = Color(0xFF252540);
  static const Color borderHighlight = Color(0xFF353560);
  static const Color borderAccent = Color(0xFF404070);

  // 霓虹主色 - 更鲜艳
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFFAA44FF);
  static const Color neonPink = Color(0xFFFF0099);
  static const Color neonGold = Color(0xFFFFCC00);
  static const Color neonGreen = Color(0xFF00FF99);
  static const Color neonOrange = Color(0xFFFF7722);
  static const Color neonRed = Color(0xFFFF2255);
  static const Color neonCyan = Color(0xFF00FFCC);

  // 文字色
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF8080AA);
  static const Color textMuted = Color(0xFF505068);

  // 状态色
  static const Color statusPending = neonOrange;
  static const Color statusWaiting = neonBlue;
  static const Color statusScheduled = neonGreen;
  static const Color statusFinished = textMuted;
  static const Color statusCancelled = neonRed;
  static const Color statusRejected = neonRed;

  // 渐变辅助色
  static const Color gradientBlueStart = Color(0xFF00D4FF);
  static const Color gradientBlueEnd = Color(0xFF0088CC);
  static const Color gradientPurpleStart = Color(0xFFAA44FF);
  static const Color gradientPurpleEnd = Color(0xFF6622AA);
  static const Color gradientGoldStart = Color(0xFFFFCC00);
  static const Color gradientGoldEnd = Color(0xFFFF8800);
  static const Color gradientGreenStart = Color(0xFF00FF99);
  static const Color gradientGreenEnd = Color(0xFF00AA55);
  static const Color gradientPinkStart = Color(0xFFFF0099);
  static const Color gradientPinkEnd = Color(0xFFCC0066);

  // 光效辅助
  static const Color glowBlue = Color(0x4000D4FF);
  static const Color glowPurple = Color(0x40AA44FF);
  static const Color glowGold = Color(0x40FFCC00);
  static const Color glowGreen = Color(0x4000FF99);
  static const Color glowPink = Color(0x40FF0099);
}

class AppConstants {
  static const String appName = '英雄联盟业余联赛平台';
  static const String appVersion = '1.0.0';

  // 主题色
  static const Color primaryColor = AppColors.neonBlue;
  static const Color secondaryColor = AppColors.neonGold;
  static const Color accentColor = AppColors.neonPurple;

  // 背景色
  static const Color backgroundDark = AppColors.backgroundDeep;
  static const Color backgroundCard = AppColors.backgroundCard;
  static const Color surfaceColor = AppColors.backgroundElevated;
  static const Color borderColor = AppColors.borderDefault;

  // 文字色
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  // 状态色
  static const Color statusPending = AppColors.statusPending;
  static const Color statusWaiting = AppColors.statusWaiting;
  static const Color statusScheduled = AppColors.statusScheduled;
  static const Color statusFinished = AppColors.statusFinished;
  static const Color statusCancelled = AppColors.statusCancelled;
  static const Color statusRejected = AppColors.statusRejected;

  // 约战状态文字
  static const Map<String, String> statusText = {
    '待审核': '待审核',
    '待应战': '待应战',
    '已约战': '已约战',
    '已结束': '已结束',
    '已取消': '已取消',
    '未通过': '未通过',
  };

  // 位置选项
  static const List<String> positions = [
    '全能',
    '上单',
    '打野',
    '中单',
    'ADC',
    '辅助',
  ];

  // 比赛模式
  static const List<String> matchModes = ['5v5', '3v3'];

  // 渐变定义 - 增强版
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.gradientBlueStart, AppColors.gradientPurpleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [AppColors.gradientGoldStart, AppColors.gradientGoldEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonBlueGradient = LinearGradient(
    colors: [AppColors.gradientBlueStart, AppColors.gradientBlueEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [AppColors.gradientPurpleStart, AppColors.gradientPurpleEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [AppColors.gradientGreenStart, AppColors.gradientGreenEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [AppColors.gradientPinkStart, AppColors.gradientPinkEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF141428), Color(0xFF0E0E1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepCardGradient = LinearGradient(
    colors: [Color(0xFF0E0E1C), Color(0xFF080810)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 边框渐变
  static const LinearGradient neonBorderGradient = LinearGradient(
    colors: [AppColors.neonBlue, AppColors.neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldBorderGradient = LinearGradient(
    colors: [AppColors.neonGold, AppColors.neonOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 霓虹发光效果 - 多层叠加
  static List<BoxShadow> neonGlow(Color color, [double blur = 20]) => [
    BoxShadow(color: color.withAlpha(179), blurRadius: blur * 0.5, spreadRadius: 0),
    BoxShadow(color: color.withAlpha(128), blurRadius: blur, spreadRadius: 0),
    BoxShadow(color: color.withAlpha(64), blurRadius: blur * 2, spreadRadius: 0),
  ];

  static List<BoxShadow> neonGlowStrong(Color color) => [
    BoxShadow(color: color.withAlpha(153), blurRadius: 8, spreadRadius: 0),
    BoxShadow(color: color.withAlpha(128), blurRadius: 16, spreadRadius: 0),
    BoxShadow(color: color.withAlpha(102), blurRadius: 32, spreadRadius: 0),
    BoxShadow(color: color.withAlpha(51), blurRadius: 48, spreadRadius: 0),
  ];

  static List<BoxShadow> softGlow(Color color) => [
    BoxShadow(color: color.withAlpha(76), blurRadius: 8, spreadRadius: 0),
    BoxShadow(color: color.withAlpha(38), blurRadius: 16, spreadRadius: 0),
    BoxShadow(color: color.withAlpha(19), blurRadius: 32, spreadRadius: 0),
  ];

  // 边框光效
  static List<BoxShadow> neonBorder(Color color, [double blur = 8]) => [
    BoxShadow(color: color.withAlpha(102), blurRadius: blur, spreadRadius: 1),
    BoxShadow(color: color.withAlpha(51), blurRadius: blur * 2, spreadRadius: 2),
  ];
}

class RegionData {
  // 所有大区列表（独立大区和合并大区）
  static const List<String> allGroups = [
    '艾欧尼亚',
    '黑色玫瑰',
    '峡谷之巅',
    '联盟一区',
    '联盟二区',
    '联盟三区',
    '联盟四区',
    '联盟五区',
  ];

  // 独立大区（直接使用大区名作为服务器）
  static const List<String> independentRegions = [
    '艾欧尼亚',
    '黑色玫瑰',
    '峡谷之巅',
  ];

  // 合并大区对应的小区
  static const Map<String, List<String>> groupToSmallRegions = {
    '联盟一区': ['祖安', '皮尔特沃夫', '巨神峰', '教育网', '男爵领域', '均衡教派', '影流', '守望之海'],
    '联盟二区': ['卡拉曼达', '暗影岛', '征服之海', '诺克萨斯', '战争学院', '雷瑟守备'],
    '联盟三区': ['班德尔城', '裁决之地', '水晶之痕', '钢铁烈阳', '皮城警备'],
    '联盟四区': ['比尔吉沃特', '弗雷尔卓德', '扭曲丛林'],
    '联盟五区': ['德玛西亚', '无畏先锋', '恕瑞玛', '巨龙之巢'],
  };

  // 所有小区列表（用于筛选），格式为 {id, name, group}
  static List<Map<String, String>> get allSmallRegions {
    final List<Map<String, String>> result = [];
    // 添加独立大区
    for (String region in independentRegions) {
      result.add({'id': region, 'name': region, 'group': region});
    }
    // 添加合并大区的小区
    for (MapEntry<String, List<String>> entry in groupToSmallRegions.entries) {
      String regionName = entry.key;
      List<String> smallRegions = entry.value;
      for (String small in smallRegions) {
        String regionId = regionName + '-' + small;
        result.add({'id': regionId, 'name': small, 'group': regionName});
      }
    }
    return result;
  }

  // 根据小区名获取大区名称
  static String getGroupBySmallRegion(String smallRegion) {
    for (var entry in groupToSmallRegions.entries) {
      if (entry.value.contains(smallRegion)) {
        return entry.key;
      }
    }
    // 如果找不到匹配，返回原值（可能是独立大区）
    return smallRegion;
  }

  // 判断是否独立大区
  static bool isIndependentRegion(String region) {
    return independentRegions.contains(region);
  }

  // 根据大区获取所有小区
  static List<String> getSmallRegionsByGroup(String group) {
    return groupToSmallRegions[group] ?? [];
  }

  // 获取所有大区列表
  static List<String> getAllGroups() {
    return allGroups;
  }
}
