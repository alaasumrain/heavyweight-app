import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_animations.dart';

/// The Manifesto Screen - The gateway to the system
/// User must read the philosophy and type "I COMMIT" to enter
class ManifestoScreen extends StatefulWidget {
  const ManifestoScreen({Key? key}) : super(key: key);
  
  @override
  State<ManifestoScreen> createState() => _ManifestoScreenState();
}

class _ManifestoScreenState extends State<ManifestoScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _commitmentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValidating = false;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _commitmentController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  Future<void> _handleCommitment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isValidating = true;
      });
      
      // Store commitment
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fortress_commitment', DateTime.now().toIso8601String());
      await prefs.setBool('fortress_committed', true);
      
      // Navigate to mandate
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/fortress/mandate');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
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
      ),
    );
  }
  
  Widget _buildManifestoText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE MANIFESTO',
          style: TextStyle(
            color: const Color(0xFF00FF00),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ).animate()
          .fadeIn(duration: 1000.ms, delay: 500.ms)
          .slideY(begin: -0.2, end: 0),
        
        const SizedBox(height: 30),
        
        Text(
          '''This is not a fitness app.
This is a mandate system.

You will not choose your workouts.
The system will prescribe them.

You will not skip rest periods.
Recovery is not optional.

You will not lie about your performance.
The system needs truth, especially in failure.

The mandate is 4-6 reps.
Not a suggestion. A requirement.

You will lift heavy.
You will lift honestly.
You will obey the protocol.

Progress is not a choice.
It is the inevitable result of compliance.

If you cannot commit to this philosophy,
close this app now.

If you are ready to surrender control
and trust the system completely,
type your commitment below.''',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            height: 1.8,
            fontFamily: 'monospace',
          ),
        ).animate()
          .fadeIn(duration: 1500.ms, delay: 1000.ms)
          .slideY(begin: 0.1, end: 0),
      ],
    );
  }
  
  Widget _buildCommitmentInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Pulsing instruction
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.5 + (_pulseController.value * 0.5),
                child: Text(
                  'TYPE "I COMMIT" TO BEGIN',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Input field
          TextFormField(
            controller: _commitmentController,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: '...',
              hintStyle: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 24,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00FF00)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00FF00), width: 2),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00FF00),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'ENTER THE SYSTEM',
                    style: TextStyle(
                      color: Color(0xFF00FF00),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ).animate()
              .fadeIn(duration: 1000.ms, delay: 2000.ms)
              .slideY(begin: 0.2, end: 0),
          
          if (_isValidating)
            const CircularProgressIndicator(
              color: Color(0xFF00FF00),
            ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 1000.ms, delay: 2500.ms);
  }
}