import 'dart:ui';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/theme_exports.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../customer/presentation/ledger/presentation/controllers/picked_receipt.dart';
import '../../../customer/presentation/purchases/presentation/providers/purchase_requests_provider.dart';
import '../../../customer/presentation/purchases/presentation/widgets/qr_purchase_handler.dart';
import '../../models/partner_model.dart';
import 'success_purchase_pop.dart';

Future<void> showRegisterPurchasePop(BuildContext context, PartnerStore partner) {
  return showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'register_purchase',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, anim1, anim2) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: SizedBox.expand()),
            ),
          ),
          _RegisterPurchaseDialog(parentContext: context, partner: partner),
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

class _RegisterPurchaseDialog extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  final PartnerStore partner;

  const _RegisterPurchaseDialog({required this.parentContext, required this.partner});

  @override
  ConsumerState<_RegisterPurchaseDialog> createState() => _RegisterPurchaseDialogState();
}

class _RegisterPurchaseDialogState extends ConsumerState<_RegisterPurchaseDialog> with SingleTickerProviderStateMixin {
  final _manualFormKey = GlobalKey<FormState>();
  late final TabController _tab;
  int _tabIndex = 0;
  XFile? _receiptImage;
  Uint8List? _receiptImageBytes;
  bool _isSubmitting = false;
  bool _didReadQrCode = false;
  late final TextEditingController _establishmentCtrl;
  final _dateCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _nfCtrl = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _establishmentCtrl = TextEditingController(text: widget.partner.name);
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return;
      setState(() => _tabIndex = _tab.index);
    });
  }

  @override
  void dispose() {
    _establishmentCtrl.dispose();
    _dateCtrl.dispose();
    _valueCtrl.dispose();
    _nfCtrl.dispose();
    _tab.dispose();
    super.dispose();
  }

  void _clearForm() {
    _receiptImage = null;
    _receiptImageBytes = null;

    _establishmentCtrl.clear();
    _dateCtrl.clear();
    _valueCtrl.clear();
    _nfCtrl.clear();

    _selectedDate = null;

    _tab.animateTo(0);
    _tabIndex = 0;

    setState(() {});
  }

  Future<void> _pickReceiptImage() async {
    try {
      final picked = await pickReceipt();

      if (picked == null) return;

      if (!mounted) return;

      setState(() {
        _receiptImage = picked.file;
        _receiptImageBytes = picked.bytes;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível carregar o comprovante: $error')));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('pt', 'BR'),
    );

    if (picked == null) return;

    setState(() => _selectedDate = picked);

    final dd = picked.day.toString().padLeft(2, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    final yyyy = picked.year.toString();
    _dateCtrl.text = '$dd/$mm/$yyyy';
  }

  double brlToDouble(String text) {
    final cleaned = text.replaceAll('R\$', '').replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.').trim();

    return double.tryParse(cleaned) ?? 0.0;
  }

  Future<void> _submitManual() async {
    if (_isSubmitting) return;

    final ok = _manualFormKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Envie a imagem do comprovante.')));
      return;
    }

    final purchaseValue = brlToDouble(_valueCtrl.text);

    if (purchaseValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um valor válido para a compra.')));
      return;
    }

    await sendPurchaseRequest(
      nfCode: _nfCtrl.text.trim(),
      purchaseDate: _selectedDate ?? DateTime.now(),
      purchaseValue: purchaseValue,
      receiptImage: _receiptImage,
      source: 'manual',
      qrCodeRaw: '',
    );
  }

  Future<void> sendPurchaseRequest({
    required String nfCode,
    required DateTime purchaseDate,
    required double purchaseValue,
    required XFile? receiptImage,
    required String source,
    required String qrCodeRaw,
  }) async {
    if (_isSubmitting) return;

    final user = ref.read(firebaseUserProvider).value;
    final profile = ref.read(currentUserProfileProvider).value;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para enviar a nota fiscal.')));

      setState(() {
        _didReadQrCode = false;
      });

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(purchaseRequestActionsProvider)
          .createPurchaseRequest(
            userId: user.uid,
            userName: profile?.name ?? user.displayName ?? 'Cliente',
            userEmail: user.email ?? '',
            partner: widget.partner,
            nfCode: nfCode,
            purchaseDate: purchaseDate,
            purchaseValue: purchaseValue,
            receiptImage: receiptImage,
            source: source,
            qrCodeRaw: qrCodeRaw,
          );

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      if (!widget.parentContext.mounted) return;

      await showPurchaseSuccessPop(widget.parentContext);

      if (!mounted) return;

      _clearForm();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível enviar a nota fiscal: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _didReadQrCode = false;
        });
      }
    }
  }

  Widget _buildReceiptPicker({double height = 150}) {
    if (_receiptImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: height,
              child: Image.memory(_receiptImageBytes!, fit: BoxFit.cover),
            ),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.10))),
            InkWell(
              onTap: _isSubmitting ? null : _pickReceiptImage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/edit.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _isSubmitting ? null : _pickReceiptImage,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAEFF6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(color: Color(0xFFE6ECF3), shape: BoxShape.circle),
              child: SvgPicture.asset('assets/icons/upload.svg', colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn)),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Anexar comprovante',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF000000)),
            ),
            const SizedBox(height: 2),
            Text(
              'Toque para enviar imagem',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final maxW = c.maxWidth;
          final maxH = c.maxHeight;

          final dialogMaxWidth = maxW < 520 ? maxW - 24 : 560.0;
          final dialogMaxHeight = maxH * 0.90;

          return Center(
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 350, maxHeight: dialogMaxHeight),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: dialogMaxWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 18))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 10, 8),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/scan.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(Color(0xFFEF8F00), BlendMode.srcIn),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Registrar Compra',
                                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  splashRadius: 18,
                                  icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Ganhe cashback validando suas notas fiscais.',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TabBar(
                              controller: _tab,
                              indicatorColor: const Color(0xFFEF8F00),
                              indicatorWeight: 1.5,
                              dividerColor: Colors.transparent,
                              labelColor: const Color(0xFF0F172A),
                              unselectedLabelColor: const Color(0x291F2933),
                              labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                              unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                              tabs: const [
                                Tab(text: 'Escanear'),
                                Tab(text: 'Digitar Dados'),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: _tabIndex == 0 ? _buildScanTab(context) : _buildManualTab(context),
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
        },
      ),
    );
  }

  Widget _buildScanTab(BuildContext context) {
    return Column(
      key: const ValueKey('scan'),
      children: [
        SizedBox(
          height: 313,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: MobileScanner(
              onDetect: (capture) {
                if (_didReadQrCode || _isSubmitting) return;

                final barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;

                final rawCode = barcodes.first.rawValue;
                if (rawCode == null || rawCode.trim().isEmpty) return;

                setState(() {
                  _didReadQrCode = true;
                });

                handleQrCodeRead(
                  context,
                  rawCode: rawCode.trim(),
                  partner: widget.partner,
                  isSubmitting: _isSubmitting,
                  onReleaseScanner: () {
                    if (!mounted) return;

                    setState(() {
                      _didReadQrCode = false;
                    });
                  },
                  onSendQrPurchase: ({required nfCode, required purchaseDate, required purchaseValue, required qrCodeRaw}) {
                    return sendPurchaseRequest(
                      nfCode: nfCode,
                      purchaseDate: purchaseDate,
                      purchaseValue: purchaseValue,
                      receiptImage: null,
                      source: 'qr_code',
                      qrCodeRaw: qrCodeRaw,
                    );
                  },
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0B84C)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/attention.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(Color(0xFFE0B84C), BlendMode.srcIn),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Aponte a câmera para o QR Code da nota fiscal. A leitura será feita automaticamente.',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFFE0B84C), height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab(BuildContext context) {
    bool hover = false;

    InputDecoration dec({required String hint, required bool hover, Widget? suffix, bool enabled = true}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: enabled ? const Color(0xFFFFFFFF) : const Color(0xFFF1F1F1),
        hoverColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: suffix,
        border: hover && enabled
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x291F2933)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
        ),
      );
    }

    return Form(
      key: _manualFormKey,
      child: Column(
        key: const ValueKey('manual'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estabelecimento',
            style: GoogleFonts.inter(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.xs),
          MouseRegion(
            onEnter: (_) => setState(() => hover = true),
            onExit: (_) => setState(() => hover = false),
            child: TextFormField(
              controller: _establishmentCtrl,
              enabled: false,
              style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w400),
              decoration: dec(hint: '—', hover: hover, enabled: false),
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Data ',
                        style: GoogleFonts.inter(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: '*',
                            style: GoogleFonts.inter(color: Color(0xFFEF8F00), fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    MouseRegion(
                      onEnter: (_) => setState(() => hover = true),
                      onExit: (_) => setState(() => hover = false),
                      child: TextFormField(
                        controller: _dateCtrl,
                        readOnly: true,
                        onTap: _pickDate,
                        style: GoogleFonts.inter(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w400),
                        decoration: dec(
                          hint: 'dd/mm/aaaa',
                          hover: hover,
                          suffix: SizedBox(
                            width: 10,
                            height: 10,
                            child: Transform.scale(
                              scale: 0.45,
                              child: SvgPicture.asset(
                                'assets/icons/calendar.svg',
                                fit: BoxFit.contain,
                                colorFilter: const ColorFilter.mode(Color(0xFFEF8F00), BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        validator: (_) {
                          if ((_dateCtrl.text).trim().isEmpty) return 'Informe a data.';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Valor (R\$) ',
                        style: GoogleFonts.inter(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: '*',
                            style: GoogleFonts.inter(color: Color(0xFFEF8F00), fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    MouseRegion(
                      onEnter: (_) => setState(() => hover = true),
                      onExit: (_) => setState(() => hover = false),
                      child: TextFormField(
                        controller: _valueCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w400),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
                        decoration: dec(hint: 'R\$ 0,00', hover: hover),
                        validator: (_) {
                          final raw = _valueCtrl.text.trim();
                          if (raw.isEmpty) return 'Informe o valor.';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text.rich(
            TextSpan(
              text: 'Código da nota fiscal (44 DÍGITOS) ',
              style: GoogleFonts.inter(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w600),
              children: [
                TextSpan(
                  text: '*',
                  style: GoogleFonts.inter(color: Color(0xFFEF8F00), fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          MouseRegion(
            onEnter: (_) => setState(() => hover = true),
            onExit: (_) => setState(() => hover = false),
            child: TextFormField(
              controller: _nfCtrl,
              keyboardType: TextInputType.number,
              maxLength: 44,
              style: GoogleFonts.inter(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w400),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(44)],
              decoration: dec(hint: 'Digite aqui...', hover: hover).copyWith(counterText: ''),
              validator: (_) {
                final v = _nfCtrl.text.trim();
                if (v.isEmpty) return 'Informe o código.';
                if (v.length != 44) return 'O código deve ter 44 dígitos.';
                return null;
              },
            ),
          ),
          SizedBox(height: 14),
          Text.rich(
            TextSpan(
              text: 'Comprovante ',
              style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w600),
              children: [
                TextSpan(
                  text: '*',
                  style: GoogleFonts.inter(color: const Color(0xFFEF8F00), fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          _buildReceiptPicker(height: 160),
          SizedBox(height: 100),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF8F00),
                foregroundColor: Color(0xFFFFFFFF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(_isSubmitting ? 'Enviando...' : 'Confirmar Envio', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
