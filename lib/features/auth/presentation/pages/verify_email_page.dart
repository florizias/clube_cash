import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../providers/verify_gate_provider.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool _loading = false;
  bool _resent = false;

  int _cooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown -= 1);
      }
    });
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;

    setState(() {
      _loading = true;
      _resent = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sessão expirou. Faça login novamente.')));
        ref.read(verifyEmailGateProvider.notifier).state = false;
        context.go('/login');
        return;
      }

      await user.sendEmailVerification();

      if (!mounted) return;
      setState(() => _resent = true);
      _startCooldown();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail de verificação reenviado.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível reenviar. Tente novamente.')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkVerified() async {
    setState(() => _loading = true);

    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sessão expirou. Faça login novamente.')));
        ref.read(verifyEmailGateProvider.notifier).state = false;
        context.go('/login');
        return;
      }

      await user.reload();
      final refreshed = auth.currentUser;

      final verified = refreshed?.emailVerified ?? false;

      if (!mounted) return;

      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail verificado! Agora faça login para continuar.')));
        await auth.signOut();
        ref.read(verifyEmailGateProvider.notifier).state = false;

        if (!mounted) return;
        context.go('/login');
        return;
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível validar agora. Tente novamente.')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 96, width: 96, child: Image.asset("assets/images/verify-email.png", fit: BoxFit.fill)),
                  SizedBox(height: 18),
                  Text(
                    'Verifique seu e-mail',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    email.isEmpty
                        ? 'Enviamos um link de verificação para o seu e-mail. Abra a mensagem e toque no link para confirmar.'
                        : 'Enviamos um link de verificação para:\n$email\n\nAbra a mensagem e toque no link para confirmar.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, height: 1.35, color: const Color(0xFF64748B)),
                  ),
                  SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dicas rápidas',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _bullet('Confira a caixa de entrada e o spam/lixo eletrônico.'),
                        _bullet('Se você abriu o e-mail em outro dispositivo, volte aqui e toque em “Já verifiquei”.'),
                        _bullet('Não recebeu? Reenvie quando o botão liberar.'),
                      ],
                    ),
                  ),
                  SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _checkVerified,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Color(0xFFFFFFFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        overlayColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: _loading
                          ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('Já verifiquei', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: (_loading || _cooldown > 0) ? null : _resend,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        foregroundColor: const Color(0xFF0F172A),
                        overlayColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        _cooldown > 0 ? 'Reenviar e-mail (${_cooldown}s)' : 'Reenviar e-mail',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  if (_resent) ...[
                    SizedBox(height: 10),
                    Text(
                      'E-mail reenviado. Se não aparecer, verifique o spam.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                    ),
                  ],
                  SizedBox(height: 18),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            ref.read(verifyEmailGateProvider.notifier).state = false;
                            context.go('/login');
                          },
                    style: TextButton.styleFrom(overlayColor: Colors.transparent, splashFactory: NoSplash.splashFactory),
                    child: Text(
                      'Voltar para login',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0038BC)),
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

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 6,
            width: 6,
            decoration: const BoxDecoration(color: Color(0xFF0038BC), shape: BoxShape.circle),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.35, color: const Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }
}
