import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../models/transaction_model.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final ApiService apiService;
  final DatabaseService databaseService;

  TransactionBloc({required this.apiService, required this.databaseService}) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<SyncTransactions>(_onSyncTransactions);
  }

  void _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final localTransactions = await databaseService.getTransactions();
      emit(TransactionLoaded(transactions: localTransactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      // First save locally
      final localId = await databaseService.insertTransaction(event.transaction);
      var newTransaction = event.transaction.copyWith(id: localId);

      // Try to sync with server
      final response = await apiService.createTransaction(newTransaction);
      if (response.success) {
        final serverId = response.data['id'];
        await databaseService.markTransactionAsSynced(localId, serverId);
        newTransaction = newTransaction.copyWith(serverId: serverId, isSynced: true);
      }

      // Reload transactions
      final transactions = await databaseService.getTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onUpdateTransaction(UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await databaseService.updateTransaction(event.transaction);
      
      // Sync with server if it has serverId
      if (event.transaction.serverId != null) {
        await apiService.updateTransaction(event.transaction);
      }

      final transactions = await databaseService.getTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await databaseService.deleteTransaction(event.transactionId);
      
      // Delete from server if it has serverId
      if (event.serverId != null) {
        await apiService.deleteTransaction(event.serverId!);
      }

      final transactions = await databaseService.getTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onSyncTransactions(SyncTransactions event, Emitter<TransactionState> emit) async {
    try {
      // Get unsynced transactions
      final unsyncedTransactions = await databaseService.getUnsyncedTransactions();
      
      for (var transaction in unsyncedTransactions) {
        final response = await apiService.createTransaction(transaction);
        if (response.success) {
          final serverId = response.data['id'];
          await databaseService.markTransactionAsSynced(transaction.id!, serverId);
        }
      }

      // Get server transactions and check for missing ones
      final serverResponse = await apiService.getTransactions();
      if (serverResponse.success) {
        final serverTransactions = serverResponse.data!;
        final localTransactions = await databaseService.getTransactions();
        
        for (var serverTransaction in serverTransactions) {
          final exists = localTransactions.any((local) => local.serverId == serverTransaction.serverId);
          if (!exists) {
            await databaseService.insertTransaction(serverTransaction);
          }
        }
      }

      final transactions = await databaseService.getTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }
}