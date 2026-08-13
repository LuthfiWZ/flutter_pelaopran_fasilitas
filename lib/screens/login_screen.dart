import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Hero brand ----
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.panel),
                      border: Border.all(
                        color: AppColors.stone.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.ember,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.tag * 2),
                              ),
                              child: const Icon(
                                Icons.construction,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PELAPORAN FASILITAS',
                                    style: TextStyle(
                                      fontFamily: AppFonts.mono,
                                      fontSize: 10.5,
                                      letterSpacing: 1.6,
                                      color: AppColors.stone,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Selamat datang kembali',
                                    style: TextStyle(
                                      fontFamily: AppFonts.display,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.graphite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 44,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.ember,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Laporkan fasilitas rusak dan pantau progres '
                          'perbaikannya dalam satu tempat.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.stone,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Cue brand: 4 tahap perbaikan
                        const Row(
                          children: [
                            _StageDot(label: 'LAPOR', filled: true),
                            Expanded(child: _StageLine()),
                            _StageDot(label: 'CEK'),
                            Expanded(child: _StageLine()),
                            _StageDot(label: 'PERBAIKAN'),
                            Expanded(child: _StageLine()),
                            _StageDot(label: 'SELESAI'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  // ---- Form ----
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Email wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: AppSpace.md),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: AppSpace.lg),
                        PrimaryButton(
                          label: 'Masuk',
                          icon: Icons.login,
                          loading: auth.loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpace.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun?',
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text('Daftar'),
                            ),
                          ],
                        ),
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

class _StageDot extends StatelessWidget {
  final String label;
  final bool filled;

  const _StageDot({required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: filled ? AppColors.ember : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: filled ? AppColors.ember : AppColors.stone.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.mono,
            fontSize: 7.5,
            letterSpacing: 0.6,
            color: AppColors.stone,
          ),
        ),
      ],
    );
  }
}

class _StageLine extends StatelessWidget {
  const _StageLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: AppColors.stone.withValues(alpha: 0.35),
    );
  }
}
