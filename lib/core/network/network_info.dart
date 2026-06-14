import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
/// Uses connectivity_plus for network type + internet_connection_checker for actual internet
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  final InternetConnectionChecker _connectionChecker;

  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  bool _lastKnownStatus = true;

  NetworkInfoImpl({
    Connectivity? connectivity,
    InternetConnectionChecker? connectionChecker,
  }) : _connectivity = connectivity ?? Connectivity(),
       _connectionChecker = connectionChecker ?? InternetConnectionChecker() {
    _initConnectivityStream();
  }

  void _initConnectivityStream() {
    _connectivityController = StreamController<bool>.broadcast();

    // Listen to connectivity changes (WiFi, Mobile, None)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) async {
      // Check actual internet when connectivity changes
      final hasInternet = await _checkActualInternet(results);
      if (hasInternet != _lastKnownStatus) {
        _lastKnownStatus = hasInternet;
        _connectivityController?.add(hasInternet);
      }
    });

    // Also listen to internet checker for more accurate status
    _internetSubscription = _connectionChecker.onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if (hasInternet != _lastKnownStatus) {
        _lastKnownStatus = hasInternet;
        _connectivityController?.add(hasInternet);
      }
    });
  }

  Future<bool> _checkActualInternet(List<ConnectivityResult> results) async {
    // If no connectivity at all, return false immediately
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return false;
    }

    // Check actual internet connectivity
    return await _connectionChecker.hasConnection;
  }

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _checkActualInternet(results);
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
    _internetSubscription?.cancel();
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
    if (contains(ConnectivityResult.none)) return ConnectionType.none;
    return ConnectionType.unknown;
  }
}
