import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../providers/app_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authFormProvider.notifier).submit(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
  }

  void _toggleMode() {
    ref.read(authFormProvider.notifier).toggleMode();
    _formKey.currentState?.reset();
    _animCtrl..reset()..forward();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFormProvider);
    final isLogin = authState.isLogin;
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 56),
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: AppTheme.tealGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.directions_car, size: 36, color: Colors.black),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    isLogin ? 'Welcome\nback.' : 'Create your\naccount.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700, height: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin
                        ? 'Sign in to track your vehicles.'
                        : 'Start tracking your vehicle maintenance.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: const Color(0xFF7B8FA6)),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (!isLogin && v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (authState.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppTheme.error.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppTheme.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(authState.errorMessage!,
                                      style: const TextStyle(
                                          color: AppTheme.error, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.primaryDark),
                                    ),
                                  )
                                : Text(isLogin ? 'Sign In' : 'Create Account'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogin
                                  ? "Don't have an account? "
                                  : 'Already have an account? ',
                              style:
                                  const TextStyle(color: Color(0xFF7B8FA6)),
                            ),
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Text(
                                isLogin ? 'Sign Up' : 'Sign In',
                                style: const TextStyle(
                                    color: AppTheme.neonTeal,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
