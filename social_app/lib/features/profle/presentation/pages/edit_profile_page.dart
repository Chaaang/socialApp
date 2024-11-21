import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_app/features/profle/domain/entities/profile_user.dart';
import 'package:social_app/features/profle/presentation/cubits/profile_cubit.dart';
import 'package:social_app/features/profle/presentation/cubits/profile_states.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PlatformFile? imagePickedFile;

  Uint8List? webImage;

  final bioTextController = TextEditingController();

  Future<void> pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: kIsWeb);

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  Future<void> updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();

    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;

    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
          uid: uid,
          newBio: bioTextController.text,
          imageMobilePath: imageMobilePath,
          imageWebBytes: imageWebBytes);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    bioTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileStates>(
      builder: (context, profileStates) {
        if (profileStates is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('E D I T'),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () => updateProfile(),
                    icon: const Icon(Icons.check))
              ],
            ),
            body: Column(
              children: [
                Center(
                    child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle),
                      clipBehavior: Clip.hardEdge,
                      child: (!kIsWeb && imagePickedFile != null)
                          ? Image.file(
                              File(imagePickedFile!.path!),
                              fit: BoxFit.cover,
                            )
                          : (kIsWeb && webImage != null)
                              ? Image.memory(webImage!)
                              : CachedNetworkImage(
                                  imageUrl: widget.user.profileImageUrl,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    size: 72,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                )),
                const Text('Bio'),
                MyTextField(
                  controller: bioTextController,
                  obscureText: false,
                  hintText: widget.user.bio.isNotEmpty
                      ? widget.user.bio
                      : 'Update Bio...',
                ),
              ],
            ),
          );
        }
      },
      listener: (context, profileStates) {
        if (profileStates is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }
}
