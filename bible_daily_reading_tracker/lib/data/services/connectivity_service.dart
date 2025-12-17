import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  StreamController<bool>? _connectivityController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  bool _isOnline = true;

  /// Get current connectivity status
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes (true = online, false = offline)
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _updateConnectivityStatus();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(_onConnectivityChanged);
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) async {
    await _updateConnectivityStatus();
  }

  /// Update connectivity status
  Future<void> _updateConnectivityStatus () async {
    final result = await _connectivity.checkConnectivity();
    final wasOnline = _isOnline;
    
    // Check if we have any connection
    _isOnline = result != ConnectivityResult.none;

    // Notify listeners if status changed
    if (wasOnline != _isOnline) {
      _connectivityController?.add(_isOnline);
    }
  }

  /// Manually check connectivity
  Future<bool> checkConnectivity() async {
    await _updateConnectivityStatus();
    return _isOnline;
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}
