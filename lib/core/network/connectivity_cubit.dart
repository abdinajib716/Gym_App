import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'network_info.dart';

/// ConnectivityState - Frontend State for UI
class ConnectivityState extends Equatable {
  final bool isConnected;
  final bool isInitialized;
  final ConnectionType connectionType;
  final DateTime? lastOnlineTime;
  final bool showOfflineBanner;

  const ConnectivityState({
    this.isConnected = true,
    this.isInitialized = false,
    this.connectionType = ConnectionType.unknown,
    this.lastOnlineTime,
    this.showOfflineBanner = false,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    bool? isInitialized,
    ConnectionType? connectionType,
    DateTime? lastOnlineTime,
    bool? showOfflineBanner,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isInitialized: isInitialized ?? this.isInitialized,
      connectionType: connectionType ?? this.connectionType,
      lastOnlineTime: lastOnlineTime ?? this.lastOnlineTime,
      showOfflineBanner: showOfflineBanner ?? this.showOfflineBanner,
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        isInitialized,
        connectionType,
        lastOnlineTime,
        showOfflineBanner,
      ];
}

/// ConnectivityCubit - Frontend Cubit for Connectivity UI
/// Use this for showing/hiding offline banners, disabling buttons, etc.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _bannerDismissTimer;

  ConnectivityCubit({required NetworkInfo networkInfo})
      : _networkInfo = networkInfo,
        super(const ConnectivityState()) {
    _init();
  }

  Future<void> _init() async {
    // Check initial connectivity
    final isConnected = await _networkInfo.isConnected;
    final results = await _networkInfo.connectivityResult;
    
    emit(state.copyWith(
      isConnected: isConnected,
      isInitialized: true,
      connectionType: results.connectionType,
      lastOnlineTime: isConnected ? DateTime.now() : null,
      showOfflineBanner: !isConnected,
    ));

    // Listen to connectivity changes
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(bool isConnected) async {
    final results = await _networkInfo.connectivityResult;
    
    if (isConnected && !state.isConnected) {
      // Coming back online
      emit(state.copyWith(
        isConnected: true,
        connectionType: results.connectionType,
        lastOnlineTime: DateTime.now(),
        showOfflineBanner: false,
      ));
      
      // Optionally show "Back online" message briefly
      _showTemporaryOnlineBanner();
      
    } else if (!isConnected && state.isConnected) {
      // Going offline
      emit(state.copyWith(
        isConnected: false,
        connectionType: ConnectionType.none,
        showOfflineBanner: true,
      ));
    }
  }

  void _showTemporaryOnlineBanner() {
    // Could emit a temporary "back online" state here if needed
    _bannerDismissTimer?.cancel();
    _bannerDismissTimer = Timer(const Duration(seconds: 3), () {
      // Banner auto-dismiss logic if needed
    });
  }

  /// Manually check connectivity
  Future<void> checkConnectivity() async {
    final isConnected = await _networkInfo.isConnected;
    final results = await _networkInfo.connectivityResult;
    
    emit(state.copyWith(
      isConnected: isConnected,
      connectionType: results.connectionType,
      showOfflineBanner: !isConnected,
    ));
  }

  /// Dismiss offline banner manually
  void dismissOfflineBanner() {
    emit(state.copyWith(showOfflineBanner: false));
  }

  /// Show offline banner
  void showOfflineBanner() {
    if (!state.isConnected) {
      emit(state.copyWith(showOfflineBanner: true));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _bannerDismissTimer?.cancel();
    _networkInfo.dispose();
    return super.close();
  }
}
