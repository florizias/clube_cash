import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../controllers/auth_controller.dart';
import '../widgets/input_textfield.dart';
import '../widgets/password_reset_success_sheet.dart';

class RecoverPasswordPage extends ConsumerStatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  ConsumerState<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends ConsumerState<RecoverPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final email = _email.text.trim().toLowerCase();

    await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(email);

    final result = ref.read(authControllerProvider);

    if (!mounted) return;

    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível enviar o e-mail. Tente novamente.')));
      return;
    }

    await PasswordResetSuccessSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.sm),
                    SizedBox(height: 96, width: 96, child: Image.asset("assets/images/reset-password.png", fit: BoxFit.fill)),
                    SizedBox(height: 40),
                    Text(
                      'Não consegue entrar?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Informe o e-mail da sua conta e enviaremos\num link para redefinir sua senha.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.3),
                    ),
                    SizedBox(height: 40),
                    Input(
                      focusNode: _emailFocus,
                      controller: _email,
                      hint: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) {
                        final value = (v ?? '').trim().toLowerCase();
                        if (value.isEmpty) return 'Informe seu e-mail.';
                        final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                        if (!ok) return 'Digite um e-mail válido.';
                        return null;
                      },
                      prefix: SvgPicture.asset(
                        "assets/icons/email.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Color(0xFFFFFFFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          overlayColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text('Redefinir senha', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => context.go('/login'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          overlayColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text(
                          'Voltar ao login',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
