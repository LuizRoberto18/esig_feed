import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/post_model.dart';
import 'local_storage_service.dart';

/// Repositório de posts do feed.
/// Responsável por buscar posts da API JSONPlaceholder e gerenciar
/// a persistência local dos dados (CRUD completo).
/// Utiliza o padrão Singleton para garantir uma única instância.
class PostRepository {
  static final PostRepository _instance = PostRepository._internal();
  factory PostRepository() => _instance;
  PostRepository._internal();

  /// Serviço de armazenamento local para persistir os posts
  final LocalStorageService _storage = LocalStorageService();

  /// Nome do arquivo onde os posts são salvos localmente
  static const String _storageKey = 'posts';

  /// URL base da API JSONPlaceholder para buscar as fotos
  static const String _apiBaseUrl = 'https://jsonplaceholder.typicode.com';

  /// Lista interna de posts carregados em memória
  List<PostModel> _posts = [];

  /// Contador para gerar IDs únicos para novos posts
  int _nextId = 10000;

  /// Indica se os posts já foram carregados da API/storage
  bool _isInitialized = false;

  /// Retorna todos os posts carregados.
  List<PostModel> getAll() => List.unmodifiable(_posts);

  /// Busca um post específico pelo seu ID.
  /// Retorna null caso não encontre.
  PostModel? getById(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Carrega os posts iniciais.
  /// Primeiro tenta carregar do armazenamento local (persistência).
  /// Se não houver dados locais, busca da API JSONPlaceholder.
  Future<List<PostModel>> loadPosts() async {
    if (_isInitialized && _posts.isNotEmpty) {
      return getAll();
    }

    // Tenta carregar posts salvos localmente primeiro
    final localData = await _storage.loadList(_storageKey);
    if (localData.isNotEmpty) {
      _posts = localData.map((json) => PostModel.fromJson(json)).toList();
      _isInitialized = true;

      // Atualiza o nextId baseado nos posts existentes
      _atualizarNextId();
      return getAll();
    }

    // Se não há dados locais, busca da API
    await _fetchFromApi();
    _isInitialized = true;
    return getAll();
  }

  /// Busca posts da API JSONPlaceholder (/photos).
  /// Limita a 30 posts para não sobrecarregar o feed.
  /// Salva os dados obtidos localmente para acesso offline.
  Future<void> _fetchFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/photos?_limit=30'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        // Converte cada item da API para o modelo de Post do feed
        _posts = jsonList
            .map((json) => PostModel.fromApiJson(json as Map<String, dynamic>))
            .toList();

        // Atualiza o nextId e persiste localmente
        _atualizarNextId();
        await _salvarLocalmente();
      } else {
        // Em caso de erro na API, gera posts de exemplo
        _posts = _gerarPostsExemplo();
      }
    } catch (e) {
      // Se houver erro de conexão, usa posts de exemplo offline
      print('Erro ao buscar dados da API: $e');
      _posts = _gerarPostsExemplo();
      await _salvarLocalmente();
    }
  }

  /// Adiciona um novo post ao feed.
  /// Gera um ID único e salva localmente.
  Future<void> add(PostModel post) async {
    final newPost = post.copyWith(id: (_nextId++).toString());
    _posts.insert(0, newPost); // Insere no topo do feed
    await _salvarLocalmente();
  }

  /// Atualiza um post existente.
  /// Localiza pelo ID e substitui os dados.
  Future<void> update(PostModel post) async {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = post;
      await _salvarLocalmente();
    }
  }

  /// Remove um post pelo seu ID.
  Future<void> delete(String id) async {
    _posts.removeWhere((p) => p.id == id);
    await _salvarLocalmente();
  }

  /// Alterna o estado de "curtida" de um post.
  /// Incrementa ou decrementa o contador de likes.
  Future<void> toggleLike(String id) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      );
      await _salvarLocalmente();
    }
  }

  /// Alterna o estado de "salvo/favorito" de um post.
  Future<void> toggleSave(String id) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(isSaved: !post.isSaved);
      await _salvarLocalmente();
    }
  }

  /// Persiste a lista de posts no armazenamento local do dispositivo.
  Future<void> _salvarLocalmente() async {
    final jsonList = _posts.map((p) => p.toJson()).toList();
    await _storage.saveList(_storageKey, jsonList);
  }

  /// Atualiza o contador de IDs para evitar colisões ao criar novos posts.
  void _atualizarNextId() {
    for (final post in _posts) {
      final id = int.tryParse(post.id) ?? 0;
      if (id >= _nextId) {
        _nextId = id + 1;
      }
    }
  }

  /// Gera posts de exemplo para uso offline (fallback quando a API falha).
  List<PostModel> _gerarPostsExemplo() {
    return [
      PostModel(
        id: '1',
        username: 'carlos.dev',
        subtitle: 'Desenvolvedor Flutter',
        imageUrls: [
          'https://picsum.photos/seed/beach1/600/600',
          'https://picsum.photos/seed/beach2/600/600',
        ],
        likes: 1218,
        comments: 47,
        shares: 6,
        sends: 27,
        date: '2 de fevereiro',
      ),
      PostModel(
        id: '2',
        username: 'ana_fotografia',
        subtitle: 'São Paulo, Brasil',
        imageUrls: ['https://picsum.photos/seed/city1/600/600'],
        likes: 532,
        comments: 23,
        shares: 2,
        sends: 12,
        date: '5 de fevereiro',
      ),
      PostModel(
        id: '3',
        username: 'marcos_viagem',
        subtitle: 'Rio de Janeiro',
        imageUrls: [
          'https://picsum.photos/seed/travel1/600/600',
          'https://picsum.photos/seed/travel2/600/600',
          'https://picsum.photos/seed/travel3/600/600',
        ],
        likes: 876,
        comments: 34,
        shares: 8,
        sends: 19,
        date: '14 de fevereiro',
      ),
      PostModel(
        id: '4',
        username: 'julia_fitness',
        subtitle: 'Personal Trainer',
        imageUrls: ['https://picsum.photos/seed/fitness1/600/600'],
        likes: 2100,
        comments: 56,
        shares: 20,
        sends: 35,
        date: '18 de fevereiro',
      ),
      PostModel(
        id: '5',
        username: 'pedro_arte',
        subtitle: 'Artista Digital',
        imageUrls: [
          'https://picsum.photos/seed/art1/600/600',
          'https://picsum.photos/seed/art2/600/600',
        ],
        likes: 3450,
        comments: 89,
        shares: 15,
        sends: 42,
        date: '20 de fevereiro',
      ),
    ];
  }
}
