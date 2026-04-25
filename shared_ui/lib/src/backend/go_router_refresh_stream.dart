import 'dart:async';
import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that listens to a [Stream] and calls [notifyListeners]
/// every time the stream emits a new value. This is useful for `refreshListenable` in GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
