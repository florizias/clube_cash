import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../share/widgets_exports.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  XFile? _profileImage;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  //late final TextEditingController _cpfCtrl;
  Uint8List? _profileImageBytes;
  bool _isSaving = false;
  String _currentPhotoUrl = '';
  bool _didFillForm = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    //_cpfCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    //_cpfCtrl.dispose();
    super.dispose();
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(firebaseUserProvider).value;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newPhotoUrl = await ref
          .read(profileActionsProvider)
          .updateProfile(
            uid: user.uid,
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            profileImage: _profileImage,
            oldPhotoUrl: _currentPhotoUrl,
          );

      ref.invalidate(currentUserProfileProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado com sucesso.')));

      setState(() {
        if (newPhotoUrl != null && newPhotoUrl.trim().isNotEmpty) {
          _currentPhotoUrl = newPhotoUrl.trim();
        }

        _profileImage = null;
        _profileImageBytes = null;
        _didFillForm = false;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível atualizar o perfil: $error')));
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
    profileAsync.whenData((profile) {
      if (profile == null || _didFillForm) return;
      _nameCtrl.text = profile.name;
      _emailCtrl.text = profile.email;
      _phoneCtrl.text = profile.phone;
      //_cpfCtrl.text = profile.cpf;
      _currentPhotoUrl = profile.photoUrl;
      _didFillForm = true;
    });

    final photoUrl = profileAsync.when(
      data: (profile) => (profile?.photoUrl ?? _currentPhotoUrl).trim(),
      loading: () => _currentPhotoUrl.trim(),
      error: (_, _) => _currentPhotoUrl.trim(),
    );

    final headerName = profileAsync.when(
      data: (profile) {
        final name = profile?.name.trim() ?? '';
        if (name.isEmpty) return 'Usuário';
        return name.split(RegExp(r'\s+')).first;
      },
      loading: () => 'Carregando...',
      error: (_, _) => 'Usuário',
    );
    final greeting = getGreeting();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                      child: photoUrl.isNotEmpty
                          ? Image.network(
                              _currentPhotoUrl.trim(),
                              key: ValueKey(_currentPhotoUrl.trim()),
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
                  //circleAction(Icons.notifications_none_rounded),
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
                      'Configurações de Perfil',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Imagem do Perfil'),
                      SizedBox(height: AppSpacing.xs),
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: const Color(0xFFE6ECF3),
                          strokeWidth: 1.5,
                          dashPattern: const [3, 3],
                          radius: const Radius.circular(14),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(14)),
                          child: InkWell(
                            onTap: () {
                              showProfileImageOptions(
                                context: context,
                                onImagePicked: (file) async {
                                  final bytes = await file.readAsBytes();

                                  if (!mounted) return;

                                  setState(() {
                                    _profileImage = file;
                                    _profileImageBytes = bytes;
                                  });
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  padding: _profileImage == null ? const EdgeInsets.all(20) : EdgeInsets.zero,
                                  decoration: const BoxDecoration(color: Color(0xFFE6ECF3), shape: BoxShape.circle),
                                  child: _profileImageBytes == null
                                      ? photoUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(100),
                                                child: Image.network(
                                                  _currentPhotoUrl,
                                                  key: ValueKey(_currentPhotoUrl),
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) {
                                                    return SvgPicture.asset(
                                                      'assets/icons/upload.svg',
                                                      colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                                                    );
                                                  },
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                'assets/icons/upload.svg',
                                                colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn),
                                              )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: Image.memory(
                                            _profileImageBytes!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Toque para abrir a câmera',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF000000)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'ou selecione da galeria',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      _label('Nome completo'),
                      SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _nameCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(hintText: 'Digite seu nome completo'),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Informe o nome completo';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14),
                      _label('E-mail'),
                      SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        enabled: false,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(hintText: 'Digite seu e-mail'),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Informe o e-mail';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14),
                      _label('Celular'),
                      SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(hintText: 'Digite seu celular'),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Informe o celular';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14),
                      /*_label('CPF'),
                      SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        enabled: false,
                        controller: _cpfCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Digite seu CPF'),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Informe o CPF';
                          }
                          return null;
                        },
                      ),*/
                    ],
                  ),
                ),
              ),
            ),

            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: const Icon(Icons.folder_open_rounded, size: 16),
                  label: Text(_isSaving ? 'Salvando...' : 'Salvar Alterações', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
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
          ],
        ),
      ),
    );
  }
}
