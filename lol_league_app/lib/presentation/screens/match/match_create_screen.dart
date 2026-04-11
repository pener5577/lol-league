import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/match_provider.dart';
import '../../../domain/providers/player_provider.dart';
import '../../../domain/providers/team_provider.dart';
import '../../../data/models/match_model.dart';
import '../../widgets/common_widgets.dart';

class MatchCreateScreen extends StatefulWidget {
  const MatchCreateScreen({super.key});

  @override
  State<MatchCreateScreen> createState() => _MatchCreateScreenState();
}

class _MatchCreateScreenState extends State<MatchCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  int? _selectedTeamId;
  String _selectedMode = '5v5';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    if (!mounted) return;
    await context.read<PlayerProvider>().loadCurrentPlayer();
    if (!mounted) return;
    context.read<TeamProvider>().loadTeams();
    // 同步 AuthProvider 的 currentPlayer
    if (mounted) {
      context.read<AuthProvider>().setCurrentPlayer(
        context.read<PlayerProvider>().currentPlayer,
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择您的战队'), backgroundColor: Colors.red),
      );
      return;
    }

    final matchProvider = context.read<MatchProvider>();
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final request = MatchCreateRequest(
      teamId: _selectedTeamId!,
      mode: _selectedMode,
      time: dateTime,
      note: _noteController.text.trim(),
    );

    final success = await matchProvider.createMatch(request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发布成功，等待审核'), backgroundColor: Colors.green),
      );
      context.pop();
    } else if (mounted && matchProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(matchProvider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布约战'),
      ),
      body: Consumer<MatchProvider>(
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
                    _buildTeamSelector(),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedMode,
                      decoration: const InputDecoration(
                        labelText: '比赛模式',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.matchModes.map((mode) {
                        return DropdownMenuItem(value: mode, child: Text(mode));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedMode = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '日期',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '时间',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: '备注',
                      hint: '如：友谊赛切磋',
                      controller: _noteController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: '发布约战',
                      onPressed: _create,
                      isLoading: provider.isLoading,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '提示: 发布约战后需要管理员审核通过才能生效',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
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

  Widget _buildTeamSelector() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, _) {
        final player = playerProvider.currentPlayer;
        final teams = context.read<TeamProvider>().teams;

        if (player?.teamId != null) {
          _selectedTeamId = player!.teamId;
        }

        if (teams.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.group_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('您还没有加入战队'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/team/list'),
                    child: const Text('加入战队'),
                  ),
                ],
              ),
            ),
          );
        }

        return DropdownButtonFormField<int>(
          value: _selectedTeamId,
          decoration: const InputDecoration(
            labelText: '选择战队',
            border: OutlineInputBorder(),
          ),
          items: teams.map((team) {
            return DropdownMenuItem(
              value: team.id,
              child: Text(team.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedTeamId = value);
          },
        );
      },
    );
  }
}
