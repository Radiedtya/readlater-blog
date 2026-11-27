import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

Future<Uint8List?> showProfileImageCropDialog(
  BuildContext context,
  Uint8List imageBytes,
) {
  return showDialog<Uint8List>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProfileImageCropDialog(imageBytes: imageBytes),
  );
}

class ProfileImageCropDialog extends StatefulWidget {
  final Uint8List imageBytes;

  const ProfileImageCropDialog({super.key, required this.imageBytes});

  @override
  State<ProfileImageCropDialog> createState() => _ProfileImageCropDialogState();
}

class _ProfileImageCropDialogState extends State<ProfileImageCropDialog> {
  final _controller = CropController();
  bool _cropping = false;
  String? _error;

  void _crop() {
    setState(() {
      _cropping = true;
      _error = null;
    });
    _controller.crop();
  }

  void _onCropped(CropResult result) {
    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.of(context).pop(croppedImage);
      case CropFailure(:final cause):
        debugPrint('Gagal memotong foto profil: $cause');
        setState(() {
          _cropping = false;
          _error = 'Foto tidak dapat diproses. Coba pilih gambar lain.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atur foto profil',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Geser atau perbesar foto, lalu posisikan di dalam lingkaran.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Crop(
                    image: widget.imageBytes,
                    controller: _controller,
                    aspectRatio: 1,
                    withCircleUi: true,
                    interactive: true,
                    fixCropRect: true,
                    baseColor: const Color(0xFF25241F),
                    maskColor: Colors.black.withValues(alpha: 0.55),
                    onCropped: _onCropped,
                    progressIndicator: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _cropping
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _cropping ? null : _crop,
                    child: _cropping
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Gunakan foto'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
