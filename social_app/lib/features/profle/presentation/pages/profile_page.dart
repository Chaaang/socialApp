import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/post/presentation/components/post_tile.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_app/features/profle/presentation/components/bio_box.dart';
import 'package:social_app/features/profle/presentation/components/profile_stats.dart';
import 'package:social_app/features/profle/presentation/cubits/profile_cubit.dart';
import 'package:social_app/features/profle/presentation/cubits/profile_states.dart';
import 'package:social_app/features/profle/presentation/pages/edit_profile_page.dart';
import 'package:social_app/features/profle/presentation/pages/follower_page.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../components/follow_button.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //cubits

  late final profileCubit = context.read<ProfileCubit>();
  late final postCubit = context.read<PostCubit>();

  AppUser? currentUser;
  bool isOwnPost = false;
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
    getPostCount();
    getCurrentUser();
  }

  void getPostCount() {
    final postState = postCubit.state;

    if (postState is! PostsLoaded) {
      return;
    }

    final userPosts =
        postState.posts.where((post) => post.userId == widget.uid).toList();

    postCount = userPosts.length;
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.uid == currentUser!.uid);
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;

    if (profileState is! ProfileLoaded) {
      return;
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    //update ui
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    //update db
    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      //update ui
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, profileStates) {
        if (profileStates is ProfileError) {
          final err = profileStates.message;

          return Scaffold(
            body: Center(
              child: Text(err),
            ),
          );
        }
        if (profileStates is ProfileLoaded) {
          //get loaded user

          final user = profileStates.profileUser;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(user.name),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                if (isOwnPost)
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                user: user,
                              ),
                            ));
                      },
                      icon: const Icon(Icons.settings))
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: user.profileImageUrl,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    imageBuilder: (context, imageProvider) => Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ProfileStats(
                    postCount: postCount,
                    followerCount: user.followers.length,
                    followingCount: user.following.length,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FollowerPage(
                                  followers: user.followers,
                                  following: user.following,
                                ))),
                  ),
                  if (!isOwnPost)
                    SizedBox(
                      width: double.infinity,
                      child: FollowButton(
                        onPressed: followButtonPressed,
                        isFollowing: user.followers.contains(currentUser!.uid),
                      ),
                    ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(user.email),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        Text(
                          'Bio',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 21),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyBio(text: user.bio),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: [
                        Text(
                          'Posts',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 21),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  BlocBuilder<PostCubit, PostStates>(
                    builder: (context, postState) {
                      if (postState is PostsLoaded) {
                        final userPosts = postState.posts
                            .where((post) => post.userId == widget.uid)
                            .toList();

                        int posts = userPosts.length;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts,
                          itemBuilder: (context, index) {
                            final post = userPosts[index];

                            return PostTile(
                              post: post,
                              onTap: () => context
                                  .read<PostCubit>()
                                  .deletePost((post.id)),
                            );
                          },
                        );
                      } else if (postState is PostsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (postState is PostsError) {
                        return Center(
                          child: Text(postState.message),
                        );
                      } else {
                        return const Center(
                          child: Text('No available post...'),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
        if (profileStates is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('No profile found...'),
            ),
          );
        }
      },
    );
  }
}
