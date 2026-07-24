import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// NetworkInfo Abstract Class
/// Defines the contract for network connectivity checking
abstract class NetworkInfo {
  /// Check if device has internet connection
  Future<bool> get isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged;

  /// Get current connectivity type
  Future<List<ConnectivityResult>> get connectivityResult;

  /// Dispose resources
  void dispose();
}

/// NetworkInfoImpl - Production Implementation
/// Uses connectivity_plus for network transport state.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _lastKnownStatus = true;

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _initConnectivityStream();
  }

  void _initConnectivityStream() {
    _connectivityController = StreamController<bool>.broadcast();

    // Listen to connectivity changes (WiFi, Mobile, None)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final hasInternet = _hasNetworkTransport(results);
      if (hasInternet != _lastKnownStatus) {
        _lastKnownStatus = hasInternet;
        _connectivityController?.add(hasInternet);
      }
    });
  }

  bool _hasNetworkTransport(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasNetworkTransport(results);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivityController?.stream ?? const Stream.empty();
  }

  @override
  Future<List<ConnectivityResult>> get connectivityResult async {
    return await _connectivity.checkConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}

/// Connection Type Helper
enum ConnectionType { wifi, mobile, ethernet, none, unknown }

/// Extension to get ConnectionType from ConnectivityResult
extension ConnectivityResultExtension on List<ConnectivityResult> {
  ConnectionType get connectionType {
    if (contains(ConnectivityResult.wifi)) return ConnectionType.wifi;
    if (contains(ConnectivityResult.mobile)) return ConnectionType.mobile;
    if (contains(ConnectivityResult.ethernet)) return ConnectionType.ethernet;
    if (contains(ConnectivityResult.vpn)) return ConnectionType.unknown;
    if (contains(ConnectivityResult.other)) return ConnectionType.unknown;
    if (contains(ConnectivityResult.none)) return ConnectionType.none;
    return ConnectionType.unknown;
  }
}
