import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../models/transaction_model.dart';
import '../../models/goal_model.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ApiService apiService;
  final DatabaseService databaseService;

  SyncBloc({required this.apiService, required this.databaseService}) 
      : super(SyncInitial()) {
    on<SyncAllData>(_onSyncAllData);
  }

  void _onSyncAllData(SyncAllData event, Emitter<SyncState> emit) async {
    emit(SyncLoading());
    try {
      // Check if user is authenticated by getting token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('userId');

      if (token == null || userId == null) {
        emit(SyncError(message: 'User not authenticated. Please login again.'));
        return;
      }

      print('Starting sync for user: $userId');
      
      // Set current user in database service
      await databaseService.setCurrentUser(userId);

      // Clear existing data for current user only
      await databaseService.clearAllTransactions();
      await databaseService.clearAllGoals();

      int transactionCount = 0;
      int goalCount = 0;

      // Sync transactions
      print('Fetching transactions from server...');
      final transactionsResponse = await apiService.getTransactions();
      print('Transactions response success: ${transactionsResponse.success}');
      
      if (transactionsResponse.success && transactionsResponse.data != null) {
        print('Found ${transactionsResponse.data!.length} transactions from API');
        for (var transaction in transactionsResponse.data!) {
          try {
            await databaseService.insertTransaction(transaction);
            transactionCount++;
          } catch (e) {
            print('Error inserting transaction: $e');
          }
        }
      } else {
        print('Transactions API error: ${transactionsResponse.message}');
      }

      // Sync goals
      print('Fetching goals from server...');
      final goalsResponse = await apiService.getGoals();
      print('Goals response success: ${goalsResponse.success}');
      
      if (goalsResponse.success && goalsResponse.data != null) {
        print('Found ${goalsResponse.data!.length} goals from API');
        for (var goal in goalsResponse.data!) {
          try {
            await databaseService.insertGoal(goal);
            goalCount++;
          } catch (e) {
            print('Error inserting goal: $e');
          }
        }
      } else {
        print('Goals API error: ${goalsResponse.message}');
      }

      emit(SyncSuccess(
        transactionCount: transactionCount,
        goalCount: goalCount,
      ));

      print('Sync completed: $transactionCount transactions, $goalCount goals');

    } catch (e) {
      print('Sync error: $e');
      emit(SyncError(message: 'Sync failed: $e'));
    }
  }
}