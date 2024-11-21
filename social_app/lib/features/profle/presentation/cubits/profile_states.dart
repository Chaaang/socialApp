import 'package:social_app/features/profle/domain/entities/profile_user.dart';

abstract class ProfileStates {}

class ProfileInitial extends ProfileStates {}

class ProfileLoaded extends ProfileStates {
  final ProfileUser profileUser;

  ProfileLoaded(this.profileUser);
}

class ProfileLoading extends ProfileStates {}

class ProfileError extends ProfileStates {
  final String message;

  ProfileError(this.message);
}
