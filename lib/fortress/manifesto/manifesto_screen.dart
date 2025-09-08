import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_state_provider.dart';
import '../../core/theme/heavyweight_theme.dart';

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
      context.go(nextRoute);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HeavyweightTheme.primary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/'); // Go back to main app
            }
          },
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The Manifesto
                const SizedBox(height: 40),
                _buildManifestoText(),
                
                const SizedBox(height: 60),
                
                // Commitment Input
                _buildCommitmentInput(),
              ],
            ),
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
          'THE MANIFESTO',
          style: HeavyweightTheme.bodyMedium,
        ),
        
        const SizedBox(height: 30),
        
        Text(
          '''THIS IS NOT A FITNESS APP.
THIS IS A MANDATE SYSTEM.

THE SYSTEM PRESCRIBES. YOU EXECUTE.
THE MANDATE IS 4-6 REPS. NON-NEGOTIABLE.

NO SKIPPED WORKOUTS. NO SKIPPED REST.
NO LIES ABOUT PERFORMANCE.

LIFT HEAVY. LIFT HONESTLY. EXECUTE THE PROTOCOL.

READY TO SURRENDER CONTROL?''',
          style: HeavyweightTheme.bodyMedium,
            fontSize: 16,
            height: 1.8,
          ),
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
            style: HeavyweightTheme.bodyMedium,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 20),
          
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
                fontSize: 24,
              ),
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
                borderSide: BorderSide(color: Colors.red),
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
          
          const SizedBox(height: 40),
          
          // Submit button
          if (!_isValidating)
            GestureDetector(
              onTap: _handleCommitment,
              child: Container(
                width: double.infinity,
                height: 60,
                color: HeavyweightTheme.primary,
                child: Center(
                  child: Text(
                    'ENTER THE SYSTEM',
                    style: HeavyweightTheme.bodyMedium,
                  ),
                ),
              ),
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