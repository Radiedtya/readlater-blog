import 'dart:async';

import 'package:flutter/material.dart';

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  static const _slides = [
    (
      eyebrow: 'PILIHAN HARI INI',
      title: 'Satu cerita bisa membuka banyak hal.',
      description: 'Temukan sudut pandang baru dari bacaan pilihan.',
      image: 'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=1400&q=85',
    ),
    (
      eyebrow: 'JEDA SEJENAK',
      title: 'Beri ruang untuk ide yang baik.',
      description: 'Simpan inspirasi, baca kembali saat waktunya tepat.',
      image: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=1400&q=85',
    ),
    (
      eyebrow: 'MULAI MENJELAJAH',
      title: 'Selalu ada hal baru untuk dipelajari.',
      description: 'Artikel pilihan untuk menemani waktu luangmu.',
      image: 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?auto=format&fit=crop&w=1400&q=85',
    ),
  ];

  final _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 244,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      slide.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: Color(0xFFDED8CB)),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xD9000000),
                            Color(0x73000000),
                            Color(0x12000000),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.eyebrow,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 310),
                            child: Text(
                              slide.title,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    height: 1.12,
                                    fontSize: 26,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            slide.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final selected = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF39372F)
                    : const Color(0xFF39372F).withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
