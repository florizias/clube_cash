import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/location/cep_helper.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';
import '../../data/repositories/partner_store_settings_repository.dart';
import '../providers/partner_store_settings_provider.dart';
import '../widgets/floating_save_bar.dart';
import '../widgets/saving_overlay.dart';
import '../widgets/settings_header_logo.dart';
import '../widgets/store_cover_preview.dart';
import '../widgets/store_logo_preview.dart';

class PartnerStoreSettingsPage extends ConsumerStatefulWidget {
  const PartnerStoreSettingsPage({super.key});

  @override
  ConsumerState<PartnerStoreSettingsPage> createState() => _PartnerStoreSettingsPageState();
}

class _PartnerStoreSettingsPageState extends ConsumerState<PartnerStoreSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String _savingMessage = 'Salvando alterações...';
  final _companyNameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();
  final _tiktokCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  PartnerStoreSettingsDto? _lastSavedStore;

  String _lastCepSearched = '';

  final _cepFocus = FocusNode();
  final _numberFocus = FocusNode();

  XFile? _logoImage;
  XFile? _coverImage;
  Uint8List? _logoImageBytes;
  Uint8List? _coverImageBytes;
  String _currentLogoUrl = '';
  String _currentCoverImageUrl = '';
  bool _isFillingForm = false;

  bool _isLoadingCep = false;
  bool _hasChanges = false;

  void _markChanged() {
    if (_isFillingForm) return;
    if (_hasChanges) return;

    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void initState() {
    super.initState();

    for (final ctrl in [
      _companyNameCtrl,
      _categoryCtrl,
      _addressCtrl,
      _cepCtrl,
      _streetCtrl,
      _numberCtrl,
      _neighborhoodCtrl,
      _cityCtrl,
      _stateCtrl,
      _whatsappCtrl,
      _websiteCtrl,
      _instagramCtrl,
      _facebookCtrl,
      _tiktokCtrl,
      _descriptionCtrl,
    ]) {
      ctrl.addListener(_markChanged);
    }
    _cepCtrl.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _categoryCtrl.dispose();
    _addressCtrl.dispose();
    _cepCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _whatsappCtrl.dispose();
    _websiteCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _tiktokCtrl.dispose();
    _descriptionCtrl.dispose();

    _cepFocus.dispose();
    _numberFocus.dispose();
    super.dispose();
    _cepCtrl.removeListener(_onCepChanged);
  }

  void _clearCepAddressFields() {
    if (!mounted) return;

    setState(() {
      _streetCtrl.clear();
      _neighborhoodCtrl.clear();
      _cityCtrl.clear();
      _stateCtrl.clear();
    });
  }

  Future<void> _pickLogoImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();

    if (!mounted) return;

    setState(() {
      _logoImage = pickedImage;
      _logoImageBytes = bytes;
      _hasChanges = true;
    });
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();

    if (!mounted) return;

    setState(() {
      _coverImage = pickedImage;
      _coverImageBytes = bytes;
      _hasChanges = true;
    });
  }

  void _applyStoreToForm(PartnerStoreSettingsDto store) {
    _isFillingForm = true;

    try {
      _companyNameCtrl.text = store.name;
      _categoryCtrl.text = store.category;

      _addressCtrl.text = store.address;

      _cepCtrl.text = store.cep;
      _streetCtrl.text = store.street;
      _numberCtrl.text = store.number;
      _neighborhoodCtrl.text = store.neighborhood;
      _cityCtrl.text = store.city;
      _stateCtrl.text = store.state;

      if (store.street.trim().isEmpty && store.address.trim().isNotEmpty) {
        _fillAddressFieldsFromText(store.address);
      }

      _whatsappCtrl.text = store.whatsapp;
      _websiteCtrl.text = store.website;
      _instagramCtrl.text = store.instagram;
      _facebookCtrl.text = store.facebook;
      _tiktokCtrl.text = store.tiktok;
      _descriptionCtrl.text = store.description;

      _currentLogoUrl = store.logoUrl;
      _currentCoverImageUrl = store.coverImageUrl;
    } finally {
      _isFillingForm = false;
    }
  }

  void _syncFormFromStore(PartnerStoreSettingsDto store) {
    _lastSavedStore = store;

    if (_hasChanges || _isSaving) return;

    _applyStoreToForm(store);
  }

  void _cancelChanges() {
    final store = _lastSavedStore;

    if (store != null) {
      _applyStoreToForm(store);
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _hasChanges = false;

      _logoImage = null;
      _coverImage = null;
      _logoImageBytes = null;
      _coverImageBytes = null;

      if (store != null) {
        _currentLogoUrl = store.logoUrl;
        _currentCoverImageUrl = store.coverImageUrl;
      }
    });
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
    );
  }

  Widget _section({required String title, required String svgIcon, required Widget child, String? subtitle}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFEAE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(height: 18, width: 18, child: SvgPicture.asset(svgIcon, colorFilter: ColorFilter.mode(Color(0xFFEF8F00), BlendMode.srcIn))),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF000000)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    FocusNode? focusNode,
    int maxLines = 1,
    bool enabled = true,
    bool readOnly = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onFieldSubmitted,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: readOnly ? const Color(0xFFF8FAFC) : const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0038BC)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final fullAddress = _fullAddress();

    setState(() {
      _isSaving = true;
      _savingMessage = _logoImage != null || _coverImage != null ? 'Enviando imagens...' : 'Salvando informações...';
    });

    try {
      await ref
          .read(partnerStoreSettingsActionsProvider)
          .updateCurrentPartnerStore(
            name: _companyNameCtrl.text.trim(),
            category: _categoryCtrl.text.trim(),
            address: fullAddress,
            cep: _cepCtrl.text.trim(),
            street: _streetCtrl.text.trim(),
            number: _numberCtrl.text.trim(),
            neighborhood: _neighborhoodCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            state: _stateCtrl.text.trim(),
            whatsapp: _whatsappCtrl.text.trim(),
            website: _websiteCtrl.text.trim(),
            instagram: _instagramCtrl.text.trim(),
            facebook: _facebookCtrl.text.trim(),
            tiktok: _tiktokCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            logoImage: _logoImage,
            coverImage: _coverImage,
          );

      if (!mounted) return;

      setState(() {
        _hasChanges = false;
        _logoImage = null;
        _coverImage = null;
        _logoImageBytes = null;
        _coverImageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas com sucesso.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível salvar as configurações: $error')));
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

    final name = profileAsync.when(data: (profile) => profile?.name ?? 'Usuário', loading: () => 'Carregando...', error: (_, _) => 'Usuário');
    final greeting = getGreeting();

    final storeAsync = ref.watch(currentPartnerStoreSettingsProvider);

    storeAsync.whenData((store) {
      if (store == null) return;
      _syncFormFromStore(store);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    border: Border(bottom: BorderSide(color: Color(0xFFE6ECF3))),
                  ),
                  child: Row(
                    children: [
                      SettingsHeaderLogo(logoBytes: _logoImageBytes, logoUrl: _currentLogoUrl),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$greeting, $name',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF001952)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Configurações da Loja',
                                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF000000)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Gerencie as informações públicas da sua empresa.',
                                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAF8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFEFEAE3)),
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    StoreCoverPreview(imageBytes: _coverImageBytes, imageUrl: _currentCoverImageUrl, height: 200),
                                    Positioned(
                                      left: 12,
                                      bottom: -60,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE5E2DC),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2))],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: StoreLogoPreview(imageBytes: _logoImageBytes, imageUrl: _currentLogoUrl),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(width: 120),
                                          const Spacer(),
                                          Wrap(
                                            spacing: 30,
                                            children: [
                                              _smallOrangeButton('Perfil', _isSaving ? null : _pickLogoImage),
                                              _smallOrangeButton('Capa', _isSaving ? null : _pickCoverImage),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      _label('Nome da Empresa'),
                                      const SizedBox(height: 6),
                                      _input(controller: _companyNameCtrl, hint: 'Casa Coco'),
                                      const SizedBox(height: 12),
                                      _label('Categoria'),
                                      const SizedBox(height: 6),
                                      _input(controller: _categoryCtrl, hint: 'Alimentação'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _section(
                            title: 'Informações de Contato',
                            svgIcon: 'assets/icons/attention-circle.svg',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Endereço da loja'),
                                const SizedBox(height: 6),
                                _fieldRow(
                                  leftFlex: 2,
                                  rightFlex: 1,
                                  left: _input(
                                    controller: _cepCtrl,
                                    focusNode: _cepFocus,
                                    hint: 'CEP',
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, CepInputFormatter()],
                                    validator: (v) {
                                      final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');

                                      if (digits.isEmpty) return 'Informe o CEP.';
                                      if (digits.length != 8) return 'CEP inválido.';

                                      return null;
                                    },
                                    suffix: _isLoadingCep
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                          )
                                        : null,
                                  ),
                                  right: _input(
                                    controller: _numberCtrl,
                                    focusNode: _numberFocus,
                                    hint: 'Número',
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    validator: (v) {
                                      final value = (v ?? '').trim();
                                      if (value.isEmpty) return 'Informe.';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _input(
                                  controller: _streetCtrl,
                                  hint: 'Logradouro',
                                  validator: (v) {
                                    final value = (v ?? '').trim();
                                    if (value.isEmpty) return 'Informe o logradouro.';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _input(
                                  controller: _neighborhoodCtrl,
                                  hint: 'Bairro',
                                  validator: (v) {
                                    final value = (v ?? '').trim();
                                    if (value.isEmpty) return 'Informe o bairro.';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _fieldRow(
                                  leftFlex: 3,
                                  rightFlex: 1,
                                  left: _input(
                                    controller: _cityCtrl,
                                    hint: 'Cidade',
                                    readOnly: true,
                                    validator: (v) {
                                      final value = (v ?? '').trim();
                                      if (value.isEmpty) return 'Busque o CEP.';
                                      return null;
                                    },
                                    suffix: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                  ),
                                  right: _input(
                                    controller: _stateCtrl,
                                    hint: 'UF',
                                    readOnly: true,
                                    validator: (v) {
                                      final value = (v ?? '').trim();
                                      if (value.isEmpty) return 'UF.';
                                      return null;
                                    },
                                    suffix: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _label('WhatsApp'),
                                const SizedBox(height: 6),
                                _input(controller: _whatsappCtrl, hint: '+55 (99) 99999-9999'),
                                const SizedBox(height: 12),
                                _label('Site Oficial'),
                                const SizedBox(height: 6),
                                _input(controller: _websiteCtrl, hint: 'www.casacoco.com.br'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _section(
                            title: 'Redes Sociais',
                            svgIcon: 'assets/icons/user-square.svg',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Instagram'),
                                const SizedBox(height: 6),
                                _input(controller: _instagramCtrl, hint: 'Link aqui'),
                                const SizedBox(height: 12),
                                _label('Facebook'),
                                const SizedBox(height: 6),
                                _input(controller: _facebookCtrl, hint: 'Link aqui'),
                                const SizedBox(height: 12),
                                _label('TikTok'),
                                const SizedBox(height: 6),
                                _input(controller: _tiktokCtrl, hint: 'Link aqui'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _section(
                            title: 'Sobre a Empresa',
                            svgIcon: 'assets/icons/user-square.svg',
                            subtitle: 'Escreva uma descrição detalhada sobre sua empresa para que os usuários conheçam um pouco sobre quem você é.',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Descrição completa'),
                                const SizedBox(height: 6),
                                _input(controller: _descriptionCtrl, hint: 'Escreva aqui', maxLines: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 72,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _hasChanges ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_hasChanges || _isSaving,
                  child: FloatingSaveBar(hasChanges: _hasChanges, onSave: _save, onCancel: _cancelChanges),
                ),
              ),
            ),
            if (_isSaving) SavingOverlay(message: _savingMessage),
          ],
        ),
      ),
    );
  }

  Widget _smallOrangeButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      height: 30,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: SizedBox(
          width: 15,
          height: 15,
          child: SvgPicture.asset(
            width: 10,
            height: 10,
            "assets/icons/image.svg",
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
          ),
        ),
        label: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF8F00),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
    );
  }

  Widget _fieldRow({required Widget left, required Widget right, int leftFlex = 1, int rightFlex = 1}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: leftFlex, child: left),
            const SizedBox(width: 12),
            Expanded(flex: rightFlex, child: right),
          ],
        );
      },
    );
  }

  String _formatCepForAddress(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 8) {
      return value.trim();
    }

    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }

  String _fullAddress() {
    final street = _streetCtrl.text.trim();
    final number = _numberCtrl.text.trim();
    final neighborhood = _neighborhoodCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final state = _stateCtrl.text.trim();
    final cep = _formatCepForAddress(_cepCtrl.text);

    return '$street, $number - $neighborhood, $city - $state, $cep, Brasil';
  }

  Future<void> _searchCep([String? cep]) async {
    final cleanCep = (cep ?? _cepCtrl.text).replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) return;
    if (_isLoadingCep) return;

    _lastCepSearched = cleanCep;

    setState(() {
      _isLoadingCep = true;
    });

    try {
      final address = await CepHelper.findAddressByCep(cleanCep);

      if (!mounted) return;

      if (address == null) {
        _clearCepAddressFields();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CEP não encontrado.')));
        return;
      }

      setState(() {
        _streetCtrl.text = address.street;
        _neighborhoodCtrl.text = address.neighborhood;
        _cityCtrl.text = address.city;
        _stateCtrl.text = address.state;
      });

      _numberFocus.requestFocus();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível buscar o CEP.')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCep = false;
        });
      }
    }
  }

  void _onCepChanged() {
    if (_isFillingForm) return;

    final digits = _cepCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length < 8) {
      _lastCepSearched = '';

      if (_streetCtrl.text.isNotEmpty || _neighborhoodCtrl.text.isNotEmpty || _cityCtrl.text.isNotEmpty || _stateCtrl.text.isNotEmpty) {
        _clearCepAddressFields();
      }

      return;
    }

    if (digits.length == 8 && digits != _lastCepSearched) {
      _searchCep(digits);
    }
  }

  void _fillAddressFieldsFromText(String address) {
    final clean = address.trim();
    if (clean.isEmpty) return;

    final withoutCountry = clean.replaceAll(RegExp(r',?\s*Brasil$', caseSensitive: false), '');

    final parts = withoutCountry.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (parts.length < 3) return;

    _streetCtrl.text = parts[0];

    final numberAndNeighborhood = parts[1].split('-').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (numberAndNeighborhood.isNotEmpty) {
      _numberCtrl.text = numberAndNeighborhood[0];
    }

    if (numberAndNeighborhood.length > 1) {
      _neighborhoodCtrl.text = numberAndNeighborhood.sublist(1).join(' - ');
    }

    final cityAndState = parts[2].split('-').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (cityAndState.isNotEmpty) {
      _cityCtrl.text = cityAndState[0];
    }

    if (cityAndState.length > 1) {
      _stateCtrl.text = cityAndState[1];
    }

    if (parts.length >= 4) {
      final cepMatch = RegExp(r'\d{5}-?\d{3}').firstMatch(parts[3]);
      if (cepMatch != null) {
        _cepCtrl.text = cepMatch.group(0) ?? '';
      }
    }
  }
}
