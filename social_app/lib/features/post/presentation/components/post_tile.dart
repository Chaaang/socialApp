import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/domain/entities/comment.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/presentation/components/comment_tile.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_app/features/post/presentation/pages/view_full_post_page.dart';
import 'package:social_app/features/profle/domain/entities/profile_user.dart';
import 'package:social_app/features/profle/presentation/cubits/profile_cubit.dart';
import 'package:social_app/features/profle/presentation/pages/profile_page.dart';

import '../../../auth/domain/entities/app_user.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onTap;
  const PostTile({super.key, required this.post, required this.onTap});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  final commentTextController = TextEditingController();

  bool isOwnPost = false;

  //current user
  AppUser? currentUser;

  //post user
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
    commentTextController.addListener(
      () {
        setState(() {});
      },
    );
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();

    currentUser = authCubit.currentUser;

    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);

    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Are you sure you want to delete your post?'),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      widget.onTap!();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    //update like

    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  void toggleHeartPost() {
    final isLiked = widget.post.heart.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.heart.remove(currentUser!.uid);
      } else {
        widget.post.heart.add(currentUser!.uid);
      }
    });

    //update like

    postCubit
        .toggleHeartPost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.heart.add(currentUser!.uid);
        } else {
          widget.post.heart.remove(currentUser!.uid);
        }
      });
    });
  }

  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: MyTextField(
                  controller: commentTextController,
                  obscureText: false,
                  hintText: 'Type a comment'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      addComment();
                      Navigator.pop(context);
                    },
                    child: const Text('Save')),
              ],
            ));
  }

  void addComment() {
    //create a comment

    final newComment = Comment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    //add a comment using cubit

    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    postUser?.profileImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: postUser!.profileImageUrl,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child:
                                        FittedBox(child: Icon(Icons.person))),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover)),
                            ),
                          )
                        : const SizedBox(
                            width: 40,
                            height: 40,
                            child: FittedBox(
                              child: Icon(
                                Icons.person,
                              ),
                            ),
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(
                              uid: widget.post.userId,
                            ),
                          )),
                      child: Text(
                        widget.post.userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ),
                    const Spacer(),
                    if (isOwnPost)
                      GestureDetector(
                          onTap: showOptions, child: const Icon(Icons.delete))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.post.text.isNotEmpty
                    ? Text(widget.post.text)
                    : const SizedBox(),
              ),
              widget.post.imageUrl.isEmpty
                  ? Container()
                  : CachedNetworkImage(
                      imageUrl: widget.post.imageUrl,
                      height: 430,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const SizedBox(height: 430),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
              // Hero(
              //     tag: 'tag-1',
              //     child: GestureDetector(
              //       onTap: () => Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => ViewFullPostPage(
              //               post: widget.post,
              //               profilePicture: postUser?.profileImageUrl,
              //               isOwnPost: isOwnPost,
              //               onTap: widget.onTap,
              //               currentUser: currentUser,
              //             ),
              //           )),
              //       child: CachedNetworkImage(
              //         imageUrl: widget.post.imageUrl,
              //         height: 430,
              //         width: double.infinity,
              //         fit: BoxFit.cover,
              //         placeholder: (context, url) =>
              //             const SizedBox(height: 430),
              //         errorWidget: (context, url, error) =>
              //             const Icon(Icons.error),
              //       ),
              //     ),
              //   ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    //like
                    SizedBox(
                      width: 40,
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: toggleLikePost,
                              child: Icon(
                                  widget.post.likes.contains(currentUser!.uid)
                                      ? Icons.thumb_up_off_alt_rounded
                                      : Icons.thumb_up_off_alt_outlined,
                                  color: widget.post.likes
                                          .contains(currentUser!.uid)
                                      ? Colors.blue
                                      : Theme.of(context).colorScheme.primary)),
                          Text(widget.post.likes.length.toString()),
                        ],
                      ),
                    ),
                    //heart
                    SizedBox(
                      width: 40,
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: toggleHeartPost,
                              child: Icon(
                                  widget.post.heart.contains(currentUser!.uid)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: widget.post.heart
                                          .contains(currentUser!.uid)
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary)),
                          Text(widget.post.heart.length.toString()),
                        ],
                      ),
                    ),

                    //comment

                    SizedBox(
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: openNewCommentBox,
                              child: const Icon(Icons.comment)),
                          Text(widget.post.comments.length.toString()),
                        ],
                      ),
                    ),

                    //timestamp
                    const Spacer(),
                    Text(widget.post.timeStamp.toString())
                  ],
                ),
              ),
              BlocBuilder<PostCubit, PostStates>(
                builder: (context, postState) {
                  if (postState is PostsLoaded) {
                    final post = postState.posts
                        .firstWhere((post) => (post.id == widget.post.id));

                    if (post.comments.isNotEmpty) {
                      int showCommentCount = post.comments.length;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: showCommentCount,
                        itemBuilder: (context, index) {
                          final comment = post.comments[index];
                          return CommentTile(
                            comment: comment,
                            imageUrl: postUser?.profileImageUrl,
                          );
                        },
                      );
                    }
                  }
                  if (postState is PostsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (postState is PostsError) {
                    return Center(
                      child: Text(postState.message),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}
