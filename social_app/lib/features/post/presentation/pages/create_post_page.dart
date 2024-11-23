import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/components/my_text_field.dart';
import '../../domain/entities/post.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final postTextController = TextEditingController();
  final ValueNotifier<PlatformFile?> imageFileNotifier =
      ValueNotifier<PlatformFile?>(null);

  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    postTextController.addListener(() {
      setState(() {});
    });
    imageFileNotifier.addListener(() {
      setState(() {});
    });
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  void uploadPost() {
    if (postTextController.text.isNotEmpty || imagePickedFile != null) {
      final postsCubit = context.read<PostCubit>();
      final post = Post(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: currentUser!.uid,
          userName: currentUser!.name,
          text: postTextController.text,
          imageUrl: '',
          timeStamp: DateTime.now(),
          likes: [],
          comments: [],
          heart: []);

      if (kIsWeb) {
        postsCubit.createPost(post, imageBytes: imagePickedFile?.bytes);
      } else {
        postsCubit.createPost(post, imagePath: imagePickedFile?.path);
      }
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: kIsWeb);

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        imageFileNotifier.value = imagePickedFile;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
          imageFileNotifier.value = imagePickedFile;
        }
      });
    }
  }

  @override
  void dispose() {
    postTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostStates>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Post'),
            actions: [
              GestureDetector(
                  onTap: () => uploadPost(),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: postTextController.text.isNotEmpty ||
                                imagePickedFile != null
                            ? Colors.blue
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(5)),
                    child: const Center(child: Text('POST')),
                  ))
            ],
          ),
          body: Column(
            children: [
              if (kIsWeb && webImage != null) Image.memory(webImage!),
              if (!kIsWeb && imagePickedFile != null)
                Image.file(File(imagePickedFile!.path!)),
              MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: const Text('Select Photo'),
              ),
              MyTextField(
                  controller: postTextController,
                  obscureText: false,
                  hintText: 'What\'s on your mind?'),
            ],
          ),
        );
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }
}
