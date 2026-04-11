class ApiConstants {
  // 模拟器访问使用电脑IP
  static const String baseUrl = 'http://192.168.10.189:3000/api';

  // 认证
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // 选手
  static const String players = '/players';
  static const String playerCurrent = '/players/me/current';
  static const String playerRankingsWinrate = '/players/rankings/winrate';
  static const String playerRankingsKda = '/players/rankings/kda';
  static const String playerRankingsMvp = '/players/rankings/mvp';

  // 战队
  static const String teams = '/teams';
  static const String teamRankingsScore = '/teams/rankings/score';
  static const String teamRankingsWinStreak = '/teams/rankings/winStreak';

  // 约战
  static const String matches = '/matches';
  static const String matchResultsList = '/matches/results/list';

  // 通知
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';

  // 统计
  static const String statsOverview = '/stats/overview';
  static const String statsPublic = '/stats/public';

  // 用户管理
  static const String users = '/users';
}
