part of 'goal_bloc.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object> get props => [];
}

class LoadGoals extends GoalEvent {}

class AddGoal extends GoalEvent {
  final GoalModel goal;

  const AddGoal({required this.goal});

  @override
  List<Object> get props => [goal];
}

class UpdateGoal extends GoalEvent {
  final GoalModel goal;

  const UpdateGoal({required this.goal});

  @override
  List<Object> get props => [goal];
}

class DeleteGoal extends GoalEvent {
  final int goalId;
  final int? serverId;

  const DeleteGoal({required this.goalId, this.serverId});

  @override
  List<Object> get props => [goalId];
}

class SyncGoals extends GoalEvent {}