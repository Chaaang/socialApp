import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/domain/entities/app_user.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/domain/entities/comment.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';

class CommentTile extends StatefulWidget {
  final String? imageUrl;
  final Comment comment;
  const CommentTile({
    super.key,
    required this.comment,
    required this.imageUrl,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.comment.userId == currentUser!.uid);
  }

  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete comment?'),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      context.read<PostCubit>().deleteComment(
                          widget.comment.postId, widget.comment.id);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          widget.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: widget.imageUrl!,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const SizedBox(
                      width: 20,
                      height: 20,
                      child: FittedBox(child: Icon(Icons.person))),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)),
                  ),
                )
              : const SizedBox(
                  width: 20,
                  height: 20,
                  child: FittedBox(
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                ),
          const SizedBox(
            width: 5,
          ),
          Text(
            widget.comment.userName,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Text(widget.comment.text),
          const Spacer(),
          if (isOwnPost)
            GestureDetector(
              onTap: showOptions,
              child: const Icon(Icons.more_horiz),
            )
        ],
      ),
    );
  }
}
