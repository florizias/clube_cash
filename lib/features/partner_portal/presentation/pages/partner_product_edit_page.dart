import 'dart:ui';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/theme_exports.dart';
import '../../../share/widgets_exports.dart';
import '../providers/partner_products_provider.dart';
import '../widgets/saving_overlay.dart';

class PartnerProductEditPage extends ConsumerStatefulWidget {
  final String productId;

  const PartnerProductEditPage({super.key, required this.productId});

  @override
  ConsumerState<PartnerProductEditPage> createState() => _PartnerProductEditPageState();
}

class _PartnerProductEditPageState extends ConsumerState<PartnerProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isDeleting = false;
  XFile? _selectedImage;
  bool _isSaving = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _cashbackCtrl;
  late final TextEditingController _priceCtrl;

  bool _didFillForm = false;
  bool _isActive = true;
  String _currentImageUrl = '';
  String _selectedCategory = 'Alimentação';
  Uint8List? _selectedImageBytes;
  final List<String> _categories = ['Alimentação', 'Bebidas', 'Sobremesas', 'Moda', 'Beleza', 'Serviços'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _stockCtrl = TextEditingController();
    _cashbackCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
  }

  Future<void> _fillFormOnce(dynamic product) async {
    if (_didFillForm) return;

    _nameCtrl.text = product.name;
    _descriptionCtrl.text = product.description;
    _stockCtrl.text = product.stock.toString();
    _cashbackCtrl.text = '${product.cashbackLabel.toStringAsFixed(0)}%';
    _priceCtrl.text = _formatPriceForInput(product.price);

    _isActive = product.isActive;
    _currentImageUrl = product.imageUrl;

    if (_categories.contains(product.category)) {
      _selectedCategory = product.category;
    }

    _didFillForm = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _stockCtrl.dispose();
    _cashbackCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  String _formatPriceForInput(num value) {
    if (value <= 0) return '';
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  double _brlToDouble(String text) {
    final cleaned = text.replaceAll('R\$', '').replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.').trim();

    return double.tryParse(cleaned) ?? 0;
  }

  TextStyle get _labelStyle => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569));

  Widget _sectionTitle({required String svgIcon, required Color iconColor, required Color iconBg, required String title}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(5)),
          child: SvgPicture.asset(svgIcon, width: 12, height: 12, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final price = _brlToDouble(_priceCtrl.text);

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um preço válido.')));
      return;
    }

    try {
      await ref
          .read(partnerProductsActionsProvider)
          .updateCurrentPartnerProduct(
            productId: widget.productId,
            name: _nameCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            price: price,
            stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
            category: _selectedCategory,
            isActive: _isActive,
            image: _selectedImage,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto atualizado com sucesso.')));

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível atualizar o produto: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Excluir produto?',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          ),
          content: Text(
            'Essa ação não poderá ser desfeita. Deseja mesmo excluir este produto?',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF64748B)),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC0392B),
                foregroundColor: const Color(0xFFFFFFFF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Excluir', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref.read(partnerProductsActionsProvider).deleteCurrentPartnerProduct(productId: widget.productId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto excluído com sucesso.')));

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível excluir o produto: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImage = image;
      _selectedImageBytes = bytes;
    });
  }

  Widget _productImageFallback() {
    return Container(
      color: const Color(0xFFE6ECF3),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/icons/gallery.svg',
        width: 28,
        height: 28,
        colorFilter: const ColorFilter.mode(Color(0xFF94A3B8), BlendMode.srcIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(partnerProductByIdProvider(widget.productId));

    return productAsync.when(
      loading: () {
        return const Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: Center(child: Text('Erro ao carregar produto: $error', textAlign: TextAlign.center)),
        );
      },
      data: (product) {
        if (product == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFFFFF),
            body: Center(child: Text('Produto não encontrado.')),
          );
        }

        _fillFormOnce(product);

        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SafeArea(
            top: true,
            bottom: true,
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            child: SvgPicture.asset(
                              'assets/icons/arrow-back.svg',
                              width: 8,
                              height: 8,
                              colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                            ),
                          ),
                          Text(
                            'Edição de Produto',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0038BC)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              sectionCard(
                                margin: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status de Exibição',
                                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF000000)),
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Produtos ocultos não aparecem no catálogo para os clientes, mas continuam salvos no seu painel.',
                                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF)),
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFFFFF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/see-key.svg',
                                            width: 16,
                                            height: 16,
                                            colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Produto Ativo',
                                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF0F172A)),
                                            ),
                                          ),
                                          Switch(
                                            value: _isActive,
                                            onChanged: (value) {
                                              setState(() => _isActive = value);
                                            },
                                            activeThumbColor: Color(0xFFFFFFFF),
                                            activeTrackColor: const Color(0xFF1E9E5A),
                                            inactiveThumbColor: const Color(0xFFD1D5DB),
                                            inactiveTrackColor: Color(0xFFFFFFFF),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              sectionCard(
                                margin: 12,
                                color: Color(0xFFFAFAF8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle(
                                      svgIcon: 'assets/icons/alert.svg',
                                      iconColor: const Color(0xFFEF8F00),
                                      iconBg: const Color(0xFFFFF3D6),
                                      title: 'Informações Gerais',
                                    ),
                                    SizedBox(height: 14),
                                    Text('Nome do Produto', style: _labelStyle),
                                    SizedBox(height: AppSpacing.xs),
                                    TextFormField(
                                      controller: _nameCtrl,
                                      decoration: InputDecoration(hintText: 'Digite o nome'),
                                      validator: (value) {
                                        if ((value ?? '').trim().isEmpty) {
                                          return 'Informe o nome do produto';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 14),
                                    Text('Descrição Detalhada', style: _labelStyle),
                                    SizedBox(height: AppSpacing.xs),
                                    TextFormField(
                                      controller: _descriptionCtrl,
                                      maxLines: 3,
                                      decoration: InputDecoration(hintText: 'Descreva o produto'),
                                    ),
                                    SizedBox(height: 14),
                                    Text('Preço do Produto', style: _labelStyle),
                                    SizedBox(height: AppSpacing.xs),
                                    TextFormField(
                                      controller: _priceCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
                                      decoration: InputDecoration(
                                        hintText: '0,00',
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                          child: SvgPicture.asset(
                                            'assets/icons/dollar-square.svg',
                                            width: 16,
                                            height: 16,
                                            colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        final price = _brlToDouble(value ?? '');

                                        if (price <= 0) {
                                          return 'Informe o preço do produto';
                                        }

                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 14),
                                    Text('Categoria', style: _labelStyle),
                                    SizedBox(height: AppSpacing.xs),
                                    DropdownButtonFormField<String>(
                                      hint: const Text(
                                        'Selecionar categoria',
                                        style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w400),
                                      ),
                                      initialValue: _selectedCategory,
                                      decoration: InputDecoration(hintText: 'Selecionar categoria'),
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF)),
                                      items: _categories
                                          .map(
                                            (item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w400),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() => _selectedCategory = value);
                                      },
                                    ),
                                    SizedBox(height: 14),
                                    Text('Estoque Disponível', style: _labelStyle),
                                    SizedBox(height: AppSpacing.xs),
                                    TextFormField(
                                      controller: _stockCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: InputDecoration(
                                        hintText: 'Quantidade em estoque',
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                                          child: SvgPicture.asset(
                                            'assets/icons/basket.svg',
                                            width: 16,
                                            height: 16,
                                            colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                                          ),
                                        ),
                                        suffixIcon: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              child: const Icon(Icons.keyboard_arrow_up_rounded, size: 20, color: Color(0xFF64748B)),
                                              onTap: () {
                                                int value = int.tryParse(_stockCtrl.text) ?? 0;
                                                value++;
                                                _stockCtrl.text = value.toString();
                                              },
                                            ),
                                            InkWell(
                                              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF64748B)),
                                              onTap: () {
                                                int value = int.tryParse(_stockCtrl.text) ?? 0;
                                                if (value > 0) {
                                                  value--;
                                                  _stockCtrl.text = value.toString();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              sectionCard(
                                margin: 12,
                                color: Color(0xFFFAFAF8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle(
                                      svgIcon: 'assets/icons/dollar-square.svg',
                                      iconColor: const Color(0xFFEF8F00),
                                      iconBg: const Color(0xFFFFF3D6),
                                      title: 'Cashback',
                                    ),
                                    SizedBox(height: 14),
                                    Text('Cashback (%)', style: _labelStyle),
                                    SizedBox(height: AppSpacing.xs),
                                    TextFormField(
                                      enabled: false,
                                      controller: _cashbackCtrl,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [PercentInputFormatter()],
                                      decoration: InputDecoration(),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              sectionCard(
                                margin: 12,
                                color: const Color(0xFFFAFAF8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle(
                                      svgIcon: 'assets/icons/activity-square.svg',
                                      iconColor: const Color(0xFFEF8F00),
                                      iconBg: const Color(0xFFFFF3D6),
                                      title: 'Imagem do Produto',
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              height: 165,
                                              child: _selectedImageBytes != null
                                                  ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                                                  : _currentImageUrl.trim().isNotEmpty
                                                  ? Image.network(
                                                      _currentImageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, _, _) {
                                                        return _productImageFallback();
                                                      },
                                                    )
                                                  : _productImageFallback(),
                                            ),
                                            Positioned.fill(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                                child: Container(color: Colors.black.withValues(alpha: 0.15)),
                                              ),
                                            ),
                                            SvgPicture.asset(
                                              'assets/icons/edit.svg',
                                              width: 20,
                                              height: 20,
                                              colorFilter: const ColorFilter.mode(Color(0xFFE6ECF3), BlendMode.srcIn),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: ElevatedButton.icon(
                                onPressed: _isSaving ? null : _save,
                                icon: SvgPicture.asset(
                                  'assets/icons/folder-cloud.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                                ),
                                label: Text(
                                  _isSaving ? 'Salvando...' : 'Salvar Alterações',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0038BC),
                                      foregroundColor: const Color(0xFFFFFFFF),
                                      elevation: 0,
                                      splashFactory: NoSplash.splashFactory,
                                      overlayColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      surfaceTintColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ).copyWith(
                                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                                      backgroundColor: WidgetStateProperty.all(const Color(0xFF0038BC)),
                                      foregroundColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
                                      elevation: WidgetStateProperty.all(0),
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton.icon(
                                onPressed: _isDeleting ? null : _delete,
                                icon: SvgPicture.asset(
                                  'assets/icons/trash.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
                                ),
                                label: Text(
                                  _isDeleting ? 'Excluindo...' : 'Excluir Produto',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF9CA3AF)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: const BorderSide(color: Colors.transparent),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isSaving) const SavingOverlay(message: 'Salvando produto...'),
              ],
            ),
          ),
        );
      },
    );
  }
}
