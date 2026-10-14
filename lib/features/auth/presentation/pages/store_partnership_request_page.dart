import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import '../../../../core/location/cep_helper.dart';
import '../controllers/auth_controller.dart';
import '../providers/verify_gate_provider.dart';
import '../widgets/input_textfield.dart';

class StorePartnershipRequestPage extends ConsumerStatefulWidget {
  const StorePartnershipRequestPage({super.key});

  @override
  ConsumerState<StorePartnershipRequestPage> createState() => _StorePartnershipRequestPageState();
}

class _StorePartnershipRequestPageState extends ConsumerState<StorePartnershipRequestPage> {
  final _formKey = GlobalKey<FormState>();

  final _storeName = TextEditingController();
  final _cnpj = TextEditingController();
  final _openingDate = TextEditingController();
  final _cep = TextEditingController();
  final _street = TextEditingController();
  final _number = TextEditingController();
  final _neighborhood = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _legalResponsible = TextEditingController();
  final _email = TextEditingController();
  final _whatsapp = TextEditingController();
  final _whyParticipate = TextEditingController();
  final _cashbackProposal = TextEditingController();
  final _loginEmail = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final _storeNameFocus = FocusNode();
  final _cnpjFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cepFocus = FocusNode();
  final _streetFocus = FocusNode();
  final _numberFocus = FocusNode();
  final _neighborhoodFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _legalResponsibleFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _whatsappFocus = FocusNode();
  final _whyParticipateFocus = FocusNode();
  final _cashbackProposalFocus = FocusNode();
  final _loginEmailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _openingDateFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoadingCep = false;
  String _lastCepSearched = '';
  String? _selectedCategory;
  String? _selectedMonthlyRevenue;

  @override
  void initState() {
    super.initState();

    _cep.addListener(_onCepChanged);
  }

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
  void dispose() {
    _storeName.dispose();
    _cnpj.dispose();
    _openingDate.dispose();
    _cep.removeListener(_onCepChanged);
    _cep.dispose();
    _street.dispose();
    _number.dispose();
    _neighborhood.dispose();
    _city.dispose();
    _state.dispose();
    _legalResponsible.dispose();
    _email.dispose();
    _whatsapp.dispose();
    _whyParticipate.dispose();
    _cashbackProposal.dispose();
    _loginEmail.dispose();
    _password.dispose();
    _confirmPassword.dispose();

    _storeNameFocus.dispose();
    _cnpjFocus.dispose();
    _addressFocus.dispose();
    _cepFocus.dispose();
    _streetFocus.dispose();
    _numberFocus.dispose();
    _neighborhoodFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _legalResponsibleFocus.dispose();
    _emailFocus.dispose();
    _whatsappFocus.dispose();
    _whyParticipateFocus.dispose();
    _cashbackProposalFocus.dispose();
    _loginEmailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _openingDateFocus.dispose();

    super.dispose();
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

  Future<void> _submitRequest() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    await ref
        .read(authControllerProvider.notifier)
        .requestStorePartnership(
      storeName: _storeName.text.trim(),
      cnpj: _cnpj.text.trim(),
      category: _selectedCategory ?? '',
      monthlyRevenue: _selectedMonthlyRevenue ?? '',
      openingDate: _openingDate.text.trim(),
      address: _fullAddress(),
      legalResponsible: _legalResponsible.text.trim(),
      commercialEmail: _email.text.trim(),
      loginEmail: _loginEmail.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      password: _password.text,
      whyParticipate: _whyParticipate.text.trim(),
      cashbackProposal: int.tryParse(_cashbackProposal.text.trim()) ?? 0,
    );
  }

  Future<void> _searchCep([String? cep]) async {
    final cleanCep = (cep ?? _cep.text).replaceAll(RegExp(r'[^0-9]'), '');

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
        _street.text = address.street;
        _neighborhood.text = address.neighborhood;
        _city.text = address.city;
        _state.text = address.state;
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

  String _formatCepForAddress(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 8) {
      return value.trim();
    }

    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }

