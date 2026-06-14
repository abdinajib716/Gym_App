import 'package:equatable/equatable.dart';

/// Base State Status - Common for all BLoCs/Cubits
enum StateStatus {
  initial,
  loading,
  success,
  failure,
  loadingMore, // For pagination
  refreshing, // For pull-to-refresh
}

/// BaseState - Foundation for all BLoC/Cubit states
/// Extend this for consistent state handling
abstract class BaseState extends Equatable {
  final StateStatus status;
  final String? errorMessage;
  final bool isOffline;

  const BaseState({
    this.status = StateStatus.initial,
    this.errorMessage,
    this.isOffline = false,
  });

  /// Helper getters for common checks
  bool get isInitial => status == StateStatus.initial;
  bool get isLoading => status == StateStatus.loading;
  bool get isSuccess => status == StateStatus.success;
  bool get isFailure => status == StateStatus.failure;
  bool get isLoadingMore => status == StateStatus.loadingMore;
  bool get isRefreshing => status == StateStatus.refreshing;
  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props => [status, errorMessage, isOffline];
}

/// GenericState - Ready-to-use generic state with data
class GenericState<T> extends BaseState {
  final T? data;

  const GenericState({
    super.status,
    super.errorMessage,
    super.isOffline,
    this.data,
  });

  GenericState<T> copyWith({
    StateStatus? status,
    String? errorMessage,
    bool? isOffline,
    T? data,
  }) {
    return GenericState<T>(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [...super.props, data];
}

/// PaginatedState - For lists with pagination
class PaginatedState<T> extends BaseState {
  final List<T> items;
  final int currentPage;
  final bool hasReachedMax;
  final int? totalItems;

  const PaginatedState({
    super.status,
    super.errorMessage,
    super.isOffline,
    this.items = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.totalItems,
  });

  PaginatedState<T> copyWith({
    StateStatus? status,
    String? errorMessage,
    bool? isOffline,
    List<T>? items,
    int? currentPage,
    bool? hasReachedMax,
    int? totalItems,
  }) {
    return PaginatedState<T>(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.length;

  @override
  List<Object?> get props => [
    ...super.props,
    items,
    currentPage,
    hasReachedMax,
    totalItems,
  ];
}
