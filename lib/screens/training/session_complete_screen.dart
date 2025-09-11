import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../fortress/engine/models/set_data.dart';
import '../../fortress/viewmodels/workout_viewmodel.dart';
import '../../providers/workout_viewmodel_provider.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/logging.dart';


/// Session Complete Screen - Final judgment of the workout
/// Shows mandate satisfaction/violation with brutal honesty
class SessionCompleteScreen extends StatefulWidget {
  final List<SetData> sessionSets;
  final bool mandateSatisfied;
  
  const SessionCompleteScreen({
    super.key,
    required this.sessionSets,
    required this.mandateSatisfied,
  });
  
  static Widget withProvider({
    required List<SetData> sessionSets,
    required bool mandateSatisfied,
  }) {
    return WorkoutViewModelProvider(
      child: SessionCompleteScreen(
        sessionSets: sessionSets,
        mandateSatisfied: mandateSatisfied,
      ),
    );
  }
  
  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Trigger haptic feedback based on mandate satisfaction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mandateSatisfied) {
        HapticFeedback.lightImpact(); // Success feedback
      } else {
        HapticFeedback.heavyImpact(); // Failure feedback
      }
      _animationController.forward();
      
      // Process workout results to refresh mandate
      _processWorkoutResults();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Process workout results and refresh mandate
  Future<void> _processWorkoutResults() async {
    if (widget.sessionSets.isEmpty) return;
    
    try {
      final viewModel = context.read<WorkoutViewModel>();
      await viewModel.processWorkoutResults(widget.sessionSets);
    } catch (e) {
      // Silently handle errors - the UI has already shown the session results
    }
  }
  
  // Calculate session statistics
  SessionStats get _stats {
    if (widget.sessionSets.isEmpty) {
      return SessionStats.empty();
    }
    
    final totalSets = widget.sessionSets.length;
    final mandateSets = widget.sessionSets.where((s) => s.metMandate).length;
    final failureSets = widget.sessionSets.where((s) => s.isFailure).length;
    final exceededSets = widget.sessionSets.where((s) => s.exceededMandate).length;
    final adherencePercent = ((mandateSets / totalSets) * 100).round();
    
    final totalVolume = widget.sessionSets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.actualReps),
    );
    
    return SessionStats(
      totalSets: totalSets,
      mandateSets: mandateSets,
      failureSets: failureSets,
      exceededSets: exceededSets,
      adherencePercent: adherencePercent,
      totalVolume: totalVolume,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    HWLog.screen('Training/SessionComplete');
    final stats = _stats;
    
    return HeavyweightScaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: HeavyweightTheme.spacingLg),
                    // Mandate Judgment Header
                    _buildMandateJudgment(),
                    const SizedBox(height: HeavyweightTheme.spacingXl),
                    // Session Statistics
                    _buildSessionStats(stats),
                    const SizedBox(height: HeavyweightTheme.spacingXl),
                    // Next Session Preview
                    _buildNextSessionPreview(),
                    const SizedBox(height: HeavyweightTheme.spacingXl),
                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: HeavyweightTheme.spacingMd),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildMandateJudgment() {
    return Column(
      children: [
        // Primary judgment
        Container(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.mandateSatisfied ? HeavyweightTheme.primary : HeavyweightTheme.error,
              width: 3,
            ),
          ),
          child: Column(
            children: [
              Text(
                widget.mandateSatisfied ? 'MANDATE' : 'MANDATE',
                style: TextStyle(
                  color: widget.mandateSatisfied ? HeavyweightTheme.primary : HeavyweightTheme.error,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: HeavyweightTheme.spacingSm),
              Text(
                widget.mandateSatisfied ? 'SATISFIED' : 'VIOLATED',
                style: TextStyle(
                  color: widget.mandateSatisfied ? HeavyweightTheme.primary : HeavyweightTheme.error,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: HeavyweightTheme.spacingMd),
        
        // Judgment explanation
        Text(
          widget.mandateSatisfied
              ? 'THE SYSTEM ACKNOWLEDGES YOUR ADHERENCE'
              : 'THE SYSTEM RECORDS YOUR FAILURE',
          style: TextStyle(
            color: HeavyweightTheme.textSecondary,
            fontSize: 14,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildSessionStats(SessionStats stats) {
    return Container(
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SESSION_SUMMARY',
            style: TextStyle(
              color: HeavyweightTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingMd),
          
          _buildStatRow('TOTAL_SETS', '${stats.totalSets}'),
          _buildStatRow('MANDATE_SETS', '${stats.mandateSets}', 
                       color: HeavyweightTheme.primary),
          _buildStatRow('FAILURE_SETS', '${stats.failureSets}', 
                       color: stats.failureSets > 0 ? HeavyweightTheme.error : null),
          _buildStatRow('EXCEEDED_SETS', '${stats.exceededSets}', 
                       color: stats.exceededSets > 0 ? HeavyweightTheme.warning : null),
          _buildStatRow('ADHERENCE', '${stats.adherencePercent}%', 
                       color: stats.adherencePercent >= 70 ? HeavyweightTheme.primary : HeavyweightTheme.error),
          _buildStatRow('TOTAL_VOLUME', '${stats.totalVolume.toStringAsFixed(1)}KG'),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HeavyweightTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: HeavyweightTheme.textSecondary,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? HeavyweightTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextSessionPreview() {
    return Container(
      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border.all(color: HeavyweightTheme.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT_SESSION',
            style: TextStyle(
              color: HeavyweightTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingSm),
          Text(
            widget.mandateSatisfied 
                ? 'WEIGHTS WILL BE INCREASED'
                : 'WEIGHTS WILL BE DECREASED',
            style: TextStyle(
              color: widget.mandateSatisfied ? HeavyweightTheme.primary : HeavyweightTheme.error,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: HeavyweightTheme.spacingXs),
          Text(
            'REST 48-72 HOURS MINIMUM',
            style: TextStyle(
              color: HeavyweightTheme.textSecondary,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action - View Log
        CommandButton(
          text: 'VIEW_TRAINING_LOG',
          variant: ButtonVariant.primary,
          semanticLabel: 'View your complete training log',
          onPressed: () {
            HWLog.event('session_complete_action', data: {'action': 'view_log'});
            context.go('/training-log');
          },
        ),
        
        const SizedBox(height: HeavyweightTheme.spacingMd),
        
        // Secondary action - Return to Assignment
        CommandButton(
          text: 'RETURN_TO_ASSIGNMENT',
          variant: ButtonVariant.secondary,
          semanticLabel: 'Return to workout assignment screen',
          onPressed: () {
            HWLog.event('session_complete_action', data: {'action': 'return_assignment'});
            context.go('/assignment');
          },
        ),
      ],
    );
  }
}

/// Session statistics model
class SessionStats {
  final int totalSets;
  final int mandateSets;
  final int failureSets;
  final int exceededSets;
  final int adherencePercent;
  final double totalVolume;
  
  const SessionStats({
    required this.totalSets,
    required this.mandateSets,
    required this.failureSets,
    required this.exceededSets,
    required this.adherencePercent,
    required this.totalVolume,
  });
  
  factory SessionStats.empty() {
    return const SessionStats(
      totalSets: 0,
      mandateSets: 0,
      failureSets: 0,
      exceededSets: 0,
      adherencePercent: 0,
      totalVolume: 0,
    );
  }
}