  String _fullAddress() {
    final street = _street.text.trim();
    final number = _number.text.trim();
    final neighborhood = _neighborhood.text.trim();
    final city = _city.text.trim();
    final state = _state.text.trim();
    final cep = _formatCepForAddress(_cep.text);

    return '$street, $number - $neighborhood, $city - $state, $cep, Brasil';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      final wasLoading = previous?.isLoading == true;

      next.whenOrNull(
        data: (_) {
          if (!wasLoading) return;
          ref
              .read(verifyEmailGateProvider.notifier)
              .state = true;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitação enviada para análise.')));
          context.go('/verify-email');
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível enviar a solicitação.')));
        },
      );
    });

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
                      'Solicitar participação',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Conte um pouco sobre sua loja. O time ClubCash vai analisar sua solicitação antes de liberar o acesso.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.4),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    Input(
                      focusNode: _storeNameFocus,
                      controller: _storeName,
                      hint: 'Nome da loja',
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _cnpjFocus.requestFocus(),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Informe o nome da loja.';
                        if (value.length < 3) return 'Digite um nome válido.';
                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/store.svg'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _cnpjFocus,
                      controller: _cnpj,
                      hint: 'CNPJ',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CnpjInputFormatter()],
                      validator: (v) {
                        final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.isEmpty) return 'Informe o CNPJ.';
                        if (digits.length != 14) {
                          return 'Digite um CNPJ válido.';
                        }
                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/id-card.svg'),
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
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: AbsorbPointer(
                        child: Input(
                          focusNode: _openingDateFocus,
                          controller: _openingDate,
                          hint: 'Data de abertura',
                          keyboardType: TextInputType.datetime,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) {
                              return 'Informe a data de abertura.';
                            }
                            return null;
                          },
                          prefix: _IconPrefix('assets/icons/calendar.svg'),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _fieldRow(
                      leftFlex: 2,
                      rightFlex: 1,
                      left: Input(
                        focusNode: _cepFocus,
                        controller: _cep,
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
                        prefix: _IconPrefix('assets/icons/place.svg'),
                        suffix: _isLoadingCep
                            ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                            : null,
                      ),
                      right: Input(
                        focusNode: _numberFocus,
                        controller: _number,
                        hint: 'Número',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _legalResponsibleFocus.requestFocus(),
                        validator: (v) {
                          final value = (v ?? '').trim();

                          if (value.isEmpty) return 'Informe o número.';

                          return null;
                        },
                        prefix: _IconPrefix('assets/icons/id-card.svg'),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _streetFocus,
                      controller: _street,
                      hint: 'Logradouro',
                      readOnly: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final value = (v ?? '').trim();

                        if (value.isEmpty) return 'Busque o CEP para preencher o logradouro.';

                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/place.svg'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _neighborhoodFocus,
                      controller: _neighborhood,
                      hint: 'Bairro',
                      readOnly: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final value = (v ?? '').trim();

                        if (value.isEmpty) return 'Busque o CEP para preencher o bairro.';

                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/place.svg'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _fieldRow(
                      leftFlex: 2,
                      rightFlex: 1,
                      left: Input(
                        focusNode: _cityFocus,
                        controller: _city,
                        hint: 'Cidade',
                        readOnly: true,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Busque o CEP.';
                          return null;
                        },
                        prefix: _IconPrefix('assets/icons/place.svg'),
                      ),
                      right: Input(
                        focusNode: _stateFocus,
                        controller: _state,
                        hint: 'UF',
                        readOnly: true,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'UF.';
                          return null;
                        },
                        prefix: _IconPrefix('assets/icons/place.svg'),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _legalResponsibleFocus,
                      controller: _legalResponsible,
                      hint: 'Responsável legal',
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) {
                          return 'Informe o responsável legal.';
                        }
                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/person-name.svg'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _emailFocus,
                      controller: _email,
                      hint: 'E-mail comercial',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _whatsappFocus.requestFocus(),
                      validator: (v) {
                        final value = (v ?? '').trim().toLowerCase();
                        if (value.isEmpty) return 'Informe o e-mail.';
                        final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                        if (!ok) return 'Digite um e-mail válido.';
                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/email.svg'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _whatsappFocus,
                      controller: _whatsapp,
                      hint: 'WhatsApp comercial',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                      onFieldSubmitted: (_) => _whyParticipateFocus.requestFocus(),
                      validator: (v) {
                        final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.isEmpty) return 'Informe o WhatsApp.';
                        if (digits.length < 10) {
                          return 'Digite um telefone válido.';
                        }
                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/phone.svg'),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dados de acesso',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Esse acesso será usado pelo responsável caso a loja seja aprovada.',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.35),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _loginEmailFocus,
                      controller: _loginEmail,
                      hint: 'E-mail de login',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (v) {
                        final value = (v ?? '').trim().toLowerCase();

                        if (value.isEmpty) return 'Informe o e-mail de login.';

                        final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);

                        if (!ok) return 'Digite um e-mail válido.';

                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/email.svg'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _passwordFocus,
                      controller: _password,
                      hint: 'Senha de acesso',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                      validator: (v) {
                        final value = v ?? '';

                        if (value
                            .trim()
                            .isEmpty) return 'Informe uma senha.';
                        if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';

                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/key.svg'),
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        splashRadius: 20,
                        icon: SvgPicture.asset(
                          _obscurePassword ? 'assets/icons/no-see-key.svg' : 'assets/icons/see-key.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _confirmPasswordFocus,
                      controller: _confirmPassword,
                      hint: 'Confirmar senha',
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _whyParticipateFocus.requestFocus(),
                      validator: (v) {
                        final value = v ?? '';
                        if (value
                            .trim()
                            .isEmpty) return 'Confirme sua senha.';
                        if (value != _password.text) {
                          return 'As senhas não coincidem.';
                        }
                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/key.svg'),
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        splashRadius: 20,
                        icon: SvgPicture.asset(
                          _obscureConfirmPassword ? 'assets/icons/no-see-key.svg' : 'assets/icons/see-key.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _whyParticipateFocus,
                      controller: _whyParticipate,
                      hint: 'Por que sua loja quer participar?',
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: 4,
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
                      prefix: _IconPrefix('assets/icons/document-text.svg'),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Input(
                      focusNode: _cashbackProposalFocus,
                      controller: _cashbackProposal,
                      hint: 'Proposta de cashback (%)',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      onFieldSubmitted: (_) => _submitRequest(),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) {
                          return 'Informe a proposta de cashback.';
                        }
                        final number = int.tryParse(value);
                        if (number == null) {
                          return 'Digite apenas números inteiros.';
                        }
                        if (number <= 0) {
                          return 'O cashback precisa ser maior que 0.';
                        }
                        if (number > 50) {
                          return 'Informe uma proposta até 50%.';
                        }
                        return null;
                      },
                      prefix: _IconPrefix('assets/icons/dollar.svg'),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0038BC),
                          foregroundColor: const Color(0xFFFFFFFF),
                          elevation: 0,
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          authState.isLoading ? 'Enviando solicitação...' : 'Enviar para análise',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Divider(),
                    TextButton(
                      style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                      onPressed: () => context.go('/register-choice'),
                      child: Text(
                        'Voltar',
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

  void _onCepChanged() {
    final digits = _cep.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length < 8) {
      _lastCepSearched = '';

      if (_street.text.isNotEmpty || _neighborhood.text.isNotEmpty || _city.text.isNotEmpty || _state.text.isNotEmpty) {
        _clearCepAddressFields();
      }

      return;
    }

    if (digits.length == 8 && digits != _lastCepSearched) {
      _searchCep(digits);
    }
  }

  void _clearCepAddressFields() {
    if (!mounted) return;

    setState(() {
      _street.clear();
      _neighborhood.clear();
      _city.clear();
      _state.clear();
    });
  }
}

Widget _fieldRow({required Widget left, required Widget right, int leftFlex = 1, int rightFlex = 1}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 360) {
        return Column(
          children: [
            left,
            SizedBox(height: AppSpacing.md),
            right,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: leftFlex, child: left),
          SizedBox(width: AppSpacing.md),
          Expanded(flex: rightFlex, child: right),
        ],
      );
    },
  );
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
