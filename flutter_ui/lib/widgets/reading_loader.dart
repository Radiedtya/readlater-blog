import 'package:flutter/material.dart';

class ReadingLoader extends StatefulWidget {
  final String? label;
  final Color accent;

  const ReadingLoader({
    super.key,
    this.label,
    this.accent = const Color(0xFFB36F8B),
  });

  @override
  State<ReadingLoader> createState() => _ReadingLoaderState();
}

class _ReadingLoaderState extends State<ReadingLoader>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.94,
      upperBound: 1.04,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicator = Semantics(
      label: widget.label ?? 'Memuat',
      child: SizedBox(
        width: 48,
        height: 48,
        child: RotationTransition(
          turns: _rotationController,
          child: CircularProgressIndicator(
            value: 0.72,
            strokeWidth: 3,
            strokeCap: StrokeCap.round,
            color: widget.accent,
            backgroundColor: widget.accent.withValues(alpha: 0.14),
          ),
        ),
      ),
    );

    if (widget.label == null) return indicator;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              indicator,
              ScaleTransition(
                scale: _pulseController,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 20,
                  color: widget.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.label!,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
