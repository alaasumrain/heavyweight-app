import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/ui/system_banner.dart';
import '../../components/ui/command_button.dart';
import '../../providers/profile_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../core/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _authService.initialize();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    // Validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('FIELDS_REQUIRED: Please fill in all fields');
      return;
    }
    
    if (!AuthService.isValidEmail(_emailController.text)) {
      _showError('INVALID_EMAIL: Please enter a valid email address');
      return;
    }
    
    if (!_isLogin && !AuthService.isValidPassword(_passwordController.text)) {
      _showError(AuthService.getPasswordFeedback(_passwordController.text));
      return;
    }
    
    bool success;
    if (_isLogin) {
      success = await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      success = await _authService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
    
    if (success && mounted) {
      // Notify AppState of auth change
      final appState = context.read<AppStateProvider>().appState;
      appState.onAuthStateChanged();
      
      // Navigate to assignment
      context.go('/assignment');
    } else if (mounted && _authService.error != null) {
      _showError(_authService.error!);
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
      backgroundColor: HeavyweightTheme.background,
      appBar: AppBar(
        backgroundColor: HeavyweightTheme.background,
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
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 40,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
              const SystemBanner(),
              const SizedBox(height: 40),
              
              // Toggle between LOGIN/SIGNUP
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: HeavyweightTheme.primary),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: _isLogin ? HeavyweightTheme.primary : Colors.transparent,
                          child: Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: HeavyweightTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: !_isLogin ? HeavyweightTheme.primary : Colors.transparent,
                          child: Text(
                            'SIGNUP',
                            textAlign: TextAlign.center,
                            style: HeavyweightTheme.bodyMedium,
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
                style: HeavyweightTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  labelStyle: HeavyweightTheme.bodyMedium,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: HeavyweightTheme.primary),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: HeavyweightTheme.primary, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 20),
              
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: HeavyweightTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: HeavyweightTheme.bodyMedium,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: HeavyweightTheme.primary),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: HeavyweightTheme.primary, width: 2),
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
                              style: HeavyweightTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'MISSING: ${missing.join(', ')}',
                              textAlign: TextAlign.center,
                              style: HeavyweightTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => context.go('/profile'),
                              child: Text(
                                'TAP TO COMPLETE →',
                                textAlign: TextAlign.center,
                                style: HeavyweightTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: HeavyweightTheme.secondary.shade800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROFILE SUMMARY',
                            style: HeavyweightTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${provider.experience?.name.toUpperCase()} • ${provider.frequency} DAYS/WEEK\n'
                            '${provider.age} YRS • ${provider.weight?.round()}${provider.unit.name.toUpperCase()} • ${provider.height}CM\n'
                            '${provider.objective?.name.toUpperCase()} FOCUSED',
                            style: HeavyweightTheme.bodyMedium,
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
              ListenableBuilder(
                listenable: _authService,
                builder: (context, child) {
                  if (_authService.isLoading) {
                    return Container(
                      height: 60,
                      child: const Center(
                        child: CircularProgressIndicator(color: HeavyweightTheme.primary),
                      ),
                    );
                  }
                  
                  return CommandButton(
                    text: _isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
                    variant: ButtonVariant.primary,
                    onPressed: _handleAuth,
                  );
                },
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
                    
                    if (!AuthService.isValidEmail(_emailController.text)) {
                      _showError('INVALID_EMAIL: Please enter a valid email');
                      return;
                    }
                    
                    final success = await _authService.resetPassword(_emailController.text);
                    
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PASSWORD_RESET_SENT: Check your email'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (mounted && _authService.error != null) {
                      _showError(_authService.error!);
                    }
                  },
                ),
              ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}