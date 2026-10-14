import 'dart:ui';

import 'package:clubcash/features/admin/presentation/widgets/input_textform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/ad_banner.dart';
import '../providers/admin_ads_provider.dart';
import '../widgets/ad_banner_image_preview.dart';
import '../widgets/ad_dialog_saving_overlay.dart';

Future<void> showAdBannerDialog(BuildContext context, WidgetRef _, {AdBanner? banner}) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'ads_banner_dialog',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, anim1, anim2) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: const SizedBox.expand()),
            ),
          ),
          _AdsBannerDetailsDialog(banner: banner),
        ],
      );
    },
  );
}

class _AdsBannerDetailsDialog extends ConsumerStatefulWidget {
  final AdBanner? banner;

  const _AdsBannerDetailsDialog({this.banner});

  @override
  ConsumerState<_AdsBannerDetailsDialog> createState() => _AdsBannerDetailsDialogState();
}

class _AdsBannerDetailsDialogState extends ConsumerState<_AdsBannerDetailsDialog> {
  late final TextEditingController titleController;
  XFile? _bannerImage;
  Uint8List? _bannerImageBytes;
  bool _isSaving = false;
  String _savingMessage = 'Salvando banner...';
  late final TextEditingController buttonLinkController;
  late final TextEditingController buttonTextController;
  late final TextEditingController descriptionController;

  FocusNode focusTitle = FocusNode();
  FocusNode focusButtonLink = FocusNode();
  FocusNode focusButtonText = FocusNode();
  FocusNode focusDescription = FocusNode();

  late bool isActive;

  bool get isEditing => widget.banner != null;

  @override
  void initState() {
    super.initState();

    final banner = widget.banner;

    titleController = TextEditingController(text: banner?.title ?? '');
    buttonLinkController = TextEditingController(text: banner?.buttonLink ?? '');
    buttonTextController = TextEditingController(text: banner?.buttonText ?? '');
    descriptionController = TextEditingController(text: banner?.description ?? '');

    isActive = banner?.isActive ?? true;
  }

  @override
  void dispose() {
    titleController.dispose();
    buttonLinkController.dispose();
    buttonTextController.dispose();
    descriptionController.dispose();
    focusTitle.dispose();
    focusButtonLink.dispose();
    focusButtonText.dispose();
    focusDescription.dispose();
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();

    if (!mounted) return;

    setState(() {
      _bannerImage = pickedImage;
      _bannerImageBytes = bytes;
    });
  }

  Future<void> _saveBanner() async {
    final title = titleController.text.trim();
    final buttonText = buttonTextController.text.trim();
    final buttonLink = buttonLinkController.text.trim();
    final description = descriptionController.text.trim();

    final oldImageURL = widget.banner?.imageURL.trim() ?? '';
    final hasNewImage = _bannerImage != null;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha o título do banner.')));
      return;
    }

    if (oldImageURL.isEmpty && !hasNewImage) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma imagem para o banner.')));
      return;
    }

    setState(() {
      _isSaving = true;
      _savingMessage = hasNewImage ? 'Enviando imagem do banner...' : 'Salvando banner...';
    });

    try {
      final actions = ref.read(adminAdsActionsProvider);

      final bannerId = widget.banner?.id ?? actions.createBannerId();
      String imageURL = oldImageURL;

      if (hasNewImage) {
        imageURL = await actions.uploadBannerImage(bannerId: bannerId, image: _bannerImage!);
      }

      if (imageURL.trim().isEmpty) {
        throw Exception('O upload não retornou a URL da imagem.');
      }

      final newBanner = AdBanner(
        id: bannerId,
        title: title,
        imageURL: imageURL,
        buttonLink: buttonLink,
        buttonText: buttonText.isEmpty ? 'Saiba mais' : buttonText,
        description: description,
        isActive: isActive,
      );

      if (isEditing) {
        await actions.updateBanner(newBanner);
      } else {
        await actions.createBanner(newBanner);
      }

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(isEditing ? 'Banner atualizado com sucesso.' : 'Banner cadastrado com sucesso.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível salvar o banner: $error')));
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
    return Dialog(
      backgroundColor: Color(0xFFFFFFFF),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0038BC),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            spacing: 2,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: SvgPicture.asset(
                                      'assets/icons/user-square.svg',
                                      colorFilter: ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                                    ),
                                  ),
                                  Text(
                                    isEditing ? 'Editar Banner' : 'Novo Banner',
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing ? 'Ajuste as configurações do destaque.' : 'Cadastre as configurações do destaque.',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFFFFFFFF).withValues(alpha: 0.9)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 32),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          icon: const Icon(Icons.close, size: 17, color: Color(0xFFFFFFFF)),
                          style: IconButton.styleFrom(
                            side: BorderSide(color: Color(0xFFFFFFFF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            minimumSize: const Size(28, 28),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AdInputField(
                              label: 'Título',
                              initialValue: '2 x R\$50,00',
                              focusNode: focusTitle,
                              hintText: '2 x R\$50,00',
                              controller: titleController,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Imagem',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Imagem',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                            ),
                            const SizedBox(height: 4),
                            AdBannerImagePreview(
                              imageBytes: _bannerImageBytes,
                              imageUrl: widget.banner?.imageURL ?? '',
                              onTap: _pickBannerImage,
                              enabled: !_isSaving,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _AdInputField(
                                    label: 'Link Botão',
                                    initialValue: 'https://...',
                                    focusNode: focusButtonLink,
                                    hintText: 'https://...',
                                    controller: buttonLinkController,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _AdInputField(
                                    label: 'Texto do Botão',
                                    initialValue: 'Saiba mais',
                                    focusNode: focusButtonText,
                                    hintText: 'Saiba mais',
                                    controller: buttonTextController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _AdInputField(
                              label: 'Descrição',
                              initialValue: 'Novas gotas, ganhe dinheiro de volta.',
                              focusNode: focusDescription,
                              hintText: 'Novas gotas, ganhe dinheiro de volta.',
                              controller: descriptionController,
                              maxLines: 2,
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveBanner,
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
                        SizedBox(width: 24),
                        Expanded(
                          child: Center(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                              child: Text(
                                'Descartar',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF9CA3AF)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isSaving) AdDialogSavingOverlay(message: _savingMessage),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? initialValue;
  final FocusNode focusNode;
  final TextEditingController controller;
  final int maxLines;

  const _AdInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.maxLines = 1,
    this.initialValue,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
        ),
        const SizedBox(height: 4),
        inputTextform(focusNode: focusNode, hint: hintText, controller: controller, maxLines: maxLines),
      ],
    );
  }
}
