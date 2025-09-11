import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/ui/command_button.dart';
import '../../components/layout/heavyweight_scaffold.dart';
import '../../providers/profile_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../core/auth_service.dart';
import '../../components/ui/toast.dart';
import '../../core/logging.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  bool _isLogin = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _authService.initialize();
    HWLog.screen('Onboarding/Auth');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    HWLog.event('auth_submit_tap', data: {
      'mode': _isLogin ? 'login' : 'signup',
    });
    setState(() {
      _isLoading = true;
    });
    // Validation with proper loading state cleanup
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('FIELDS_REQUIRED. COMPLETE_ALL_INPUTS.');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    if (!AuthService.isValidEmail(_emailController.text)) {
      _showError('INVALID_EMAIL. CHECK_FORMAT.');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    if (!_isLogin && !AuthService.isValidPassword(_passwordController.text)) {
      _showError(AuthService.getPasswordFeedback(_passwordController.text));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      
      // Navigate to app shell (Assignment tab)
      HWLog.event('auth_success_navigate', data: {'to': '/app?tab=0'});
      context.go('/app?tab=0');
    } else if (mounted && _authService.error != null) {
      HWLog.event('auth_failed', data: {'error': _authService.error!});
      _showError(_authService.error!);
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showError(String message) {
    HeavyweightToast.show(context, message: message, variant: ToastVariant.error);
  }

  @override
  Widget build(BuildContext context) {
    HWLog.event('auth_screen_build', data: {'mode': _isLogin ? 'login' : 'signup'});
    return HeavyweightScaffold(
      title: 'AUTH',
      subtitle: _isLogin ? 'LOGIN' : 'SIGNUP',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
          child: Column(
            children: [
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
                          padding: const EdgeInsets.symmetric(vertical: HeavyweightTheme.spacingMd),
                          color: _isLogin ? HeavyweightTheme.primary : Colors.transparent,
                          child: Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: HeavyweightTheme.bodyMedium.copyWith(
                              color: _isLogin ? HeavyweightTheme.background : HeavyweightTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: HeavyweightTheme.spacingMd),
                          color: !_isLogin ? HeavyweightTheme.primary : Colors.transparent,
                          child: Text(
                            'SIGNUP',
                            textAlign: TextAlign.center,
                            style: HeavyweightTheme.bodyMedium.copyWith(
                              color: !_isLogin ? HeavyweightTheme.background : HeavyweightTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: HeavyweightTheme.spacingLg),
              
              // Email field
              TextField(
                controller: _emailController,
                style: HeavyweightTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  labelStyle: HeavyweightTheme.bodyMedium,
                  filled: true,
                  fillColor: HeavyweightTheme.background,
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
              
              const SizedBox(height: HeavyweightTheme.spacingMd),
              
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: HeavyweightTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: HeavyweightTheme.bodyMedium,
                  filled: true,
                  fillColor: HeavyweightTheme.background,
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
              
              const SizedBox(height: HeavyweightTheme.spacingLg),
              
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
                        padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                        decoration: BoxDecoration(
                          border: Border.all(color: HeavyweightTheme.error),
                          color: HeavyweightTheme.errorSurface,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'INCOMPLETE PROFILE',
                              textAlign: TextAlign.center,
                              style: HeavyweightTheme.bodyMedium,
                            ),
                            const SizedBox(height: HeavyweightTheme.spacingSm),
                            Text(
                              'MISSING: ${missing.join(', ')}',
                              textAlign: TextAlign.center,
                              style: HeavyweightTheme.bodyMedium,
                            ),
                            const SizedBox(height: HeavyweightTheme.spacingSm),
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
                      padding: const EdgeInsets.all(HeavyweightTheme.spacingMd),
                      decoration: BoxDecoration(
                        border: Border.all(color: HeavyweightTheme.secondary),
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
              const SizedBox(height: HeavyweightTheme.spacingLg),
              ],
              
              const SizedBox(height: HeavyweightTheme.spacingXl),
              
              // Action button
              ListenableBuilder(
                listenable: _authService,
                builder: (context, child) {
                  return CommandButton(
                    text: _isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
                    variant: ButtonVariant.primary,
                    isLoading: _authService.isLoading || _isLoading,
                    onPressed: (_authService.isLoading || _isLoading) ? null : _handleAuth,
                  );
                },
              ),
              
              if (_isLogin) ...[
                const SizedBox(height: HeavyweightTheme.spacingMd),
                CommandButton(
                  text: 'FORGOT PASSWORD',
                  variant: ButtonVariant.secondary,
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      _showError('EMAIL_REQUIRED_FOR_RESET');
                      return;
                    }
                    
                    if (!AuthService.isValidEmail(_emailController.text)) {
                      _showError('INVALID_EMAIL. CHECK_FORMAT.');
                      return;
                    }
                    
                    final success = await _authService.resetPassword(_emailController.text);
                    
                    if (!mounted) return;
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('RESET_SENT. CHECK_EMAIL.'),
                          backgroundColor: HeavyweightTheme.success,
                        ),
                      );
                    } else if (_authService.error != null) {
                      _showError(_authService.error!);
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
