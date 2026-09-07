import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity and exposes a stream of online/offline state.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamController<bool> _controller;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  Stream<bool> get onlineStream => _controller.stream;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _controller = StreamController<bool>.broadcast();
  }

  /// Start monitoring connectivity. Call this once during app initialization.
  Future<void> init() async {
    // Check initial state
    final results = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(results);

    // Subscribe to changes
    _subscription =
        _connectivity.onConnectivityChanged.listen((results) {
      final online = _isConnected(results);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(online);
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) =>
      results.any((r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet);

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
