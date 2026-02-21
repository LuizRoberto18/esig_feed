import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/global.dart';
import '../../../core/stores/post_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../model/post_model.dart';
import 'post_form_page.dart';

/// Tela de detalhes do post.
/// Exibe todas as informações de um post específico em formato detalhado,
/// Permite editar e excluir o post diretamente desta tela.
class PostDetailPage extends StatefulWidget {
  /// Post a ser exibido nos detalhes
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
                Navigator.pop(context, true); // Retorna true indicando exclusão
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
            _buildUserHeader(),

            // Carrossel de imagens do post
            _buildImageCarousel(),

            // Indicadores de página do carrossel
            if (_currentPost.imageUrls.length > 1) _buildPageIndicators(),

            // Botões de interação (curtir, comentar, compartilhar, etc.)
            _buildInteractionButtons(),

            // Seção de detalhes textuais do post
            _buildDetailsSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Constrói o cabeçalho com avatar e nome do usuário
  Widget _buildUserHeader() {
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
                      _currentPost.username.isNotEmpty
                          ? _currentPost.username[0].toUpperCase()
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

          // Nome de usuário e subtítulo/descrição
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentPost.username,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_currentPost.subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _currentPost.subtitle,
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

  /// Constrói o carrossel de imagens do post
  Widget _buildImageCarousel() {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _currentPost.imageUrls.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          final imageUrl = _currentPost.imageUrls[index];
          final isLocal = !imageUrl.startsWith('http');

          // Suporte para imagens locais (câmera/galeria) e URLs da web
          return isLocal
              ? Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _buildImageError(),
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
                  errorBuilder: (_, __, ___) => _buildImageError(),
                );
        },
      ),
    );
  }

  /// Constrói indicadores de página (pontos) abaixo do carrossel
  Widget _buildPageIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _currentPost.imageUrls.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _currentPage == index ? 10 : 6,
            height: _currentPage == index ? 10 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? AppColors.accent
                  : AppColors.primaryLight.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói os botões de interação (curtir, comentar, compartilhar, enviar, salvar)
  Widget _buildInteractionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Botão de curtir
          _buildActionButton(
            icon: _currentPost.isLiked ? Icons.favorite : Icons.favorite_border,
            color: _currentPost.isLiked
                ? AppColors.danger
                : AppColors.textPrimary,
            label: formatNumber(_currentPost.likes),
            onTap: () async {
              await _postStore.toggleLike(_currentPost.id);
              // Atualiza o post local com os novos dados
              final updated = _postStore.posts.firstWhere(
                (p) => p.id == _currentPost.id,
                orElse: () => _currentPost,
              );
              setState(() => _currentPost = updated);
            },
          ),
          const SizedBox(width: 20),

          // Botão de comentários
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            color: AppColors.textPrimary,
            label: formatNumber(_currentPost.comments),
            onTap: () {},
          ),
          const SizedBox(width: 20),

          // Botão de compartilhar
          _buildActionButton(
            icon: Icons.repeat,
            color: AppColors.textPrimary,
            label: formatNumber(_currentPost.shares),
            onTap: () {},
          ),
          const SizedBox(width: 20),

          // Botão de enviar
          _buildActionButton(
            icon: Icons.send_outlined,
            color: AppColors.textPrimary,
            label: formatNumber(_currentPost.sends),
            onTap: () {},
          ),

          const Spacer(),

          // Botão de salvar/favoritar
          GestureDetector(
            onTap: () async {
              await _postStore.toggleSave(_currentPost.id);
              final updated = _postStore.posts.firstWhere(
                (p) => p.id == _currentPost.id,
                orElse: () => _currentPost,
              );
              setState(() => _currentPost = updated);
            },
            child: Icon(
              _currentPost.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _currentPost.isSaved
                  ? AppColors.accent
                  : AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção de detalhes textuais do post
  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Contador de curtidas
          Text(
            '${formatNumber(_currentPost.likes)} curtidas',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 12),

          // Informação de localização (se disponível)
          if (_currentPost.locationName != null &&
              _currentPost.locationName!.isNotEmpty)
            _buildDetailRow(
              icon: Icons.place,
              label: 'Localização',
              value: _currentPost.locationName!,
              iconColor: AppColors.accent,
            ),

          // Coordenadas GPS (se disponíveis)
          if (_currentPost.latitude != null && _currentPost.longitude != null)
            _buildDetailRow(
              icon: Icons.gps_fixed,
              label: 'Coordenadas',
              value:
                  '${_currentPost.latitude!.toStringAsFixed(4)}, ${_currentPost.longitude!.toStringAsFixed(4)}',
              iconColor: AppColors.primaryLight,
            ),

          // Data do post
          if (_currentPost.date.isNotEmpty)
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Data',
              value: _currentPost.date,
              iconColor: AppColors.primaryLight,
            ),

          const SizedBox(height: 16),

          // Seção de estatísticas detalhadas
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
              _buildStatCard(
                'Curtidas',
                _currentPost.likes,
                Icons.favorite,
                AppColors.danger,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Comentários',
                _currentPost.comments,
                Icons.chat_bubble,
                AppColors.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                'Compartilh.',
                _currentPost.shares,
                Icons.repeat,
                AppColors.accent,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Envios',
                _currentPost.sends,
                Icons.send,
                AppColors.success,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Número de imagens no post
          _buildDetailRow(
            icon: Icons.photo_library,
            label: 'Imagens',
            value: '${_currentPost.imageUrls.length} foto(s)',
            iconColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  /// Constrói uma linha de detalhe com ícone, rótulo e valor
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = AppColors.textPrimary,
  }) {
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

  /// Constrói um card de estatística com ícone, valor e rótulo
  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
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

  /// Constrói um botão de ação com ícone e contagem
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
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

  /// Widget de fallback quando uma imagem não carrega
  Widget _buildImageError() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: AppColors.textHint,
          size: 60,
        ),
      ),
    );
  }
}
