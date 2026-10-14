import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/theme/theme_exports.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/input_textfield.dart';
import '../../../share/widgets_exports.dart';

class PartnerChangePasswordPage extends ConsumerStatefulWidget {
  const PartnerChangePasswordPage({super.key});

  @override
  ConsumerState<PartnerChangePasswordPage> createState() => _PartnerChangePasswordPageState();
}

class _PartnerChangePasswordPageState extends ConsumerState<PartnerChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();

    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
    );
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final currentPassword = _currentPasswordCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A confirmação da senha não confere.')));
      return;
    }

    final user = ref.read(firebaseUserProvider).value;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado. Faça login novamente.')));
      return;
    }

    final email = user.email;

    if (email == null || email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível identificar o e-mail da conta.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final credential = EmailAuthProvider.credential(email: email.trim().toLowerCase(), password: currentPassword);

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);

      if (!mounted) return;

      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha atualizada com sucesso.')));

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message = 'Não foi possível atualizar a senha.';

      if (error.code == 'wrong-password' || error.code == 'invalid-credential') {
        message = 'A senha atual está incorreta.';
      }

      if (error.code == 'weak-password') {
        message = 'A nova senha é muito fraca.';
      }

      if (error.code == 'requires-recent-login') {
        message = 'Por segurança, faça login novamente antes de alterar a senha.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar senha: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    final headerName = profileAsync.when(
      data: (profile) {
        final name = profile?.name.trim() ?? '';
        if (name.isEmpty) return 'Usuário';
        return name.split(RegExp(r'\s+')).first;
      },
      loading: () => 'Carregando...',
      error: (_, _) => 'Usuário',
    );
    final photoUrl = profileAsync.when(data: (profile) => profile?.photoUrl ?? '', loading: () => '', error: (_, _) => '');
    final greeting = getGreeting();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF001E68),
                border: Border(bottom: BorderSide(color: Color(0xFFE6ECF3))),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 36,
                      height: 36,
                      color: const Color(0xFFFFFFFF),
                      child: photoUrl.trim().isNotEmpty
                          ? Image.network(
                              photoUrl.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return const Icon(Icons.person, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$greeting, $headerName',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                  //circleAction(svgAsset: 'assets/icons/notification.svg', onTap: () {}),
                  SizedBox(width: AppSpacing.sm),
                  circleAction(svgAsset: 'assets/icons/support.svg', onTap: () {}),
                ],
              ),
            ),
            Container(
              height: 46,
              color: const Color(0xFF001E68),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(24),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: SvgPicture.asset(
                          width: 10,
                          height: 10,
                          "assets/icons/arrow-back.svg",
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Alteração de Senha',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Senha Atual'),
                      SizedBox(height: AppSpacing.xs),
                      Input(
                        focusNode: _currentPasswordFocus,
                        controller: _currentPasswordCtrl,
                        hint: 'Digitar...',
                        obscureText: _obscureCurrentPassword,
                        prefix: SvgPicture.asset(
                          "assets/icons/key.svg",
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                        ),
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                          splashRadius: 20,
                          icon: SvgPicture.asset(
                            _obscureCurrentPassword ? "assets/icons/no-see-key.svg" : "assets/icons/see-key.svg",
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              _currentPasswordFocus.hasFocus ? const Color(0xFF0038BC) : const Color(0x291F2933),
                              BlendMode.srcIn,
                            ),
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
                      SizedBox(height: 14),

                      _label('Nova Senha'),
                      SizedBox(height: AppSpacing.xs),
                      Input(
                        focusNode: _newPasswordFocus,
                        controller: _newPasswordCtrl,
                        hint: 'Digitar...',
                        obscureText: _obscureNewPassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        prefix: SvgPicture.asset(
                          "assets/icons/key.svg",
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                        ),
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                          splashRadius: 20,
                          icon: SvgPicture.asset(
                            _obscureNewPassword ? "assets/icons/no-see-key.svg" : "assets/icons/see-key.svg",
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              _newPasswordFocus.hasFocus ? const Color(0xFF0038BC) : const Color(0x291F2933),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) {
                          final value = (v ?? '');
                          if (value.trim().isEmpty) return 'Informe sua nova senha.';
                          if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
                          return null;
                        },
                      ),
                      SizedBox(height: 14),

                      _label('Confirmar Nova Senha'),
                      SizedBox(height: AppSpacing.xs),
                      Input(
                        focusNode: _confirmPasswordFocus,
                        controller: _confirmPasswordCtrl,
                        hint: 'Digitar...',
                        obscureText: _obscureConfirmPassword,
                        prefix: SvgPicture.asset(
                          "assets/icons/key.svg",
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                        ),
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          splashRadius: 20,
                          icon: SvgPicture.asset(
                            _obscureConfirmPassword ? "assets/icons/no-see-key.svg" : "assets/icons/see-key.svg",
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              _confirmPasswordFocus.hasFocus ? const Color(0xFF0038BC) : const Color(0x291F2933),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) {
                          final value = (v ?? '').trim();
                          final newPassword = _newPasswordCtrl.text.trim();

                          if (value.isEmpty) return 'Confirme sua nova senha.';
                          if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
                          if (value != newPassword) return 'As senhas não conferem.';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0038BC),
                    foregroundColor: Color(0xFFFFFFFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Atualizar Senha', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
