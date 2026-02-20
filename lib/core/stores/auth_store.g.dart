part of 'auth_store.dart';

mixin _$AuthStore on _AuthStoreBase, Store {
  late final _$usernameAtom = Atom(
    name: '_AuthStoreBase.username',
    context: context,
  );

  @override
  String get username {
    _$usernameAtom.reportRead();
    return super.username;
  }

  @override
  set username(String value) {
    _$usernameAtom.reportWrite(value, super.username, () {
      super.username = value;
    });
  }

  late final _$passwordAtom = Atom(
    name: '_AuthStoreBase.password',
    context: context,
  );

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_AuthStoreBase.isLoading',
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

  late final _$isAuthenticatedAtom = Atom(
    name: '_AuthStoreBase.isAuthenticated',
    context: context,
  );

  @override
  bool get isAuthenticated {
    _$isAuthenticatedAtom.reportRead();
    return super.isAuthenticated;
  }

  @override
  set isAuthenticated(bool value) {
    _$isAuthenticatedAtom.reportWrite(value, super.isAuthenticated, () {
      super.isAuthenticated = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_AuthStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$canUseBiometricsAtom = Atom(
    name: '_AuthStoreBase.canUseBiometrics',
    context: context,
  );

  @override
  bool get canUseBiometrics {
    _$canUseBiometricsAtom.reportRead();
    return super.canUseBiometrics;
  }

  @override
  set canUseBiometrics(bool value) {
    _$canUseBiometricsAtom.reportWrite(value, super.canUseBiometrics, () {
      super.canUseBiometrics = value;
    });
  }

  late final _$isBiometricLoadingAtom = Atom(
    name: '_AuthStoreBase.isBiometricLoading',
    context: context,
  );

  @override
  bool get isBiometricLoading {
    _$isBiometricLoadingAtom.reportRead();
    return super.isBiometricLoading;
  }

  @override
  set isBiometricLoading(bool value) {
    _$isBiometricLoadingAtom.reportWrite(value, super.isBiometricLoading, () {
      super.isBiometricLoading = value;
    });
  }

  late final _$checkBiometricsAsyncAction = AsyncAction(
    '_AuthStoreBase.checkBiometrics',
    context: context,
  );

  @override
  Future<void> checkBiometrics() {
    return _$checkBiometricsAsyncAction.run(() => super.checkBiometrics());
  }

  late final _$authenticateWithBiometricsAsyncAction = AsyncAction(
    '_AuthStoreBase.authenticateWithBiometrics',
    context: context,
  );

  @override
  Future<bool> authenticateWithBiometrics() {
    return _$authenticateWithBiometricsAsyncAction.run(
      () => super.authenticateWithBiometrics(),
    );
  }

  late final _$loginAsyncAction = AsyncAction(
    '_AuthStoreBase.login',
    context: context,
  );

  @override
  Future<bool> login() {
    return _$loginAsyncAction.run(() => super.login());
  }

  late final _$_AuthStoreBaseActionController = ActionController(
    name: '_AuthStoreBase',
    context: context,
  );

  @override
  void setUsername(String value) {
    final _$actionInfo = _$_AuthStoreBaseActionController.startAction(
      name: '_AuthStoreBase.setUsername',
    );
    try {
      return super.setUsername(value);
    } finally {
      _$_AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPassword(String value) {
    final _$actionInfo = _$_AuthStoreBaseActionController.startAction(
      name: '_AuthStoreBase.setPassword',
    );
    try {
      return super.setPassword(value);
    } finally {
      _$_AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void logout() {
    final _$actionInfo = _$_AuthStoreBaseActionController.startAction(
      name: '_AuthStoreBase.logout',
    );
    try {
      return super.logout();
    } finally {
      _$_AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
username: ${username},
password: ${password},
isLoading: ${isLoading},
isAuthenticated: ${isAuthenticated},
errorMessage: ${errorMessage},
canUseBiometrics: ${canUseBiometrics},
isBiometricLoading: ${isBiometricLoading}
    ''';
  }
}
