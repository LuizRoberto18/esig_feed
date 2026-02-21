import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/global.dart';
import '../../../core/theme/app_colors.dart';
import '../../model/post_model.dart';
import 'post_card_image_error.dart';

/// Card de post no feed, estilo rede social.
/// Exibe o cabeçalho do usuário, carrossel de imagens, botões de interação
/// e informações do post. Suporta ações de edição, exclusão, curtir e salvar.
class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Callback para alternar curtida
  final VoidCallback onToggleLike;

  /// Callback para alternar favorito/salvo
  final VoidCallback onToggleSave;

  /// Callback para navegação à tela de detalhes do post
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleLike,
    required this.onToggleSave,
    this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    // GestureDetector para detectar toque e navegar aos detalhes
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: AppColors.primaryDark,
        margin: const EdgeInsets.only(bottom: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com avatar, nome, botão seguir e menu de opções
            _PostCardHeader(
              post: post,
              onEdit: widget.onEdit,
              onDelete: _showDeleteDialog,
            ),
            // Carrossel de imagens com indicador de página
            _PostCardImageCarousel(
              post: post,
              pageController: _pageController,
              currentPage: _currentPage,
              onPageChanged: (index) => setState(() => _currentPage = index),
            ),
            // Botões de interação (curtir, comentar, compartilhar, enviar, salvar)
            _PostCardActions(
              post: post,
              currentPage: _currentPage,
              onToggleLike: widget.onToggleLike,
              onToggleSave: widget.onToggleSave,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '${formatNumber(post.likes)} curtidas',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            // Nome da localização (exibido se disponível)
            if (post.locationName != null && post.locationName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place, color: AppColors.accent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      post.locationName!,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                post.date,
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  /// Exibe diálogo de confirmação para exclusão do post
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Excluir postagem',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Tem certeza que deseja excluir esta postagem?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete();
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Constrói o cabeçalho do card com avatar, nome de usuário e opções
class _PostCardHeader extends StatelessWidget {
  final PostModel post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PostCardHeader({
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar com borda gradiente estilo stories
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.storyGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundColor: AppColors.surface,
                    child: Text(
                      post.username.isNotEmpty
                          ? post.username[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Nome de usuário e subtítulo/descrição
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (post.subtitle.isNotEmpty)
                  Text(
                    post.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Botão "Seguir" estilizado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.accent,
            ),
            child: const Text(
              'Seguir',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Menu popup com opções de editar e excluir
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
              size: 20,
            ),
            color: AppColors.surface,
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.textPrimary, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Editar',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.accent, size: 18),
                    SizedBox(width: 10),
                    Text('Excluir', style: TextStyle(color: AppColors.accent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///Carrossel de imagens com indicador de posição
class _PostCardImageCarousel extends StatelessWidget {
  final PostModel post;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _PostCardImageCarousel({
    required this.post,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: pageController,
            itemCount: post.imageUrls.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final imageUrl = post.imageUrls[index];
              final isLocal = !imageUrl.startsWith('http');

              return isLocal
                  ? Image.file(
                      File(imageUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const PostCardImageError();
                      },
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const PostCardImageError();
                      },
                    );
            },
          ),
        ),
        if (post.imageUrls.length > 1)
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currentPage + 1}/${post.imageUrls.length}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Constrói a barra de botões de interação abaixo da imagem
class _PostCardActions extends StatelessWidget {
  final PostModel post;
  final int currentPage;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleSave;

  const _PostCardActions({
    required this.post,
    required this.currentPage,
    required this.onToggleLike,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          // Botão de curtida com indicador visual de estado
          _ActionIconWithCount(
            icon: post.isLiked
                ? Icons.favorite
                : Icons.favorite_border_outlined,
            color: post.isLiked ? AppColors.danger : AppColors.textPrimary,
            count: formatNumber(post.likes),
            onTap: onToggleLike,
          ),
          const SizedBox(width: 12),

          // Botão de comentários
          _ActionIconWithCount(
            icon: Icons.chat_bubble_outline,
            color: AppColors.textPrimary,
            count: formatNumber(post.comments),
            onTap: () {},
          ),
          const SizedBox(width: 12),

          // Botão de compartilhamento
          _ActionIconWithCount(
            icon: Icons.repeat,
            color: AppColors.textPrimary,
            count: formatNumber(post.shares),
            onTap: () {},
          ),
          const SizedBox(width: 12),

          // Botão de envio direto
          _ActionIconWithCount(
            icon: Icons.send_outlined,
            color: AppColors.textPrimary,
            count: formatNumber(post.sends),
            onTap: () {},
          ),
          const Spacer(),
          if (post.imageUrls.length > 1)
            Row(
              children: List.generate(post.imageUrls.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index
                        ? AppColors.accent
                        : AppColors.primaryLight.withOpacity(0.5),
                  ),
                );
              }),
            ),
          const Spacer(),

          // Botão de salvar/favoritar
          GestureDetector(
            onTap: onToggleSave,
            child: Icon(
              post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: post.isSaved ? AppColors.accent : AppColors.textPrimary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIconWithCount extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String count;
  final VoidCallback onTap;

  const _ActionIconWithCount({
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 4),
          Text(
            count,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
