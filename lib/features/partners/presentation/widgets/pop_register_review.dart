import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/partner_model.dart';
import '../providers/partner_reviews_provider.dart';

Future<void> showRegisterReviewPop(BuildContext context, PartnerStore partner) {
  return showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'register_review',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, anim1, anim2) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: const SizedBox.expand()),
            ),
          ),
          _RegisterReviewDialog(partner: partner),
        ],
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(curved), child: child),
      );
    },
  );
}

class _RegisterReviewDialog extends ConsumerStatefulWidget {
  final PartnerStore partner;

  const _RegisterReviewDialog({required this.partner});

  @override
  ConsumerState<_RegisterReviewDialog> createState() => _RegisterReviewDialogState();
}

class _RegisterReviewDialogState extends ConsumerState<_RegisterReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentCtrl = TextEditingController();

  double _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(partnerReviewActionsProvider).sendReview(partner: widget.partner, rating: _rating, comment: _commentCtrl.text.trim());

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avaliação enviada com sucesso.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível enviar a avaliação: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 360,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 18))],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Avaliar loja',
                            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                          ),
                        ),
                        IconButton(
                          onPressed: _isSubmitting ? null : () => Navigator.of(context, rootNavigator: true).pop(),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.partner.name,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final value = index + 1;
                        final selected = value <= _rating;

                        return IconButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                            setState(() {
                              _rating = value.toDouble();
                            });
                          },
                          icon: Icon(selected ? Icons.star_rounded : Icons.star_border_rounded, size: 34, color: const Color(0xFFF59E0B)),
                        );
                      }),
                    ),

                    Text(
                      '${_rating.toStringAsFixed(0)} de 5',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _commentCtrl,
                      maxLines: 5,
                      minLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Conte como foi sua experiência com a loja...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0038BC)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDC2626)),
                        ),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.isEmpty) {
                          return 'Escreva sua avaliação.';
                        }

                        if (text.length < 5) {
                          return 'Escreva uma avaliação um pouco maior.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0038BC),
                          foregroundColor: const Color(0xFFFFFFFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          _isSubmitting ? 'Enviando...' : 'Enviar avaliação',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
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
