import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/heavyweight_theme.dart';

/// The Philosophy Screen - Sets expectations before the Manifesto
/// Frames the brutalist identity as a choice, not a threat
class PhilosophyScreen extends StatelessWidget {
  const PhilosophyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Main content centered
              Column(
                children: [
                  // Primary headline
                  Text(
                    'THIS IS NOT\nFOR EVERYONE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                      height: 1.1,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Explanation paragraphs
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Most fitness apps want you to feel good.\nWe want you to get strong.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Container(
                          height: 1,
                          width: 60,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'This system enforces heavy sets and mandatory rest. No shortcuts. No excuses. Just results.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade300,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Closing statement
                  Text(
                    'It requires commitment.\nIf you\'re ready to do the work,\nwe are ready to guide you.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // CTA button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () => context.go('/manifesto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'UNDERSTOOD',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Exit option
              TextButton(
                onPressed: () {
                  // Could show exit dialog or just pop
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      title: Text(
                        'LEAVING HEAVYWEIGHT?',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: Text(
                        'This approach isn\'t right for everyone.\nFind what works for you.',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'STAY',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/'); // Back to splash or exit app
                          },
                          child: Text(
                            'LEAVE',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'This isn\'t for me',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}