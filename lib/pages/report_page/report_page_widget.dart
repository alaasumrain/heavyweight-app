import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'report_page_model.dart';
export 'report_page_model.dart';

class ReportPageWidget extends StatefulWidget {
  const ReportPageWidget({super.key});

  @override
  State<ReportPageWidget> createState() => _ReportPageWidgetState();
}

class _ReportPageWidgetState extends State<ReportPageWidget> {
  late ReportPageModel _model;
  List<String> _trainingLog = [];

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportPageModel());
    _loadTrainingLog();
  }

  Future<void> _loadTrainingLog() async {
    final prefs = await SharedPreferences.getInstance();
    final log = prefs.getStringList('training_log') ?? [];
    
    // If empty, add some demo data
    if (log.isEmpty) {
      log.addAll([
        '2025-08-30 | BACK | DEADLIFT: 5,5,4 | PULL_UP: 6,5,5 | ROW: 6,6,5',
        '2025-08-29 | LEGS | SQUAT: 6,5,5 | LEG_PRESS: 5,5,4 | RDL: 6,6,5',
        '2025-08-28 | CHEST | BENCH_PRESS: 5,5,4 | INCLINE_PRESS: 5,4,4 | DIPS: 6,5,5',
        '2025-08-27 | SHOULDERS | OHP: 6,5,5 | LATERAL_RAISE: 6,6,5 | REAR_DELT: 6,6,6',
        'NEW_MAX_RECORDED: SQUAT | 145KG',
        '2025-08-26 | ARMS | CURL: 6,6,5 | TRICEP_EXT: 6,5,5 | HAMMER: 6,6,5',
      ]);
      await prefs.setStringList('training_log', log);
    }
    
    setState(() {
      _trainingLog = log;
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Header with TERMINAL prompt
        Align(
          alignment: const AlignmentDirectional(0.0, -1.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 0.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'TRAINING_LOG',
                    style: GoogleFonts.ibmPlexMono(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Launch TERMINAL interface
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierColor: Colors.black,
                      builder: (context) => _TerminalInterface(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '>',
                      style: GoogleFonts.ibmPlexMono(
                        color: const Color(0xFF666666),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Log entries
        Expanded(
          child: _trainingLog.isEmpty
              ? Center(
                  child: Text(
                    'NO_SESSIONS_RECORDED',
                    style: GoogleFonts.ibmPlexMono(
                      color: const Color(0xFF666666),
                      fontSize: 14.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 20.0),
                  itemCount: _trainingLog.length,
                  itemBuilder: (context, index) {
                    final entry = _trainingLog[index];
                    final isMaxRecord = entry.startsWith('NEW_MAX_RECORDED');
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isMaxRecord 
                            ? const Color(0xFF1A2A1A)  // Slightly green tint for max records
                            : const Color(0xFF1A1A1A),
                        border: Border.all(
                          color: isMaxRecord 
                              ? const Color(0xFF444444)
                              : const Color(0xFF333333),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        entry,
                        style: GoogleFonts.ibmPlexMono(
                          color: isMaxRecord 
                              ? const Color(0xFFAAFFAA)  // Bright green for max records
                              : Colors.white,
                          fontSize: 12.0,
                          fontWeight: isMaxRecord 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          letterSpacing: 0.5,
                          height: 1.5,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// TERMINAL Interface - Full screen command interface
class _TerminalInterface extends StatefulWidget {
  @override
  _TerminalInterfaceState createState() => _TerminalInterfaceState();
}

class _TerminalInterfaceState extends State<_TerminalInterface> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _history = [
    'HEAVYWEIGHT_TERMINAL_v1.0.0',
    'TYPE "HELP" FOR COMMAND LIST',
    '',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Terminal output
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return Text(
                    _history[index],
                    style: GoogleFonts.ibmPlexMono(
                      color: const Color(0xFF00FF00),
                      fontSize: 12.0,
                      height: 1.5,
                    ),
                  );
                },
              ),
            ),
            // Command input
            Row(
              children: [
                Text(
                  '> ',
                  style: GoogleFonts.ibmPlexMono(
                    color: const Color(0xFF00FF00),
                    fontSize: 14.0,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.ibmPlexMono(
                      color: const Color(0xFF00FF00),
                      fontSize: 14.0,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    autofocus: true,
                    onSubmitted: (command) {
                      setState(() {
                        _history.add('> $command');
                        _processCommand(command);
                        _controller.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _processCommand(String command) {
    final cmd = command.toUpperCase();
    switch (cmd) {
      case 'HELP':
        _history.addAll([
          'AVAILABLE COMMANDS:',
          '  STATUS    - SHOW CURRENT TRAINING METRICS',
          '  CLEAR     - CLEAR TERMINAL',
          '  EXIT      - CLOSE TERMINAL',
          '',
        ]);
        break;
      case 'STATUS':
        _history.addAll([
          'CURRENT_WEEK: 12',
          'SESSIONS_COMPLETE: 47',
          'CURRENT_MAX_BENCH: 102.5KG',
          'CURRENT_MAX_SQUAT: 145KG',
          'CURRENT_MAX_DEADLIFT: 180KG',
          '',
        ]);
        break;
      case 'CLEAR':
        _history.clear();
        _history.addAll([
          'HEAVYWEIGHT_TERMINAL_v1.0.0',
          '',
        ]);
        break;
      case 'EXIT':
        Navigator.of(context).pop();
        break;
      default:
        _history.add('COMMAND_NOT_RECOGNIZED: $command');
        _history.add('');
        break;
    }
  }
}