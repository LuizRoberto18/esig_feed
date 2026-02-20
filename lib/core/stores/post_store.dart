import 'package:mobx/mobx.dart';

import '../../data/model/post_model.dart';
import '../../data/repository/post_repository.dart';

part 'post_store.g.dart';

class PostStore = _PostStoreBase with _$PostStore;

abstract class _PostStoreBase with Store {
  final PostRepository _repository = PostRepository();

  @observable
  ObservableList<PostModel> posts = ObservableList<PostModel>();

  @observable
  bool isLoading = false;

  @action
  void loadPosts() {
    isLoading = true;
    posts = ObservableList.of(_repository.getAll());
    isLoading = false;
  }

  @action
  void addPost(PostModel post) {
    _repository.add(post);
    posts = ObservableList.of(_repository.getAll());
  }

  @action
  void updatePost(PostModel post) {
    _repository.update(post);
    posts = ObservableList.of(_repository.getAll());
  }

  @action
  void deletePost(String id) {
    _repository.delete(id);
    posts = ObservableList.of(_repository.getAll());
  }

  @action
  void toggleLike(String id) {
    _repository.toggleLike(id);
    posts = ObservableList.of(_repository.getAll());
  }

  @action
  void toggleSave(String id) {
    _repository.toggleSave(id);
    posts = ObservableList.of(_repository.getAll());
  }
}
