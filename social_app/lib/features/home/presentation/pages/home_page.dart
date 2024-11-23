import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/post/presentation/components/post_tile.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_app/features/post/presentation/pages/create_post_page.dart';
import '../components/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Newsfeed'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostPage(),
                    ));
              },
              icon: const Icon(Icons.create))
        ],
      ),
      drawer: const MyDrawer(),
      body: BlocBuilder<PostCubit, PostStates>(
        builder: (context, postState) {
          if (postState is PostsLoading || postState is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          }
          //loaded
          else if (postState is PostsLoaded) {
            var allPosts = postState.posts;

            return ListView(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allPosts.length,
                  itemBuilder: (context, index) {
                    final post = allPosts[index];
                    return PostTile(
                      post: post,
                      onTap: () => deletePost(post.id),
                    );
                  },
                ),
              ],
            );
          }
          //error
          else if (postState is PostsError) {
            var err = postState.message;
            return Center(
              child: Text(err),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
