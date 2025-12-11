import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'base_state.dart';

/// BaseEvent - Foundation for all BLoC events
abstract class BaseEvent {
  const BaseEvent();
}

/// BaseBloc - Foundation for Business Logic BLoCs
/// Use this for complex business logic with events
abstract class BaseBloc<Event extends BaseEvent, State extends BaseState>
    extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// Execute an async operation with Either result
  Future<void> executeEither<T>({
    required Future<Either<String, T>> Function() operation,
    required Emitter<State> emit,
    required State Function() onLoading,
    required State Function(T data) onSuccess,
    required State Function(String error) onFailure,
  }) async {
    emit(onLoading());

    final result = await operation();

    result.fold(
      (failure) => emit(onFailure(failure)),
      (data) => emit(onSuccess(data)),
    );
  }

  /// Execute a simple async operation
  Future<void> executeAsync<T>({
    required Future<T> Function() operation,
    required Emitter<State> emit,
    required State Function() onLoading,
    required State Function(T data) onSuccess,
    required State Function(String error) onFailure,
  }) async {
    emit(onLoading());

    try {
      final data = await operation();
      emit(onSuccess(data));
    } catch (e) {
      emit(onFailure(e.toString()));
    }
  }
}

/// Example: How to create a BLoC for business logic
/// 
/// // Events
/// abstract class UserEvent extends BaseEvent {}
/// 
/// class LoadUser extends UserEvent {
///   final String userId;
///   LoadUser(this.userId);
/// }
/// 
/// class UpdateUser extends UserEvent {
///   final User user;
///   UpdateUser(this.user);
/// }
/// 
/// // State
/// class UserState extends BaseState {
///   final User? user;
///   
///   const UserState({
///     super.status,
///     super.errorMessage,
///     super.isOffline,
///     this.user,
///   });
///   
///   UserState copyWith({...}) => UserState(...);
/// }
/// 
/// // BLoC
/// class UserBloc extends BaseBloc<UserEvent, UserState> {
///   final UserRepository _repository;
///   
///   UserBloc(this._repository) : super(const UserState()) {
///     on<LoadUser>(_onLoadUser);
///     on<UpdateUser>(_onUpdateUser);
///   }
///   
///   Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
///     await executeEither(
///       operation: () => _repository.getUser(event.userId),
///       emit: emit,
///       onLoading: () => state.copyWith(status: StateStatus.loading),
///       onSuccess: (user) => state.copyWith(status: StateStatus.success, user: user),
///       onFailure: (error) => state.copyWith(status: StateStatus.failure, errorMessage: error),
///     );
///   }
/// }
