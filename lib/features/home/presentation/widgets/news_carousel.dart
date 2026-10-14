import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';
import 'news_card_item.dart';

class NewsCarousel extends StatefulWidget {
  final String headerTitle;
  final List<Map<String, dynamic>> itemsJson;
  final void Function(Map<String, dynamic> item) onTapItem;

  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;

  const NewsCarousel({
    super.key,
    required this.headerTitle,
    required this.itemsJson,
    required this.onTapItem,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 450),
  });

  @override
  State<NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<NewsCarousel> {
  late final PageController _controller;

  Timer? _timer;
  Timer? _resumeTimer;

  static const _initialPage = 1000;

  int _index = 0;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: 0.9, initialPage: _initialPage);

    if (widget.autoPlay) _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant NewsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final configChanged =
        oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.autoPlayAnimationDuration != widget.autoPlayAnimationDuration ||
        oldWidget.itemsJson.length != widget.itemsJson.length;

    if (configChanged) {
      _stopAutoPlay();
      if (widget.autoPlay) _startAutoPlay();
    }

    if (_index >= widget.itemsJson.length && widget.itemsJson.isNotEmpty) {
      setState(() => _index = 0);
      _jumpToRealIndex(0);
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();

    if (widget.itemsJson.length <= 1) return;

    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted) return;
      if (_userInteracting) return;
      if (!_controller.hasClients) return;

      _controller.nextPage(duration: widget.autoPlayAnimationDuration, curve: Curves.easeOut);
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  void _markInteracting() {
    if (!_userInteracting) {
      setState(() => _userInteracting = true);
    }
    _scheduleResumeAutoPlay();
  }

  void _scheduleResumeAutoPlay() {
    _resumeTimer?.cancel();
    if (!widget.autoPlay) return;

    _resumeTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _userInteracting = false);
    });
  }

  void _jumpToRealIndex(int realIndex) {
    if (!_controller.hasClients) return;
    final target = _initialPage - (_initialPage % widget.itemsJson.length) + realIndex;
    _controller.jumpToPage(target);
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _resumeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemsJson.isEmpty) return SizedBox.shrink();

    final current = widget.itemsJson[_index];
    final tag = (current['tag'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.headerTitle,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF131516)),
              ),
              if (tag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFE0B84C)),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: Listener(
            onPointerDown: (_) => _markInteracting(),
            onPointerSignal: (_) => _markInteracting(),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: const {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                },
              ),
              child: PageView.builder(
                controller: _controller,
                physics: const PageScrollPhysics(),
                itemCount: null,
                onPageChanged: (i) {
                  setState(() => _index = i % widget.itemsJson.length);
                },
                itemBuilder: (context, i) {
                  final realIndex = i % widget.itemsJson.length;
                  final item = widget.itemsJson[realIndex];

                  final title = (item['title'] ?? '').toString();
                  final buttonText = (item['buttonText'] ?? 'Saiba mais').toString();
                  final thumbnailUrl = (item['thumbnailUrl'] ?? '').toString();

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: NewsCardItem(title: title, buttonText: buttonText, thumbnailUrl: thumbnailUrl, onPressed: () => widget.onTapItem(item)),
                  );
                },
              ),
            ),
          ),
        ),

        SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.itemsJson.length, (i) {
            final selected = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: selected ? 18 : 6,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
