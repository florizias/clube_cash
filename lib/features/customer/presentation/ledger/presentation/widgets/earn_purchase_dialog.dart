import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../app/theme/app_spacing.dart';
import '../../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../../auth/presentation/widgets/input_textfield.dart';
import '../../../../../partners/models/partner_model.dart';
import '../../../purchases/presentation/providers/purchase_requests_provider.dart';
import '../../../widgets/product_dropdown.dart';
import '../controllers/picked_receipt.dart';

Future<void> showEarnPurchaseDialog(BuildContext context, {required PartnerStore partner}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _EarnPurchaseDialog(partner: partner),
  );
}

class _EarnPurchaseDialog extends ConsumerStatefulWidget {
  final PartnerStore partner;

  const _EarnPurchaseDialog({required this.partner});

  @override
  ConsumerState<_EarnPurchaseDialog> createState() => _EarnPurchaseDialogState();
}

class _EarnPurchaseDialogState extends ConsumerState<_EarnPurchaseDialog> {
  final _formKey = GlobalKey<FormState>();

  final _productName = TextEditingController();
  final _productNameFocus = FocusNode();
  final _productValue = TextEditingController();
  final _productValueFocus = FocusNode();
  final _productReceipt = TextEditingController();
  final _productReceiptFocus = FocusNode();
  PartnerProduct? _selectedProduct;
  int _paymentIndex = -1;
  PickedReceipt? _receipt;

  bool _success = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _productNameFocus.addListener(() => setState(() {}));
    _productValueFocus.addListener(() => setState(() {}));
    _productReceiptFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _productName.dispose();
    _productNameFocus.dispose();
    _productValue.dispose();
    _productValueFocus.dispose();
    _productReceipt.dispose();
    _productReceiptFocus.dispose();
    super.dispose();
  }

  String _formatPrice(num value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  List<PartnerProduct> get _availableProducts {
    return widget.partner.products.where((product) => product.isActive).toList();
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_receipt == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Envie um comprovante.')));
      return;
    }

    final user = ref.read(firebaseUserProvider).value;
    final profile = ref.read(currentUserProfileProvider).value;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para enviar o comprovante.')));
      return;
    }

    final purchaseValue = _brlToDouble(_productValue.text);

    if (purchaseValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um valor válido.')));
      return;
    }

    setState(() => _loading = true);

    try {
      await ref
          .read(purchaseRequestActionsProvider)
          .createPurchaseRequest(
            userId: user.uid,
            userName: profile?.name ?? user.displayName ?? 'Cliente',
            userEmail: user.email ?? '',
            partner: widget.partner,
            nfCode: _productName.text.trim(),
            purchaseDate: DateTime.now(),
            purchaseValue: purchaseValue,
            receiptImage: _receipt!.file,
          );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _success = true;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível enviar: $error')));

      setState(() => _loading = false);
    }
  }

  double _brlToDouble(String text) {
    final cleaned = text.replaceAll('R\$', '').replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.').trim();

    return double.tryParse(cleaned) ?? 0.0;
  }

  void _onPickReceipt() async {
    final picked = await pickReceipt();
    if (picked == null) return;

    setState(() {
      _receipt = picked;
      _productReceipt.text = picked.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFFFFFFFF),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: _success ? _SuccessContent(onClose: () => Navigator.pop(context)) : formContent(),
      ),
    );
  }

  Widget formContent() {
    final TextStyle style = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF6B7280));

    return SizedBox(
      width: 340,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(24),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: SvgPicture.asset(
                          "assets/icons/arrow-back.svg",
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(Color(0xFF001952), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Negócio Realizado',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF001952)),
                  ),
                ],
              ),
            ),
            Divider(color: Color(0xFFE5E2DC), height: 0),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Nome do produto',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFEF8F00)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProductDropdown(
                products: _availableProducts,
                selected: _selectedProduct,
                onChanged: (product) {
                  setState(() {
                    _selectedProduct = product;
                    _productName.text = product?.title ?? '';
                    _productValue.text = product == null ? '' : _formatPrice(product.price);
                  });
                },
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Valor do produto',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFEF8F00)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Input(
                style: style,
                focusNode: _productValueFocus,
                controller: _productValue,
                hint: 'Selecione um produto',
                readOnly: true,
                prefix: SvgPicture.asset(
                  "assets/icons/dollar-square.svg",
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                ),
                validator: (v) {
                  final raw = (v ?? '').trim();
                  if (raw.isEmpty) return 'Selecione um produto';
                  final val = _brlToDouble(raw);
                  if (val <= 0) return 'Produto sem valor válido';
                  return null;
                },
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Nota fiscal / comprovante',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFEF8F00)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Input(
                style: style,
                focusNode: _productReceiptFocus,
                controller: _productReceipt,
                hint: 'Enviar arquivo',
                readOnly: true,
                onTap: _onPickReceipt,
                suffix: SvgPicture.asset(
                  "assets/icons/folder-up.svg",
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                ),
                validator: (_) {
                  if (_receipt == null) return 'Envie um comprovante';
                  return null;
                },
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Forma de pagamento',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFEF8F00)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FormField<int>(
                initialValue: _paymentIndex,
                validator: (v) {
                  if (_paymentIndex < 0) return 'Selecione uma forma de pagamento';
                  return null;
                },
                builder: (state) {
                  final hasError = state.hasError;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _Pill(
                              text: 'Dinheiro/Pix',
                              selected: _paymentIndex == 0,
                              onTap: () {
                                setState(() => _paymentIndex = 0);
                                state.didChange(0);
                                state.validate();
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _Pill(
                              text: 'Débito/Crédito',
                              selected: _paymentIndex == 1,
                              onTap: () {
                                setState(() => _paymentIndex = 1);
                                state.didChange(1);
                                state.validate();
                              },
                            ),
                          ),
                        ],
                      ),
                      if (hasError) ...[
                        SizedBox(height: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            state.errorText ?? '',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFDC2626)),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 14),
            Divider(color: Color(0xFFE5E2DC), height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF001952),
                    disabledBackgroundColor: const Color(0xFFE5E2DC),
                    foregroundColor: Color(0xFFFFFFFF),
                    disabledForegroundColor: Color(0xFF9CA3AF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: const Color(0x291F2933)),
                    ),
                  ),
                  child: _loading
                      ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_loading ? 'Enviando...' : 'Enviar para análise', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  final VoidCallback onClose;

  const _SuccessContent({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 437,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 8,
            width: 30,
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: BorderRadius.all(Radius.circular(4))),
          ),
          SizedBox(height: 60),
          Column(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Color(0xFFFFFFFF), size: 70),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Sucesso',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: AppSpacing.sm),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                child: Text(
                  'Tudo certo! Seu resgate foi realizado com sucesso.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001952),
                foregroundColor: Color(0xFFFFFFFF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Retornar as compras', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6ECF3) : Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? const Color(0xFF0A56BD) : const Color(0xFFE5E2DC)),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
      ),
    );
  }
}
