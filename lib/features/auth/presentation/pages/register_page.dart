import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../controllers/auth_controller.dart';
import '../providers/verify_gate_provider.dart';
import '../widgets/input_textfield.dart';
import '../widgets/outline_social_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    await ref
        .read(authControllerProvider.notifier)
        .signUp(name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        role: 'customer');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ref
              .read(verifyEmailGateProvider.notifier)
              .state = true;
          context.go('/verify-email');
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível criar a conta. Tente novamente.')));
        },
      );
    });

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Criar conta',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Bem-vindo! Preencha seus dados para continuar.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Input(
                      focusNode: _nameFocus,
                      controller: _name,
                      hint: 'Nome completo',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Informe seu nome.';
                        if (value.length < 3) return 'Digite seu nome completo.';
                        return null;
                      },
                      prefix: SvgPicture.asset(
                        "assets/icons/person-name.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _emailFocus,
                      controller: _email,
                      hint: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
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
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _phoneFocus,
                      controller: _phone,
                      hint: 'Celular',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                      validator: (v) {
                        final raw = (v ?? '').trim();
                        if (raw.isEmpty) return 'Informe seu celular.';
                        final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length < 10) return 'Digite um celular válido (com DDD).';
                        if (digits.length > 11) return 'Digite um celular válido.';
                        return null;
                      },
                      prefix: SvgPicture.asset(
                        "assets/icons/phone.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _passwordFocus,
                      controller: _password,
                      hint: 'Senha',
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) {
                        final value = (v ?? '');
                        if (value
                            .trim()
                            .isEmpty) return 'Informe sua senha.';
                        if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
                        return null;
                      },
                      prefix: SvgPicture.asset(
                        "assets/icons/key.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                      ),
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        splashRadius: 20,
                        icon: SvgPicture.asset(
                          _obscure ? "assets/icons/no-see-key.svg" : "assets/icons/see-key.svg",
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(_passwordFocus.hasFocus ? const Color(0xFF0038BC) : const Color(0xFF9CA3AF), BlendMode.srcIn),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                          children: [
                            const TextSpan(text: 'Ao se cadastrar, você concorda com nossos '),
                            TextSpan(
                              text: 'Termos de Serviço',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF0038BC)),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {},
                            ),
                            const TextSpan(text: ' e '),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF0038BC)),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 48),
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
                        ),
                        child: Text('Começar a economizar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    OutlineSocialButton(
                      onTap: authState.isLoading ? () {} : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                      icon: SvgPicture.asset('assets/icons/google.svg'),
                      label: 'Registrar com Google',
                    ),
                    SizedBox(height: AppSpacing.md),
                    /*OutlineSocialButton(onTap: () {}, icon: SvgPicture.asset('assets/icons/apple.svg'), label: 'Entrar com Apple'),
                    SizedBox(height: AppSpacing.md),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já tem uma conta? ',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                        ),
                        InkWell(
                          onTap: () => context.go('/login'),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                            child: Text(
                              'Entrar',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFFEF8F00)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    TextButton(
                      style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                      onPressed: () => context.go('/home'),
                      child: Text(
                        "Voltar a página principal",
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                      ),
                    ),
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
