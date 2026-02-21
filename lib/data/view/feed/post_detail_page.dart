import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/global.dart';
import '../../../core/stores/post_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../model/post_model.dart';
import '../widgets/post_card_image_error.dart';
import 'post_form_page.dart';

/// Tela de detalhes do post.
/// Exibe todas as informações de post específico em formato detalhado,
/// Permite editar e excluir o post diretamente desta tela.
class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  /// Store para gerenciar ações sobre o post (curtir, salvar, etc.)
  final PostStore _postStore = getIt<PostStore>();

  late PageController _pageController;
  int _currentPage = 0;
  late PostModel _currentPost;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPost = widget.post;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navega para a tela de edição do post.
  /// Ao retornar, atualiza o post no store e na tela de detalhes.
  Future<void> _editPost() async {
    final result = await Navigator.push<PostModel>(
      context,
      MaterialPageRoute(builder: (_) => PostFormPage(post: _currentPost)),
    );
    if (result != null) {
      await _postStore.updatePost(result);
      setState(() {
        _currentPost = result;
      });
    }
  }

  /// Exibe diálogo de confirmação para exclusão do post.
  /// Após confirmação, remove o post e retorna à tela anterior.
  void _deletePost() {
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
            onPressed: () async {
              Navigator.pop(ctx);
              await _postStore.deletePost(_currentPost.id);
              if (mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike() async {
    await _postStore.toggleLike(_currentPost.id);
    final updated = _postStore.posts.firstWhere(
      (p) => p.id == _currentPost.id,
      orElse: () => _currentPost,
    );
    setState(() => _currentPost = updated);
  }

  Future<void> _toggleSave() async {
    await _postStore.toggleSave(_currentPost.id);
    final updated = _postStore.posts.firstWhere(
      (p) => p.id == _currentPost.id,
      orElse: () => _currentPost,
    );
    setState(() => _currentPost = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Detalhes do Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _editPost,
            icon: const Icon(Icons.edit, color: AppColors.accent),
            tooltip: 'Editar postagem',
          ),
          IconButton(
            onPressed: _deletePost,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            tooltip: 'Excluir postagem',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com informações do usuário
            _PostDetailUserHeader(post: _currentPost),
            // Carrossel de imagens do post
            _PostDetailImageCarousel(
              post: _currentPost,
              pageController: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
            ),
            // Indicadores de página do carrossel
            if (_currentPost.imageUrls.length > 1)
              _PostDetailPageIndicators(
                total: _currentPost.imageUrls.length,
                currentPage: _currentPage,
              ),
            // Botões de interação (curtir, comentar, compartilhar, etc.)
            _PostDetailInteractionButtons(
              post: _currentPost,
              onToggleLike: _toggleLike,
              onToggleSave: _toggleSave,
            ),
            // Seção de detalhes textuais do post
            _PostDetailDetailsSection(post: _currentPost),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

///  o cabeçalho com avatar e nome do usuário
class _PostDetailUserHeader extends StatelessWidget {
  final PostModel post;

  const _PostDetailUserHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar do usuário com borda gradiente
          Container(
            width: 50,
            height: 50,
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
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (post.subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      post.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostDetailImageCarousel extends StatelessWidget {
  final PostModel post;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  const _PostDetailImageCarousel({
    required this.post,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  errorBuilder: (context, error, stackTrace) =>
                      const PostCardImageError(),
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
                  errorBuilder: (context, error, stackTrace) =>
                      const PostCardImageError(),
                );
        },
      ),
    );
  }
}

///  indicadores de página (pontos) abaixo do carrossel
class _PostDetailPageIndicators extends StatelessWidget {
  final int total;
  final int currentPage;

  const _PostDetailPageIndicators({
    required this.total,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          total,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: currentPage == index ? 10 : 6,
            height: currentPage == index ? 10 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentPage == index
                  ? AppColors.accent
                  : AppColors.primaryLight.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

///  os botões de interação (curtir, comentar, compartilhar, enviar, salvar)
class _PostDetailInteractionButtons extends StatelessWidget {
  final PostModel post;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleSave;

  const _PostDetailInteractionButtons({
    required this.post,
    required this.onToggleLike,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Botão de curtir
          _PostDetailActionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            color: post.isLiked ? AppColors.danger : AppColors.textPrimary,
            label: formatNumber(post.likes),
            onTap: onToggleLike,
          ),
          const SizedBox(width: 20),
          // Botão de comentários
          _PostDetailActionButton(
            icon: Icons.chat_bubble_outline,
            color: AppColors.textPrimary,
            label: formatNumber(post.comments),
            onTap: () {},
          ),
          const SizedBox(width: 20),
          // Botão de compartilhar
          _PostDetailActionButton(
            icon: Icons.repeat,
            color: AppColors.textPrimary,
            label: formatNumber(post.shares),
            onTap: () {},
          ),
          const SizedBox(width: 20),
          // Botão de enviar
          _PostDetailActionButton(
            icon: Icons.send_outlined,
            color: AppColors.textPrimary,
            label: formatNumber(post.sends),
            onTap: () {},
          ),
          const Spacer(),
          // Botão de salvar/favoritar
          GestureDetector(
            onTap: onToggleSave,
            child: Icon(
              post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: post.isSaved ? AppColors.accent : AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

///  a seção de detalhes textuais do post
class _PostDetailDetailsSection extends StatelessWidget {
  final PostModel post;

  const _PostDetailDetailsSection({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            '${formatNumber(post.likes)} curtidas',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          // Informação de localização (se disponível)
          if (post.locationName != null && post.locationName!.isNotEmpty)
            _PostDetailRow(
              icon: Icons.place,
              label: 'Localização',
              value: post.locationName!,
              iconColor: AppColors.accent,
            ),
          // Coordenadas GPS (se disponíveis)
          if (post.latitude != null && post.longitude != null)
            _PostDetailRow(
              icon: Icons.gps_fixed,
              label: 'Coordenadas',
              value:
                  '${post.latitude!.toStringAsFixed(4)}, ${post.longitude!.toStringAsFixed(4)}',
              iconColor: AppColors.primaryLight,
            ),
          if (post.date.isNotEmpty)
            _PostDetailRow(
              icon: Icons.calendar_today,
              label: 'Data',
              value: post.date,
              iconColor: AppColors.primaryLight,
            ),
          const SizedBox(height: 16),
          const Text(
            'Estatísticas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          // Grid de estatísticas (curtidas, comentários, compartilhamentos, envios)
          Row(
            children: [
              _PostDetailStatCard(
                label: 'Curtidas',
                value: post.likes,
                icon: Icons.favorite,
                color: AppColors.danger,
              ),
              const SizedBox(width: 12),
              _PostDetailStatCard(
                label: 'Comentários',
                value: post.comments,
                icon: Icons.chat_bubble,
                color: AppColors.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PostDetailStatCard(
                label: 'Compartilh.',
                value: post.shares,
                icon: Icons.repeat,
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              _PostDetailStatCard(
                label: 'Envios',
                value: post.sends,
                icon: Icons.send,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PostDetailRow(
            icon: Icons.photo_library,
            label: 'Imagens',
            value: '${post.imageUrls.length} foto(s)',
            iconColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

/// linha de detalhe com ícone, rótulo e valor
class _PostDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _PostDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///  card de estatística com ícone, valor e rótulo
class _PostDetailStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _PostDetailStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              formatNumber(value),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///  botão de ação com ícone e contagem
class _PostDetailActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _PostDetailActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
