import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'base_state.dart';

/// BaseCubit - Foundation for Frontend Cubits
/// Provides common functionality for UI state management
abstract class BaseCubit<State extends BaseState> extends Cubit<State> {
  BaseCubit(super.initialState);

  /// Execute an async operation with automatic state handling
  /// [operation] - The async function to execute
  /// [onSuccess] - Callback when operation succeeds
  /// [onFailure] - Callback when operation fails
  Future<void> execute<T>({
    required Future<Either<String, T>> Function() operation,
    required State Function(T data) onSuccess,
    required State Function(String error) onFailure,
    State Function()? onLoading,
  }) async {
    if (onLoading != null) {
      emit(onLoading());
    }

    final result = await operation();
    
    result.fold(
      (failure) => emit(onFailure(failure)),
      (data) => emit(onSuccess(data)),
    );
  }

  /// Execute a simple async operation
  Future<void> executeSimple<T>({
    required Future<T> Function() operation,
    required State Function(T data) onSuccess,
    required State Function(String error) onFailure,
    State Function()? onLoading,
  }) async {
    if (onLoading != null) {
      emit(onLoading());
    }

    try {
      final data = await operation();
      emit(onSuccess(data));
    } catch (e) {
      emit(onFailure(e.toString()));
    }
  }

  /// Handle offline state
  void setOffline(State offlineState) {
    emit(offlineState);
  }
}

/// GenericCubit - Ready-to-use cubit for simple data
class GenericCubit<T> extends BaseCubit<GenericState<T>> {
  GenericCubit() : super(const GenericState());

  void setLoading() {
    emit(state.copyWith(status: StateStatus.loading));
  }

  void setSuccess(T data) {
    emit(state.copyWith(
      status: StateStatus.success,
      data: data,
      errorMessage: null,
    ));
  }

  void setFailure(String error) {
    emit(state.copyWith(
      status: StateStatus.failure,
      errorMessage: error,
    ));
  }

  void setOfflineState() {
    emit(state.copyWith(
      isOffline: true,
      errorMessage: 'No internet connection',
    ));
  }

  void reset() {
    emit(const GenericState());
  }
}

/// PaginatedCubit - For lists with pagination
abstract class PaginatedCubit<T> extends BaseCubit<PaginatedState<T>> {
  PaginatedCubit() : super(const PaginatedState());

  /// Override to fetch data
  Future<Either<String, List<T>>> fetchData(int page);

  /// Load initial data
  Future<void> loadInitial() async {
    emit(state.copyWith(status: StateStatus.loading));

    final result = await fetchData(1);

    result.fold(
      (failure) => emit(state.copyWith(
        status: StateStatus.failure,
        errorMessage: failure,
      )),
      (items) => emit(state.copyWith(
        status: StateStatus.success,
        items: items,
        currentPage: 1,
        hasReachedMax: items.isEmpty,
      )),
    );
  }

  /// Load more data (pagination)
  Future<void> loadMore() async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(status: StateStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await fetchData(nextPage);

    result.fold(
      (failure) => emit(state.copyWith(
        status: StateStatus.success, // Keep showing existing data
        errorMessage: failure,
      )),
      (items) => emit(state.copyWith(
        status: StateStatus.success,
        items: [...state.items, ...items],
        currentPage: nextPage,
        hasReachedMax: items.isEmpty,
      )),
    );
  }

  /// Refresh data (pull-to-refresh)
  Future<void> refresh() async {
    emit(state.copyWith(status: StateStatus.refreshing));

    final result = await fetchData(1);

    result.fold(
      (failure) => emit(state.copyWith(
        status: StateStatus.failure,
        errorMessage: failure,
      )),
      (items) => emit(state.copyWith(
        status: StateStatus.success,
        items: items,
        currentPage: 1,
        hasReachedMax: items.isEmpty,
      )),
    );
  }
}
