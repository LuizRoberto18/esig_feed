import 'package:mobx/mobx.dart';

import '../../data/model/post_model.dart';
import '../../data/repository/post_repository.dart';

part 'post_store.g.dart';

/// Store MobX responsável pelo gerenciamento de estado dos posts do feed.
/// Gerencia operações de CRUD (criar, ler, atualizar, deletar) dos posts,
/// além de interações como curtir e salvar.
/// Utiliza o PostRepository para persistência e consumo de API.
class PostStore = _PostStoreBase with _$PostStore;

abstract class _PostStoreBase with Store {
  /// Repositório que gerencia a persistência e busca de posts
  final PostRepository _repository = PostRepository();

  /// Lista observável de posts exibidos no feed
  @observable
  ObservableList<PostModel> posts = ObservableList<PostModel>();

  /// Indica se os posts estão sendo carregados (loading state)
  @observable
  bool isLoading = false;

  /// Mensagem de erro caso ocorra falha ao carregar posts
  @observable
  String? errorMessage;

  /// Carrega os posts do repositório (API ou armazenamento local).
  /// Exibe indicador de carregamento enquanto busca os dados.
  @action
  Future<void> loadPosts() async {
    isLoading = true;
    errorMessage = null;
    try {
      final loadedPosts = await _repository.loadPosts();
      posts = ObservableList.of(loadedPosts);
    } catch (e) {
      errorMessage = 'Erro ao carregar posts: $e';
    }
    isLoading = false;
  }

  /// Adiciona um novo post ao feed.
  /// O post é inserido no topo da lista e salvo localmente.
  @action
  Future<void> addPost(PostModel post) async {
    await _repository.add(post);
    posts = ObservableList.of(_repository.getAll());
  }

  /// Atualiza os dados de um post existente.
  /// Busca o post pelo ID e substitui com os novos dados.
  @action
  Future<void> updatePost(PostModel post) async {
    await _repository.update(post);
    posts = ObservableList.of(_repository.getAll());
  }

  /// Remove um post do feed pelo seu ID.
  @action
  Future<void> deletePost(String id) async {
    await _repository.delete(id);
    posts = ObservableList.of(_repository.getAll());
  }

  /// Alterna o estado de curtida de um post (curtir/descurtir).
  @action
  Future<void> toggleLike(String id) async {
    await _repository.toggleLike(id);
    posts = ObservableList.of(_repository.getAll());
  }

  /// Alterna o estado de salvo/favoritado de um post.
  @action
  Future<void> toggleSave(String id) async {
    await _repository.toggleSave(id);
    posts = ObservableList.of(_repository.getAll());
  }
}
