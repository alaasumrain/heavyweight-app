import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/ui/system_banner.dart';
import '../../components/ui/navigation_bar.dart';

class TrainingLogScreen extends StatelessWidget {
  const TrainingLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SystemBanner(),
              const SizedBox(height: 40),
              
              Text(
                'TRAINING LOG',
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              
              const SizedBox(height: 40),
              
              Expanded(
                child: Center(
                  child: Text(
                    'TRAINING LOG\nCOMING SOON',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexMono(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HeavyweightNavigationBar(
        currentIndex: 1, // Training Log is index 1
      ),
    );
  }
}

