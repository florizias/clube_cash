import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../controllers/auth_controller.dart';
import '../models/partner_rewiew.dart';
import '../providers/auth_providers.dart';
import '../widgets/input_textfield.dart';
import '../widgets/outline_social_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<PartnerReviewInfo> loadPartnerReviewInfo({required String uid, required String fallbackStatus, required String fallbackEmail}) async {
    final snap = await FirebaseFirestore.instance.collection('store_requests').doc(uid).get();

    final data = snap.data() ?? <String, dynamic>{};

    return PartnerReviewInfo(
      status: data['status']?.toString() ?? fallbackStatus,
      rejectionReason: data['rejectionReason']?.toString() ?? data['reason']?.toString() ?? '',
      storeName: data['storeName']?.toString() ?? data['name']?.toString() ?? data['businessName']?.toString() ?? '',
      email: data['email']?.toString() ?? fallbackEmail,
    );
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    await ref.read(authControllerProvider.notifier).signIn(email: _email.text.trim(), password: _password.text);

    final authResult = ref.read(authControllerProvider);

    if (authResult.hasError) {
      return;
    }

    final authRepo = ref.read(authRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);

    final user = authRepo.currentUser;

    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível identificar o usuário.')));
      return;
    }

    final profile = await userRepo.getProfile(user.uid);

    if (!mounted) return;

    if (profile == null) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil não encontrado.')));
      return;
    }

    if (profile.status == 'blocked') {
      await ref.read(authControllerProvider.notifier).signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta bloqueada.')));
      return;
    }

    if (!user.emailVerified) {
      context.go('/verify-email');
      return;
    }

    if (profile.role == 'partner' && profile.status != 'active') {
      context.go('/partner/status');
      return;
    }

    if (profile.role == 'admin') {
      context.go('/admin/home');
    } else if (profile.role == 'partner') {
      context.go('/partner/home');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, st) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível entrar. Verifique seus dados.')));
        },
      );
    });

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Entrar na conta',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Que bom te ver de novo! Insira seus dados para continuar.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Input(
                      focusNode: _emailFocus,
                      controller: _email,
                      hint: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      prefix: SvgPicture.asset(
                        "assets/icons/email.svg",
                        height: 20,
                        width: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Informe seu e-mail.';
                        final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                        if (!ok) return 'Digite um e-mail válido.';
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _passwordFocus,
                      controller: _password,
                      hint: 'Senha',
                      obscureText: _obscure,
                      prefix: SvgPicture.asset(
                        "assets/icons/key.svg",
                        height: 20,
                        width: 20,
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) {
                        final value = (v ?? '');
                        if (value.trim().isEmpty) return 'Informe sua senha.';
                        if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Esqueceu a senha? ',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                        ),
                        InkWell(
                          onTap: () => context.go('/recover'),
                          borderRadius: BorderRadius.circular(8),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                            child: Text(
                              'Redefinir senha',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0038BC)),
                            ),
                          ),
                        ),
                      ],
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
                          overlayColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text('Começar a economizar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    OutlineSocialButton(
                      onTap: authState.isLoading
                          ? () {}
                          : () async {
                              await ref.read(authControllerProvider.notifier).signInWithGoogle();
                              if (!context.mounted) return;
                              context.go('/home');
                            },
                      icon: SvgPicture.asset('assets/icons/google.svg'),
                      label: 'Entrar com Google',
                    ),
                    SizedBox(height: AppSpacing.md),
                    /*OutlineSocialButton(onTap: () {}, icon: SvgPicture.asset('assets/icons/apple.svg'), label: 'Cadastrar com Apple'),
                    SizedBox(height: AppSpacing.md),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Não tem uma conta? ',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                        ),
                        InkWell(
                          onTap: () => context.go('/register-choice'),
                          borderRadius: BorderRadius.circular(8),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                            child: Text(
                              'Criar conta',
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
