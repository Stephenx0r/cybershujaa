import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_theme.dart';
import 'base_mission_screen.dart';

class TerminalSimulationScreen extends BaseMissionScreen {
  const TerminalSimulationScreen({
    super.key,
    required super.mission,
  });

  @override
  ConsumerState<BaseMissionScreen> createStateImpl() => _TerminalSimulationScreenState();
}

class _TerminalSimulationScreenState
    extends BaseMissionScreenState<TerminalSimulationScreen> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  List<TerminalEntry> _terminalHistory = [];
  bool _hasSubmittedSolution = false;
  int _currentSessionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeTerminal();
  }

  void _initializeTerminal() {
    final session = widget.mission.challenges.first.content.dataPayload['session'] as List;
    setState(() {
      _terminalHistory = [
        TerminalEntry(
          type: TerminalEntryType.system,
          content: 'Terminal Session Started\nType "help" for available commands\nMission: ${widget.mission.title}\n',
        ),
        TerminalEntry(
          type: TerminalEntryType.system,
          content: _getInitialMessage(),
        ),
      ];

      // Add first session entry to get started
      if (_currentSessionIndex < session.length) {
        final entry = session[_currentSessionIndex];
        _terminalHistory.add(
          TerminalEntry(
            type: entry['type'] == 'command'
                ? TerminalEntryType.command
                : TerminalEntryType.output,
            content: entry['content'],
          ),
        );
        _currentSessionIndex++;
      }
    });
    
    // Ensure the terminal widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String _getInitialMessage() {
    final missionId = widget.mission.id;
    if (missionId == 'TERMINAL_002') {
      return 'Analyzing network traffic for suspicious connections...\nUse commands like: netstat, tcpdump, whois, iptables\n';
    } else if (missionId == 'TERMINAL_003') {
      return 'Investigating suspicious file activity...\nUse commands like: ls -la, find, stat, file, cat\n';
    } else if (missionId == 'TERMINAL_004') {
      return 'Investigating suspicious user account activity...\nUse commands like: who, w, last, id, passwd\n';
    } else {
      return 'Investigating suspicious process activity...\nUse commands like: ps, lsof, netstat, kill\n';
    }
  }

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget buildMissionContent() {
    return Expanded(
      child: _buildTerminal(),
    );
  }

  Widget _buildTerminal() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceMedium),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), // GitHub Dark theme background
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: const Color(0xFF30363D), // GitHub Dark border
          width: 1,
        ),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        children: [
          // Terminal Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMedium),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22), // Darker header
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF30363D),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Terminal dots
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5F56), // Red
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFBD2E), // Yellow
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27CA3F), // Green
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppTheme.spaceMedium),
                Expanded(
                  child: Text(
                    'Terminal - CyberShujaa Mission',
                    style: AppTheme.labelMedium.copyWith(
                      color: const Color(0xFF8B949E), // GitHub text secondary
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSmall,
                    vertical: AppTheme.spaceXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: AppTheme.accentGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Terminal Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppTheme.spaceMedium),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 350,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _terminalHistory.map((entry) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.type == TerminalEntryType.command) ...[
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'user@cybershujaa:~\$ ',
                            style: TextStyle(
                              color: Color(0xFF7CE38B), // GitHub green
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: entry.content,
                            style: const TextStyle(
                              color: Color(0xFFF0F6FC), // GitHub white
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    SelectableText(
                      entry.content,
                      style: TextStyle(
                        color: _getEntryColor(entry.type),
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            );
          }).toList(),
                ),
              ),
            ),
          ),
          // Command input at bottom
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMedium,
              vertical: AppTheme.spaceSmall,
            ),
            child: Row(
              children: [
                const Text(
                  'user@cybershujaa:~\$ ',
                  style: TextStyle(
                    color: Color(0xFF7CE38B), // GitHub green
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Theme(
                    data: ThemeData(
                      inputDecorationTheme: const InputDecorationTheme(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                    child: TextField(
                      controller: _commandController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Color(0xFFF0F6FC), // GitHub white
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                      ),
                      onSubmitted: _handleCommand,
                      cursorColor: const Color(0xFF7CE38B), // GitHub green cursor
                      cursorWidth: 2,
                      cursorHeight: 16,
                      showCursor: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEntryColor(TerminalEntryType type) {
    switch (type) {
      case TerminalEntryType.command:
        return const Color(0xFFF0F6FC); // GitHub white
      case TerminalEntryType.output:
        return const Color(0xFF8B949E); // GitHub text secondary
      case TerminalEntryType.error:
        return const Color(0xFFFF7B72); // GitHub red
      case TerminalEntryType.success:
        return const Color(0xFF7CE38B); // GitHub green
      case TerminalEntryType.system:
        return const Color(0xFF79C0FF); // GitHub blue
    }
  }

  void _handleCommand(String command) {
    final trimmedCommand = command.trim();
    if (trimmedCommand.isEmpty) {
      _commandController.clear();
      return;
    }

    setState(() {
      // Add command to history
      _terminalHistory.add(
        TerminalEntry(
          type: TerminalEntryType.command,
          content: trimmedCommand,
        ),
      );

      // Process command
      if (trimmedCommand == 'help') {
        _handleHelpCommand();
      } else if (trimmedCommand == 'clear') {
        _terminalHistory.clear();
        _initializeTerminal();
      } else if (_isCorrectSolution(trimmedCommand)) {
        _handleCorrectSolution();
      } else {
        // Check if there are more session entries to show
        final session = widget.mission.challenges.first.content.dataPayload['session'] as List;
        if (_currentSessionIndex < session.length) {
          final entry = session[_currentSessionIndex];
          _terminalHistory.add(
            TerminalEntry(
              type: entry['type'] == 'command'
                  ? TerminalEntryType.command
                  : TerminalEntryType.output,
              content: entry['content'],
            ),
          );
          _currentSessionIndex++;
        } else {
          _terminalHistory.add(
            TerminalEntry(
              type: TerminalEntryType.error,
              content: 'Command not found or incorrect. Type "help" for available commands.',
            ),
          );
        }
      }
    });

    // Clear input and scroll to bottom
    _commandController.clear();
    Future.delayed(const Duration(milliseconds: 50), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleHelpCommand() {
    _terminalHistory.add(
      TerminalEntry(
        type: TerminalEntryType.system,
        content: _getHelpMessage(),
      ),
    );
  }

  String _getHelpMessage() {
    final missionId = widget.mission.id;
    if (missionId == 'TERMINAL_002') {
      return '''Available Commands:
  help     - Show this help message
  clear    - Clear terminal screen
  netstat  - Show network connections
  tcpdump  - Capture network traffic
  whois    - Lookup domain information
  iptables - Manage firewall rules
''';
    } else if (missionId == 'TERMINAL_003') {
      return '''Available Commands:
  help     - Show this help message
  clear    - Clear terminal screen
  ls       - List directory contents
  find     - Search for files
  stat     - Show file status
  file     - Determine file type
  cat      - Display file contents
''';
    } else if (missionId == 'TERMINAL_004') {
      return '''Available Commands:
  help     - Show this help message
  clear    - Clear terminal screen
  who      - Show logged-in users
  w        - Show user activity
  last     - Show login history
  id       - Show user identity
  passwd   - Change password
''';
    } else {
      return '''Available Commands:
  help     - Show this help message
  clear    - Clear terminal screen
  ps       - List running processes
  kill     - Terminate a process (usage: kill -9 PID)
  lsof     - List open files
  netstat  - Show network connections
''';
    }
  }

  bool _isCorrectSolution(String command) {
    return command.trim() == widget.mission.challenges.first.content.solution.trim();
  }

  void _handleCorrectSolution() {
    _hasSubmittedSolution = true;
    _terminalHistory.add(
      TerminalEntry(
        type: TerminalEntryType.success,
        content: _getSuccessMessage(),
      ),
    );

    completeMission();
    
    // Listen for any key to show completion dialog
    _focusNode.requestFocus();
    _commandController.addListener(() {
      if (_hasSubmittedSolution && _commandController.text.isNotEmpty) {
        showSuccessAndExit();
      }
    });
  }

  String _getSuccessMessage() {
    final missionId = widget.mission.id;
    if (missionId == 'TERMINAL_002') {
      return '''Success! You've successfully blocked the suspicious IP address.
Network security has been restored.

Mission completed! Type any key to exit.''';
    } else if (missionId == 'TERMINAL_003') {
      return '''Success! You've successfully identified the suspicious hidden file.
File system security has been restored.

Mission completed! Type any key to exit.''';
    } else if (missionId == 'TERMINAL_004') {
      return '''Success! You've successfully identified the suspicious user account.
User account security has been restored.

Mission completed! Type any key to exit.''';
    } else {
      return '''Success! You've successfully terminated the suspicious process.
System security has been restored.

Mission completed! Type any key to exit.''';
    }
  }

  @override
  double getProgressValue() {
    if (_hasSubmittedSolution) return 1.0;
    return _currentSessionIndex / 
        (widget.mission.challenges.first.content.dataPayload['session'] as List).length;
  }
}

enum TerminalEntryType {
  command,
  output,
  error,
  success,
  system,
}

class TerminalEntry {
  final TerminalEntryType type;
  final String content;

  TerminalEntry({
    required this.type,
    required this.content,
  });
}
