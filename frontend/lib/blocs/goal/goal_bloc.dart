import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../models/goal_model.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final ApiService apiService;
  final DatabaseService databaseService;

  GoalBloc({required this.apiService, required this.databaseService}) : super(GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<SyncGoals>(_onSyncGoals);
    on<ClearGoals>(_onClearGoals);
  }

  void _onLoadGoals(LoadGoals event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final localGoals = await databaseService.getGoals();
      emit(GoalLoaded(goals: localGoals));
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }

  void _onAddGoal(AddGoal event, Emitter<GoalState> emit) async {
    try {
      // First save locally
      final localId = await databaseService.insertGoal(event.goal);
      var newGoal = event.goal.copyWith(id: localId);

      // Try to sync with server
      final response = await apiService.createGoal(newGoal);
      if (response.success) {
        final serverId = response.data['id'];
        await databaseService.markGoalAsSynced(localId, serverId);
        newGoal = newGoal.copyWith(serverId: serverId, isSynced: true);
      }

      // Reload goals
      final goals = await databaseService.getGoals();
      emit(GoalLoaded(goals: goals));
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }

  void _onUpdateGoal(UpdateGoal event, Emitter<GoalState> emit) async {
    try {
      await databaseService.updateGoal(event.goal);
      
      // Sync with server if it has serverId
      if (event.goal.serverId != null) {
        await apiService.updateGoal(event.goal);
      }

      final goals = await databaseService.getGoals();
      emit(GoalLoaded(goals: goals));
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }

  void _onDeleteGoal(DeleteGoal event, Emitter<GoalState> emit) async {
    try {
      await databaseService.deleteGoal(event.goalId);
      
      // Delete from server if it has serverId
      if (event.serverId != null) {
        await apiService.deleteGoal(event.serverId!);
      }

      final goals = await databaseService.getGoals();
      emit(GoalLoaded(goals: goals));
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }

  void _onSyncGoals(SyncGoals event, Emitter<GoalState> emit) async {
    try {
      // Get unsynced goals
      final unsyncedGoals = await databaseService.getUnsyncedGoals();
      
      for (var goal in unsyncedGoals) {
        final response = await apiService.createGoal(goal);
        if (response.success) {
          final serverId = response.data['id'];
          await databaseService.markGoalAsSynced(goal.id!, serverId);
        }
      }

      // Get server goals and check for missing ones
      final serverResponse = await apiService.getGoals();
      if (serverResponse.success) {
        final serverGoals = serverResponse.data!;
        final localGoals = await databaseService.getGoals();
        
        for (var serverGoal in serverGoals) {
          final exists = localGoals.any((local) => local.serverId == serverGoal.serverId);
          if (!exists) {
            await databaseService.insertGoal(serverGoal);
          }
        }
      }

      final goals = await databaseService.getGoals();
      emit(GoalLoaded(goals: goals));
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }

  void _onClearGoals(ClearGoals event, Emitter<GoalState> emit) async {
    try {
      await databaseService.clearAllGoals();
      emit(GoalLoaded(goals: []));
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }
}