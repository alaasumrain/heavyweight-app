import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_state_provider.dart';
import '../../core/theme/heavyweight_theme.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../components/ui/command_button.dart';
import '../../core/logging.dart';

/// The Manifesto Screen - The gateway to the system
/// User must read the philosophy and type "I COMMIT" to enter
class ManifestoScreen extends StatefulWidget {
  const ManifestoScreen({Key? key}) : super(key: key);
  
  @override
  State<ManifestoScreen> createState() => _ManifestoScreenState();
}

class _ManifestoScreenState extends State<ManifestoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commitmentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValidating = false;
  
  @override
  void dispose() {
    _commitmentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  Future<void> _handleCommitment() async {
    HWLog.event('manifesto_commit_attempt', data: {
      'text': _commitmentController.text,
    });
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isValidating = true;
      });
      
      // Mark manifesto as committed in AppState
      final appState = context.read<AppStateProvider>().appState;
      await appState.commitManifesto();
      
      // Navigate to next step (AppState will handle routing)
      if (!mounted) return;
      final nextRoute = appState.nextRoute;
      HWLog.event('manifesto_commit_success', data: {'next': nextRoute});
      context.go(nextRoute);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    HWLog.screen('Onboarding/Manifesto');
    final appState = context.read<AppStateProvider>().appState;
    final committed = appState.manifestoCommitted;
    return HeavyweightScaffold(
      title: 'MANIFESTO',
      showBackButton: committed, // allow back when accessed from Settings
      fallbackRoute: '/app?tab=2',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: HeavyweightTheme.spacingMd),
              _buildManifestoText(),
              const SizedBox(height: HeavyweightTheme.spacingXl),
              _buildCommitmentInput(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildManifestoText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE PROTOCOL',
          style: HeavyweightTheme.bodyMedium,
        ),
        
        const SizedBox(height: HeavyweightTheme.spacingLg),
        
        Text(
          '''THE HEAVYWEIGHT PROTOCOL

A SYSTEMATIC APPROACH TO STRENGTH.
PRECISION-ENGINEERED TRAINING PROGRAMS.

FOUR TO SIX REPETITIONS. HEAVY LOADS.
THE SCIENCE OF PROGRESSIVE OVERLOAD.

CONSISTENCY BUILDS POWER.
REST WHEN PRESCRIBED. TRAIN WHEN REQUIRED.

TRACK EVERY REPETITION. MEASURE EVERY GAIN.
THE SYSTEM GUIDES. YOU EXECUTE.

READY TO BEGIN YOUR TRANSFORMATION?''',
          style: HeavyweightTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Widget _buildCommitmentInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Instruction
          Text(
            'TYPE "I COMMIT" TO BEGIN',
            style: HeavyweightTheme.bodySmall,
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingMd),
          
          // Input field
          TextFormField(
            controller: _commitmentController,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: HeavyweightTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: '...',
              hintStyle: HeavyweightTheme.bodySmall,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: HeavyweightTheme.primary),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF444444)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: HeavyweightTheme.primary, width: 2),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: HeavyweightTheme.danger),
              ),
              filled: true,
              fillColor: const Color(0xFF111111),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z\s]')),
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Your commitment is required';
              }
              if (value.trim().toUpperCase() != 'I COMMIT') {
                return 'Type exactly: I COMMIT';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleCommitment(),
          ),
          
          const SizedBox(height: HeavyweightTheme.spacingXl),
          
          // Submit button
          if (!_isValidating)
            CommandButton(
              text: 'ENTER THE SYSTEM',
              variant: ButtonVariant.primary,
              onPressed: _handleCommitment,
            ),
          
          if (_isValidating)
            const CircularProgressIndicator(
              color: HeavyweightTheme.primary,
            ),
        ],
      ),
    );
  }
}
