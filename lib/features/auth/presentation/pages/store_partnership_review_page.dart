import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../../../share/widgets_exports.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_providers.dart';
import '../widgets/input_textfield.dart';

class StorePartnershipReviewPage extends ConsumerStatefulWidget {
  const StorePartnershipReviewPage({super.key});

  @override
  ConsumerState<StorePartnershipReviewPage> createState() => _StorePartnershipReviewPageState();
}

class _StorePartnershipReviewPageState extends ConsumerState<StorePartnershipReviewPage> {
  final _formKey = GlobalKey<FormState>();

  final _storeName = TextEditingController();
  final _cnpj = TextEditingController();
  final _openingDate = TextEditingController();
  final _location = TextEditingController();
  final _legalResponsible = TextEditingController();
  final _email = TextEditingController();
  final _whatsapp = TextEditingController();
  final _whyParticipate = TextEditingController();
  final _cashbackProposal = TextEditingController();
  final _resubmissionMessage = TextEditingController();

  final _storeNameFocus = FocusNode();
  final _cnpjFocus = FocusNode();
  final _openingDateFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _legalResponsibleFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _whatsappFocus = FocusNode();
  final _whyParticipateFocus = FocusNode();
  final _cashbackProposalFocus = FocusNode();
  final _resubmissionMessageFocus = FocusNode();

  String? _selectedCategory;
  String? _selectedMonthlyRevenue;
  String _rejectionReason = '';

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _categories = const [
    'Alimentação',
    'Moda e acessórios',
    'Beleza e estética',
    'Mercado e conveniência',
    'Saúde e bem-estar',
    'Casa e decoração',
    'Serviços',
    'Educação',
    'Pet shop',
    'Outro',
  ];

