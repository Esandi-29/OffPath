import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

/// ViewModel for the auth screens. Its state is loading / error / done,
/// which the screens use to show a spinner or an error message.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}

final authControllerProvider =
AsyncNotifierProvider<AuthController, void>(AuthController.new);