part of 'sync_bloc.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object> get props => [];
}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {
  final int transactionCount;
  final int goalCount;

  const SyncSuccess({
    required this.transactionCount,
    required this.goalCount,
  });

  @override
  List<Object> get props => [transactionCount, goalCount];
}

class SyncError extends SyncState {
  final String message;

  const SyncError({required this.message});

  @override
  List<Object> get props => [message];
}