  final List<String> _monthlyRevenueOptions = const [
    'R\$ 0 - R\$ 5.000,00',
    'R\$ 5.000,00 - R\$ 10.000,00',
    'R\$ 10.000,00 - R\$ 25.000,00',
    'R\$ 25.000,00 - R\$ 50.000,00',
    'R\$ 50.000,00 - R\$ 100.000,00',
    'Acima de R\$ 100.000,00',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadRequest);
  }

  @override
  void dispose() {
    _storeName.dispose();
    _cnpj.dispose();
    _openingDate.dispose();
    _location.dispose();
    _legalResponsible.dispose();
    _email.dispose();
    _whatsapp.dispose();
    _whyParticipate.dispose();
    _cashbackProposal.dispose();
    _resubmissionMessage.dispose();
    _storeNameFocus.dispose();
    _cnpjFocus.dispose();
    _openingDateFocus.dispose();
    _locationFocus.dispose();
    _legalResponsibleFocus.dispose();
    _emailFocus.dispose();
    _whatsappFocus.dispose();
    _whyParticipateFocus.dispose();
    _cashbackProposalFocus.dispose();
    _resubmissionMessageFocus.dispose();
    super.dispose();
  }

  String _onlyDigits(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _loadRequest() async {
    final user = ref
        .read(firebaseUserProvider)
        .value;

    if (user == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance.collection('store_requests').doc(user.uid).get();

      final data = snap.data();

      if (data == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitação não encontrada.')));
          context.go('/login');
        }
        return;
      }

      _storeName.text = data['storeName']?.toString() ?? '';
      _cnpj.text = data['cnpj']?.toString() ?? '';
      _selectedCategory = data['category']?.toString();
      _selectedMonthlyRevenue = data['monthlyRevenue']?.toString();
      _openingDate.text = data['openingDate']?.toString() ?? '';
      _location.text = data['location']?.toString() ?? '';
      _legalResponsible.text = data['legalResponsible']?.toString() ?? '';
      _email.text = data['commercialEmail']?.toString() ?? data['email']?.toString() ?? '';
      _whatsapp.text = data['whatsapp']?.toString() ?? '';
      _whyParticipate.text = data['whyParticipate']?.toString() ?? '';
      _cashbackProposal.text = data['cashbackProposal']?.toString() ?? '';
      _rejectionReason = data['rejectionReason']?.toString() ?? data['reason']?.toString() ?? '';

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar solicitação: $error')));
    }
  }

  Future<void> _pickOpeningDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 1, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Data de abertura',
      cancelText: 'Cancelar',
      confirmText: 'Selecionar',
    );

    if (pickedDate == null) return;

    final day = pickedDate.day.toString().padLeft(2, '0');
    final month = pickedDate.month.toString().padLeft(2, '0');
    final year = pickedDate.year.toString();

    setState(() {
      _openingDate.text = '$day/$month/$year';
    });
  }

  Future<void> _resubmit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final user = ref
        .read(firebaseUserProvider)
        .value;

    if (user == null) {
      context.go('/login');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final data = {
        'storeName': _storeName.text.trim(),
        'cnpj': _cnpj.text.trim(),
        'cnpjDigits': _onlyDigits(_cnpj.text),
        'category': _selectedCategory ?? '',
        'monthlyRevenue': _selectedMonthlyRevenue ?? '',
        'openingDate': _openingDate.text.trim(),
        'location': _location.text.trim(),
        'legalResponsible': _legalResponsible.text.trim(),
        'commercialEmail': _email.text.trim().toLowerCase(),
        'whatsapp': _whatsapp.text.trim(),
        'whyParticipate': _whyParticipate.text.trim(),
        'cashbackProposal': int.tryParse(_cashbackProposal.text.trim()) ?? 0,

        'status': 'pending',
        'resubmissionMessage': _resubmissionMessage.text.trim(),
        'resubmittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('store_requests').doc(user.uid).set(data, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'status': 'pending_approval',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastro reenviado para análise.')));

      await ref.read(authControllerProvider.notifier).signOut();

      if (!mounted) return;
      context.go('/login');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível reenviar: $error')));
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Corrigir cadastro',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Atualize as informações solicitadas e envie novamente para análise.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.4),
                    ),

                    if (_rejectionReason
                        .trim()
                        .isNotEmpty) ...[
                      SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDC2626)),
                        ),
                        child: Text(
                          'Motivo da recusa: $_rejectionReason',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF991B1B), height: 1.35),
                        ),
                      ),
                    ],

                    SizedBox(height: AppSpacing.xl),

                    Input(
                      controller: _storeName,
                      hint: 'Nome da loja',
                      focusNode: _storeNameFocus,
                      prefix: _IconPrefix('assets/icons/store.svg'),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Informe o nome da loja.';
                        if (value.length < 3) return 'Digite um nome válido.';
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    Input(
                      controller: _cnpj,
                      hint: 'CNPJ',
                      focusNode: _cnpjFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CnpjInputFormatter()],
                      prefix: _IconPrefix('assets/icons/id-card.svg'),
                      validator: (v) {
                        final digits = _onlyDigits(v ?? '');
                        if (digits.isEmpty) return 'Informe o CNPJ.';
                        if (digits.length != 14) return 'Digite um CNPJ válido.';
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    _DropdownField(
                      value: _selectedCategory,
                      hint: 'Categoria',

                      items: _categories,
                      icon: 'assets/icons/category.svg',
                      validatorText: 'Selecione a categoria da loja.',
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    _DropdownField(
                      value: _selectedMonthlyRevenue,
                      hint: 'Faturamento mensal',
                      items: _monthlyRevenueOptions,
                      icon: 'assets/icons/dollar-square.svg',
                      validatorText: 'Selecione o faturamento mensal.',
                      onChanged: (value) {
                        setState(() {
                          _selectedMonthlyRevenue = value;
                        });
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    InkWell(
                      onTap: _pickOpeningDate,
                      child: AbsorbPointer(
                        child: Input(
                          controller: _openingDate,
                          hint: 'Data de abertura',
                          focusNode: _openingDateFocus,
                          keyboardType: TextInputType.datetime,
                          prefix: _IconPrefix('assets/icons/calendar.svg'),
                          validator: (v) {
                            if ((v ?? '')
                                .trim()
                                .isEmpty) {
                              return 'Informe a data de abertura.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.md),

                    Input(
                      controller: _location,
                      hint: 'Localização / Cidade e Estado',
                      focusNode: _locationFocus,
                      prefix: _IconPrefix('assets/icons/place.svg'),
                      validator: (v) {
                        if ((v ?? '')
                            .trim()
                            .isEmpty) {
                          return 'Informe a localização.';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    Input(
                      controller: _legalResponsible,
                      hint: 'Responsável legal',
                      focusNode: _legalResponsibleFocus,
                      prefix: _IconPrefix('assets/icons/person-name.svg'),
                      validator: (v) {
                        if ((v ?? '')
                            .trim()
                            .isEmpty) {
                          return 'Informe o responsável legal.';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    Input(
                      controller: _email,
                      hint: 'E-mail comercial',
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      prefix: _IconPrefix('assets/icons/email.svg'),
                      validator: (v) {
                        final value = (v ?? '').trim().toLowerCase();
                        if (value.isEmpty) return 'Informe o e-mail.';
                        final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                        if (!ok) return 'Digite um e-mail válido.';
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    Input(
                      controller: _whatsapp,
                      hint: 'WhatsApp comercial',
                      focusNode: _whatsappFocus,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                      prefix: _IconPrefix('assets/icons/phone.svg'),
                      validator: (v) {
                        final digits = _onlyDigits(v ?? '');
                        if (digits.isEmpty) return 'Informe o WhatsApp.';
                        if (digits.length < 10) return 'Digite um telefone válido.';
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    Input(
                      controller: _whyParticipate,
                      hint: 'Por que sua loja quer participar?',
                      focusNode: _whyParticipateFocus,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: 4,
                      prefix: _IconPrefix('assets/icons/document-text.svg'),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) {
                          return 'Conte por que sua loja quer participar.';
                        }
                        if (value.length < 20) {
                          return 'Escreva uma resposta um pouco mais completa.';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    Input(
                      controller: _cashbackProposal,
                      hint: 'Proposta de cashback (%)',
                      focusNode: _cashbackProposalFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      prefix: _IconPrefix('assets/icons/dollar.svg'),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Informe a proposta de cashback.';
                        final number = int.tryParse(value);
                        if (number == null) return 'Digite apenas números inteiros.';
                        if (number <= 0) return 'O cashback precisa ser maior que 0.';
                        if (number > 50) return 'Informe uma proposta até 50%.';
                        return null;
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

                    Input(
                      controller: _resubmissionMessage,
                      hint: 'Mensagem para reavaliação',
                      focusNode: _resubmissionMessageFocus,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: 4,
                      prefix: _IconPrefix('assets/icons/document-text.svg'),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) {
                          return 'Explique o que foi corrigido.';
                        }
                        if (value.length < 10) {
                          return 'Escreva uma mensagem um pouco mais completa.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _resubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0038BC),
                          foregroundColor: const Color(0xFFFFFFFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          _isSaving ? 'Reenviando...' : 'Reenviar para análise',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.md),

                    TextButton(
                      onPressed: () async {
                        final shouldLogout = await showConfirmLogoutPop(context);
                        if (!shouldLogout) return;
                        if (!context.mounted) return;
                        await ref.read(authControllerProvider.notifier).signOut();
                        if (!context.mounted) return;
                        context.go('/home');
                      },
                      child: Text(
                        'Voltar para login',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
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

class _IconPrefix extends StatelessWidget {
  final String asset;

  const _IconPrefix(this.asset);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(asset, width: 20, height: 20, colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn));
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final String icon;
  final String validatorText;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.icon,
    required this.validatorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8)),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SvgPicture.asset(icon, width: 20, height: 20, colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn)),
        ),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF0F172A)),
      dropdownColor: Colors.white,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value
            .trim()
            .isEmpty) {
          return validatorText;
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
