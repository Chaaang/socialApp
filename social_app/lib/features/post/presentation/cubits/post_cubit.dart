import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/post/domain/repos/post_repo.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_app/features/storage/domain/storage_repo.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';

class PostCubit extends Cubit<PostStates> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.postRepo, required this.storageRepo})
      : super(PostsInitial());

  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    try {
      emit(PostUploading());
      String? imageUrl;

      if (imagePath != null) {
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }

      if (imageBytes != null) {
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);

      postRepo.createPost(newPost);

      fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to create Posts: $e'));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostUploading());

      final posts = await postRepo.fetchAllPosts();

      if (posts.isNotEmpty) {
        emit(PostsLoaded(posts));
      } else {
        emit(PostsError('No post available'));
      }
    } catch (e) {
      emit(PostsError('Failed to fetch All posts $e'));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);

      //fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to delete post $e'));
    }
  }

  Future<void> fetchPostByUserId(String userId) async {
    try {
      emit(PostUploading());
      final posts = await postRepo.fetchPostByUserId(userId);
      if (posts.isNotEmpty) {
        emit(PostsLoaded(posts));
      } else {
        emit(PostsError('No posts available...'));
      }
    } catch (e) {
      emit(PostsError('Failed to fetch post $e'));
    }
  }

  Future<void> togglePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsError('Failed to toggle like: $e'));
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);

      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to add comment: $e'));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);

      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Error delete comment: $e'));
    }
  }
}
