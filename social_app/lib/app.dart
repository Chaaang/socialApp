import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/data/firebase_auth_repo.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_state.dart';
import 'package:social_app/features/auth/presentation/pages/auth_page.dart';
import 'package:social_app/features/post/data/firebase_post_repo.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/profle/data/firebase_profile_repo.dart';
import 'package:social_app/features/profle/presentation/cubits/profile_cubit.dart';
import 'package:social_app/features/storage/data/firebase_storage_repo.dart';
import 'package:social_app/features/themes/light_mode.dart';

import 'features/home/presentation/pages/home_page.dart';

//root level

class MyApp extends StatelessWidget {
  //Authentication cubit
  final firebaseauthRepo = FirebaseAuthRepo();

  final firebaseprofileRepo = FirebaseProfileRepo();

  final firebasestorageRepo = FirebaseStorageRepo();

  final firebasePostRepo = FirebasePostRepo();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepo: firebaseauthRepo)..checkAuth()),
        BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
                  profileRepo: firebaseprofileRepo,
                  storageRepo: firebasestorageRepo,
                )),
        BlocProvider<PostCubit>(
            create: (context) => PostCubit(
                  postRepo: firebasePostRepo,
                  storageRepo: firebasestorageRepo,
                ))
      ],
      child: MaterialApp(
          theme: lightMode,
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              // ignore: avoid_print
              print(authState);

              if (authState is UnAuthenticated) {
                return const AuthPage();
              }
              if (authState is Authenticated) {
                return const HomePage();
              } else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
            listener: (context, authState) {
              if (authState is AuthError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(authState.message)));
              }
            },
          )),
    );
  }
}
