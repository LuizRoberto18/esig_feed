part of 'post_store.dart';

mixin _$PostStore on _PostStoreBase, Store {
  late final _$postsAtom = Atom(name: '_PostStoreBase.posts', context: context);

  @override
  ObservableList<PostModel> get posts {
    _$postsAtom.reportRead();
    return super.posts;
  }

  @override
  set posts(ObservableList<PostModel> value) {
    _$postsAtom.reportWrite(value, super.posts, () {
      super.posts = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_PostStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$_PostStoreBaseActionController = ActionController(
    name: '_PostStoreBase',
    context: context,
  );

  @override
  void loadPosts() {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.loadPosts',
    );
    try {
      return super.loadPosts();
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addPost(PostModel post) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.addPost',
    );
    try {
      return super.addPost(post);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updatePost(PostModel post) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.updatePost',
    );
    try {
      return super.updatePost(post);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deletePost(String id) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.deletePost',
    );
    try {
      return super.deletePost(id);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleLike(String id) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.toggleLike',
    );
    try {
      return super.toggleLike(id);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleSave(String id) {
    final _$actionInfo = _$_PostStoreBaseActionController.startAction(
      name: '_PostStoreBase.toggleSave',
    );
    try {
      return super.toggleSave(id);
    } finally {
      _$_PostStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
posts: ${posts},
isLoading: ${isLoading}
    ''';
  }
}
