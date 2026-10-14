import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_spacing.dart';
import '../providers/account_deactivation_provider.dart';

class CustomerDeleteAccountPage extends ConsumerStatefulWidget {
  const CustomerDeleteAccountPage({super.key});

  @override
  ConsumerState<CustomerDeleteAccountPage> createState() => _CustomerDeleteAccountPageState();
}

class _CustomerDeleteAccountPageState extends ConsumerState<CustomerDeleteAccountPage> {
  final _confirmCtrl = TextEditingController();
  bool _isSaving = false;
  static const _confirmText = 'EU DELETO MINHA CONTA';

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canDelete => _confirmCtrl.text.trim() == _confirmText;

  void _onDelete() async {
    if (!_canDelete || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(accountDeactivationActionsProvider).deactivateCurrentAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta deletada com sucesso.')));

      context.go('/login');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível deletar a conta: $error')));
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
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFC63B2B),
                border: Border(bottom: BorderSide(color: Color(0xFFE6ECF3))),
              ),
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
                      'Excluir minha conta',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFC63B2B),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(color: Color(0xFFC0392B), shape: BoxShape.circle),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/attention-circle.svg',
                        width: 140,
                        height: 140,
                        colorFilter: ColorFilter.mode(Color(0xFFFCEAEA), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Você tem certeza?',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFFFCEAEA)),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Esta ação é permanente e não pode ser desfeita.\n'
                        'Você perderá todos os seus pontos, cashbacks\n'
                        'acumulados e histórico de compras.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFFFCEAEA), height: 1.45),
                  ),
                  SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569)),
                                children: [
                                  const TextSpan(text: 'Para confirmar, digite '),
                                  TextSpan(
                                    text: _confirmText,
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFC0392B)),
                                  ),
                                  const TextSpan(text: ':'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _confirmCtrl,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF111827)),
                            decoration: InputDecoration(
                              hoverColor: Colors.transparent,
                              hintText: 'Digite aqui',
                              hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE6ECF3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFC63B2B), width: 1.2),
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _canDelete && !_isSaving ? _onDelete : null,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return const Color(0xFFC63B2B).withValues(alpha: 0.45);
                                  }
                                  return const Color(0xFFC0392B);
                                }),
                                foregroundColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
                                elevation: WidgetStateProperty.all(0),
                                shadowColor: WidgetStateProperty.all(Colors.transparent),
                                surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                                overlayColor: WidgetStateProperty.all(Colors.transparent),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                              child: Text(
                                _isSaving ? 'Deletando...' : 'Confirmar Exclusão',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(const Color(0xFFE6ECF3)),
                                foregroundColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                                elevation: WidgetStateProperty.all(0),
                                shadowColor: WidgetStateProperty.all(Colors.transparent),
                                surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                                overlayColor: WidgetStateProperty.all(Colors.transparent),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                              child: Text('Cancelar e Voltar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
