import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../model/post_model.dart';

class PostFormPage extends StatefulWidget {
  final PostModel? post;

  const PostFormPage({super.key, this.post});

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _usernameController;
  late TextEditingController _subtitleController;
  late TextEditingController _dateController;
  late TextEditingController _likesController;
  late TextEditingController _commentsController;
  late TextEditingController _sharesController;
  late TextEditingController _sendsController;

  final List<TextEditingController> _imageControllers = [];
  final List<String> _localImagePaths = [];

  bool get isEditing => widget.post != null;

  String? _locationName;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    final post = widget.post;

    _usernameController = TextEditingController(text: post?.username ?? '');
    _subtitleController = TextEditingController(text: post?.subtitle ?? '');
    _dateController = TextEditingController(text: post?.date ?? '');
    _likesController = TextEditingController(
      text: post?.likes.toString() ?? '0',
    );
    _commentsController = TextEditingController(
      text: post?.comments.toString() ?? '0',
    );
    _sharesController = TextEditingController(
      text: post?.shares.toString() ?? '0',
    );
    _sendsController = TextEditingController(
      text: post?.sends.toString() ?? '0',
    );

    _locationName = post?.locationName;
    _latitude = post?.latitude;
    _longitude = post?.longitude;

    if (post != null && post.imageUrls.isNotEmpty) {
      for (final url in post.imageUrls) {
        _imageControllers.add(TextEditingController(text: url));
      }
    } else {
      _imageControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _subtitleController.dispose();
    _dateController.dispose();
    _likesController.dispose();
    _commentsController.dispose();
    _sharesController.dispose();
    _sendsController.dispose();
    for (final c in _imageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addImageField() {
    setState(() {
      _imageControllers.add(TextEditingController());
    });
  }

  void _removeImageField(int index) {
    if (_imageControllers.length > 1) {
      setState(() {
        _imageControllers[index].dispose();
        _imageControllers.removeAt(index);
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _localImagePaths.add(photo.path);
          final emptyIndex = _imageControllers.indexWhere(
            (c) => c.text.trim().isEmpty,
          );
          if (emptyIndex != -1) {
            _imageControllers[emptyIndex].text = photo.path;
          } else {
            _imageControllers.add(TextEditingController(text: photo.path));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir câmera: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          for (final img in images) {
            _localImagePaths.add(img.path);
            final emptyIndex = _imageControllers.indexWhere(
              (c) => c.text.trim().isEmpty,
            );
            if (emptyIndex != -1) {
              _imageControllers[emptyIndex].text = img.path;
            } else {
              _imageControllers.add(TextEditingController(text: img.path));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir galeria: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Serviço de localização desativado'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permissão de localização negada'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permissão de localização negada permanentemente. Ative nas configurações.',
              ),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = <String>[];
          if (place.subLocality?.isNotEmpty == true) {
            parts.add(place.subLocality!);
          }
          if (place.locality?.isNotEmpty == true) {
            parts.add(place.locality!);
          }
          if (place.administrativeArea?.isNotEmpty == true) {
            parts.add(place.administrativeArea!);
          }
          _locationName = parts.join(', ');
          _subtitleController.text = _locationName ?? '';
        }
      } catch (_) {
        _locationName =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _subtitleController.text = _locationName ?? '';
      }

      setState(() => _isLoadingLocation = false);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final imageUrls = _imageControllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos uma imagem'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final post = PostModel(
      id: widget.post?.id ?? '',
      username: _usernameController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      imageUrls: imageUrls,
      likes: int.tryParse(_likesController.text) ?? 0,
      comments: int.tryParse(_commentsController.text) ?? 0,
      shares: int.tryParse(_sharesController.text) ?? 0,
      sends: int.tryParse(_sendsController.text) ?? 0,
      date: _dateController.text.trim(),
      isLiked: widget.post?.isLiked ?? false,
      isSaved: widget.post?.isSaved ?? false,
      latitude: _latitude,
      longitude: _longitude,
      locationName: _locationName,
    );

    Navigator.pop(context, post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          isEditing ? 'Editar Postagem' : 'Nova Postagem',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _usernameController,
              label: 'Nome de usuário',
              icon: Icons.person,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Informe o nome de usuário';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Subtitle / Location
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _subtitleController,
                    label: 'Localização',
                    icon: Icons.location_on,
                  ),
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: _isLoadingLocation
                      ? Icons.hourglass_top
                      : Icons.my_location,
                  onTap: _isLoadingLocation ? null : _getLocation,
                  tooltip: 'Obter localização atual',
                ),
              ],
            ),
            if (_locationName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.place, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _locationName!,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            _buildTextField(
              controller: _dateController,
              label: 'Data (ex: 2 de fevereiro)',
              icon: Icons.calendar_today,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Informe a data';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _likesController,
                    label: 'Curtidas',
                    icon: Icons.favorite,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _commentsController,
                    label: 'Comentários',
                    icon: Icons.chat_bubble,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _sharesController,
                    label: 'Compartilh.',
                    icon: Icons.repeat,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _sendsController,
                    label: 'Envios',
                    icon: Icons.send,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Images section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Imagens',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildIconButton(
                      icon: Icons.camera_alt,
                      onTap: _takePhoto,
                      tooltip: 'Tirar foto',
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      icon: Icons.photo_library,
                      onTap: _pickFromGallery,
                      tooltip: 'Galeria',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addImageField,
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.accent,
                      ),
                      tooltip: 'Adicionar URL',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...List.generate(_imageControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _imageControllers[index],
                        label: 'Imagem ${index + 1}',
                        icon: Icons.image,
                      ),
                    ),
                    if (_imageControllers.length > 1)
                      IconButton(
                        onPressed: () => _removeImageField(index),
                        icon: const Icon(
                          Icons.remove_circle,
                          color: AppColors.danger,
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Image preview
            _buildImagePreviews(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviews() {
    final allPaths = _imageControllers
        .map((c) => c.text.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (allPaths.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allPaths.length,
        itemBuilder: (context, index) {
          final path = allPaths[index];
          final isLocal = !path.startsWith('http');

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isLocal
                    ? Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildErrorPreview(),
                      )
                    : Image.network(
                        path,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildErrorPreview(),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorPreview() {
    return Container(
      width: 120,
      height: 120,
      color: AppColors.surface,
      child: const Icon(Icons.broken_image, color: AppColors.textHint),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
          ),
          child: Icon(icon, color: AppColors.accent, size: 22),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 20),
        filled: true,
        fillColor: AppColors.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
