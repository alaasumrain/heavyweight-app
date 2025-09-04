import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/ui/system_banner.dart';
import '../../components/ui/command_button.dart';
import '../../providers/profile_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../backend/supabase/supabase.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      if (_isLogin) {
        // Sign in existing user
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Sign up new user
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      
      if (mounted) {
        // Notify AppState of auth change
        final appState = context.read<AppStateProvider>().appState;
        appState.onAuthStateChanged();
        
        // Navigate to assignment (AppState will handle proper routing)
        context.go('/assignment');
      }
    } catch (error) {
      if (mounted) {
        _showError(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade900,
      ),
    );
  }

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
              
              // Toggle between LOGIN/SIGNUP
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: _isLogin ? Colors.white : Colors.transparent,
                          child: Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexMono(
                              color: _isLogin ? Colors.black : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: !_isLogin ? Colors.white : Colors.transparent,
                          child: Text(
                            'SIGNUP',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexMono(
                              color: !_isLogin ? Colors.black : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Email field
              TextField(
                controller: _emailController,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  labelStyle: GoogleFonts.ibmPlexMono(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 20),
              
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: GoogleFonts.ibmPlexMono(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Profile summary (for signup only)
              if (!_isLogin) ...[
                Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    if (!provider.isComplete) {
                      // Show which fields are missing
                      final missing = <String>[];
                      if (provider.experience == null) missing.add('EXPERIENCE');
                      if (provider.frequency == null) missing.add('FREQUENCY');
                      if (provider.age == null) missing.add('AGE');
                      if (provider.weight == null) missing.add('WEIGHT');
                      if (provider.height == null) missing.add('HEIGHT');
                      if (provider.objective == null) missing.add('OBJECTIVE');
                      
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red.shade800),
                          color: Colors.red.shade900.withOpacity(0.3),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'INCOMPLETE PROFILE',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ibmPlexMono(
                                color: Colors.red.shade300,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'MISSING: ${missing.join(', ')}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ibmPlexMono(
                                color: Colors.red.shade400,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => context.go('/profile'),
                              child: Text(
                                'TAP TO COMPLETE →',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.ibmPlexMono(
                                  color: Colors.red.shade200,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROFILE SUMMARY',
                            style: GoogleFonts.ibmPlexMono(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${provider.experience?.name.toUpperCase()} • ${provider.frequency} DAYS/WEEK\n'
                            '${provider.age} YRS • ${provider.weight?.round()}${provider.unit.name.toUpperCase()} • ${provider.height}CM\n'
                            '${provider.objective?.name.toUpperCase()} FOCUSED',
                            style: GoogleFonts.ibmPlexMono(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
              
              const Spacer(),
              
              // Action button
              if (_isLoading)
                Container(
                  height: 60,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else
                                  CommandButton(
                    text: _isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
                    variant: ButtonVariant.primary,
                    onPressed: _handleAuth,
                  ),
              
              if (_isLogin) ...[
                const SizedBox(height: 16),
                CommandButton(
                  text: 'FORGOT PASSWORD',
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      _showError('EMAIL_REQUIRED_FOR_RESET');
                      return;
                    }
                    
                    try {
                      final messenger = ScaffoldMessenger.of(context);
                      await supabase.auth.resetPasswordForEmail(
                        _emailController.text.trim(),
                      );
                      
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('PASSWORD_RESET_SENT'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (error) {
                      if (!mounted) return;
                      _showError('RESET_FAILED: ${error.toString()}');
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}