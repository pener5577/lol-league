import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/team_provider.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  String? _lastExportPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadPlayers();
      context.read<TeamProvider>().loadTeams();
    });
  }

  Future<void> _exportTeamsExcel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在导出战队数据...';
    });

    try {
      final teams = context.read<TeamProvider>().teams;
      final workbook = excel.Excel.createExcel();
      final sheet = workbook['战队数据'];

      // 表头
      sheet.appendRow([
        excel.TextCellValue('ID'),
        excel.TextCellValue('战队名称'),
        excel.TextCellValue('大区'),
        excel.TextCellValue('小区'),
        excel.TextCellValue('胜场'),
        excel.TextCellValue('负场'),
        excel.TextCellValue('积分'),
        excel.TextCellValue('连胜'),
      ]);

      // 数据行
      for (final team in teams) {
        sheet.appendRow([
          excel.IntCellValue(team.id),
          excel.TextCellValue(team.name),
          excel.TextCellValue(team.regionGroup),
          excel.TextCellValue(team.regionSmall),
          excel.IntCellValue(team.wins),
          excel.IntCellValue(team.losses),
          excel.IntCellValue(team.score),
          excel.IntCellValue(team.winStreak),
        ]);
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/teams_$timestamp.xlsx';
      final file = File(filePath);
      file.writeAsBytesSync(workbook.encode()!);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '导出成功';
          _lastExportPath = filePath;
        });
        _showExportSuccess(filePath, '战队数据');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '导出失败: $e';
        });
      }
    }
  }

  Future<void> _exportPlayersExcel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在导出选手数据...';
    });

    try {
      final players = context.read<PlayerProvider>().players;
      final workbook = excel.Excel.createExcel();
      final sheet = workbook['选手数据'];

      // 表头
      sheet.appendRow([
        excel.TextCellValue('ID'),
        excel.TextCellValue('召唤师名称'),
        excel.TextCellValue('游戏ID'),
        excel.TextCellValue('大区'),
        excel.TextCellValue('小区'),
        excel.TextCellValue('位置'),
        excel.TextCellValue('MVP'),
        excel.TextCellValue('击杀'),
        excel.TextCellValue('死亡'),
        excel.TextCellValue('助攻'),
        excel.TextCellValue('胜场'),
        excel.TextCellValue('负场'),
      ]);

      // 数据行
      for (final player in players) {
        sheet.appendRow([
          excel.IntCellValue(player.id),
          excel.TextCellValue(player.matchName),
          excel.TextCellValue(player.gameId),
          excel.TextCellValue(player.regionGroup),
          excel.TextCellValue(player.regionSmall),
          excel.TextCellValue(player.position),
          excel.IntCellValue(player.mvpCount),
          excel.IntCellValue(player.kills),
          excel.IntCellValue(player.deaths),
          excel.IntCellValue(player.assists),
          excel.IntCellValue(player.wins),
          excel.IntCellValue(player.losses),
        ]);
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/players_$timestamp.xlsx';
      final file = File(filePath);
      file.writeAsBytesSync(workbook.encode()!);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '导出成功';
          _lastExportPath = filePath;
        });
        _showExportSuccess(filePath, '选手数据');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '导出失败: $e';
        });
      }
    }
  }

  void _showExportSuccess(String filePath, String fileType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.neonGreen),
            SizedBox(width: 8),
            Text('导出成功', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$fileType 表格已导出',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF252540),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                filePath,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '请使用Excel打开文件，编辑数据后保存。\n然后将文件分享发回给管理员进行导入。',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('路径已复制到剪贴板'), backgroundColor: AppColors.neonBlue),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('复制路径'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportDialog() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('导入数据', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请将编辑好的Excel文件放到应用文档目录：',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF252540),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FutureBuilder<String>(
                future: getApplicationDocumentsDirectory().then((d) => d.path),
                builder: (context, snapshot) {
                  return SelectableText(
                    snapshot.data ?? '获取路径中...',
                    style: const TextStyle(color: AppColors.neonBlue, fontSize: 12),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '战队导入文件名: teams_xxxx.xlsx\n选手导入文件名: players_xxxx.xlsx',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
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
              Navigator.pop(ctx);
              _importData();
            },
            child: const Text('开始导入'),
          ),
        ],
      ),
    );
  }

  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在导入数据...';
    });

    try {
      final directoryPath = await getApplicationDocumentsDirectory();
      final dir = Directory(directoryPath.path);
      final files = dir.listSync();

      int teamsImported = 0;
      int playersImported = 0;
      int teamsFailed = 0;
      int playersFailed = 0;

      final teamProvider = context.read<TeamProvider>();
      final playerProvider = context.read<PlayerProvider>();

      for (final file in files) {
        if (file is File && file.path.endsWith('.xlsx')) {
          final fileName = file.path.split('/').last.split('\\').last;

          if (fileName.startsWith('teams_')) {
            try {
              final bytes = file.readAsBytesSync();
              final workbook = excel.Excel.decodeBytes(bytes);

              for (final table in workbook.tables.keys) {
                final sheet = workbook.tables[table]!;
                for (int i = 1; i < sheet.maxRows; i++) {
                  final row = sheet.row(i);
                  if (row.isEmpty) continue;

                  try {
                    final id = _getIntValue(row[0]);
                    final wins = _getIntValue(row[4]) ?? 0;
                    final losses = _getIntValue(row[5]) ?? 0;
                    final score = _getIntValue(row[6]) ?? 0;
                    final winStreak = _getIntValue(row[7]) ?? 0;

                    if (id != null && id > 0) {
                      await teamProvider.updateTeamStats(
                        id,
                        wins: wins,
                        losses: losses,
                        score: score,
                        winStreak: winStreak,
                      );
                      teamsImported++;
                    }
                  } catch (e) {
                    teamsFailed++;
                  }
                }
              }
            } catch (e) {
              teamsFailed++;
            }
          } else if (fileName.startsWith('players_')) {
            try {
              final bytes = file.readAsBytesSync();
              final workbook = excel.Excel.decodeBytes(bytes);

              for (final table in workbook.tables.keys) {
                final sheet = workbook.tables[table]!;
                for (int i = 1; i < sheet.maxRows; i++) {
                  final row = sheet.row(i);
                  if (row.isEmpty) continue;

                  try {
                    final id = _getIntValue(row[0]);
                    final mvpCount = _getIntValue(row[6]) ?? 0;
                    final kills = _getIntValue(row[7]) ?? 0;
                    final deaths = _getIntValue(row[8]) ?? 0;
                    final assists = _getIntValue(row[9]) ?? 0;
                    final wins = _getIntValue(row[10]) ?? 0;
                    final losses = _getIntValue(row[11]) ?? 0;

                    if (id != null && id > 0) {
                      final totalGames = wins + losses;
                      final winRate = totalGames > 0 ? (wins * 100 / totalGames).round() : 0;
                      final kda = deaths > 0 ? (kills + assists) / deaths : (kills + assists).toDouble();

                      await playerProvider.updatePlayerStats(
                        id,
                        kills: kills,
                        deaths: deaths,
                        assists: assists,
                        mvpCount: mvpCount,
                        wins: wins,
                        losses: losses,
                        winRate: winRate,
                        kda: kda,
                      );
                      playersImported++;
                    }
                  } catch (e) {
                    playersFailed++;
                  }
                }
              }
            } catch (e) {
              playersFailed++;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '导入完成: 战队${teamsImported}条, 选手${playersImported}条';
        });

        teamProvider.loadTeams();
        playerProvider.loadPlayers();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('战队: 成功$teamsImported/${teamsImported + teamsFailed}, 选手: 成功$playersImported/${playersImported + playersFailed}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = '导入失败: $e';
        });
      }
    }
  }

  int? _getIntValue(dynamic cell) {
    if (cell == null) return null;
    final value = cell.value;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据管理'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D18), Color(0xFF1A1A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.neonBlue),
                    const SizedBox(height: 16),
                    Text(_statusMessage ?? '处理中...', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('战队数据'),
                    const SizedBox(height: 12),
                    _buildDataCard(
                      title: '战队数据',
                      description: '导出Excel表格\n编辑胜场、负场、积分、连胜',
                      icon: Icons.shield,
                      color: AppColors.neonPurple,
                      onExport: _exportTeamsExcel,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('选手数据'),
                    const SizedBox(height: 12),
                    _buildDataCard(
                      title: '选手数据',
                      description: '导出Excel表格\n编辑MVP、击杀、死亡、助攻、胜场、负场',
                      icon: Icons.person,
                      color: AppColors.neonBlue,
                      onExport: _exportPlayersExcel,
                    ),
                    const SizedBox(height: 24),
                    _buildImportSection(),
                    if (_statusMessage != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.neonGreen.withAlpha(50)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _statusMessage!,
                                style: const TextStyle(color: AppColors.neonGreen, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.neonBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onExport,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF252540).withAlpha(128),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onExport,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('导出Excel表格'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF252540).withAlpha(128),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonGold.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upload_file, color: AppColors.neonGold, size: 28),
                SizedBox(width: 12),
                Text(
                  '导入编辑后的数据',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '将编辑好的Excel文件放到应用文档目录，然后点击"扫描导入"按钮。',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showImportDialog,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('扫描导入'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.neonGold,
                  side: const BorderSide(color: AppColors.neonGold),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
