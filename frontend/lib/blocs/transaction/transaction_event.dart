part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const AddTransaction({required this.transaction});

  @override
  List<Object> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const UpdateTransaction({required this.transaction});

  @override
  List<Object> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final int transactionId;
  final int? serverId;

  const DeleteTransaction({required this.transactionId, this.serverId});

  @override
  List<Object> get props => [transactionId];
}

class SyncTransactions extends TransactionEvent {}

class ClearTransactions extends TransactionEvent {}