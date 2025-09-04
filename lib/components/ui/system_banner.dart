import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemBanner extends StatelessWidget {
  const SystemBanner({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'HEAVYWEIGHT',
        textAlign: TextAlign.center,
        style: GoogleFonts.ibmPlexMono(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );
  }
}