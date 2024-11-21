import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profle/domain/entities/profile_user.dart';
import 'package:social_app/features/profle/domain/repos/profile_repo.dart';
import 'package:social_app/features/profle/presentation/cubits/profile_states.dart';
import 'package:social_app/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({
    required this.profileRepo,
    required this.storageRepo,
  }) : super(ProfileInitial());

  //Fetch user profile using repo

  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());

      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('User not Found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  Future<void> updateProfile(
      {required String uid,
      String? newBio,
      Uint8List? imageWebBytes,
      String? imageMobilePath}) async {
    emit(ProfileLoading());

    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError('Failed to fetch user profile update'));
        return;
      }

      //profile picture update

      String? imageDownloadUrl;

      if (imageWebBytes != null || imageMobilePath != null) {
        //mobile
        if (imageMobilePath != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        }
        //web
        else {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes!, uid);
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError('Failed to Upload image'));
          return;
        }
      }

      //update new profile
      final updateProfile = currentUser.copyWith(
          newBio: newBio ?? currentUser.bio,
          newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl);

      //update in repo
      await profileRepo.updateProfile(updateProfile);

      //refetch update profile

      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError('Error updateing profile: $e'));
    }
  }

  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      await profileRepo.toggleFollow(currentUid, targetUid);
    } catch (e) {
      emit(ProfileError('Error toggling follow $e'));
    }
  }
}
