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
import 'package:social_app/features/search/data/firebase_search_repo.dart';
import 'package:social_app/features/search/presentation/cubits/search_cubit.dart';
import 'package:social_app/features/storage/data/firebase_storage_repo.dart';
import 'package:social_app/features/themes/cubit/theme_cubit.dart';

import 'features/home/presentation/pages/home_page.dart';

//root level

class MyApp extends StatelessWidget {
  //Authentication cubit
  final firebaseauthRepo = FirebaseAuthRepo();

  final firebaseprofileRepo = FirebaseProfileRepo();

  final firebasestorageRepo = FirebaseStorageRepo();

  final firebasePostRepo = FirebasePostRepo();

  final firebaseSearchRepo = FirebaseSearchRepo();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          //Auth cubit
          BlocProvider<AuthCubit>(
              create: (context) =>
                  AuthCubit(authRepo: firebaseauthRepo)..checkAuth()),

          //Profile Cubit
          BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                    profileRepo: firebaseprofileRepo,
                    storageRepo: firebasestorageRepo,
                  )),

          //Post Cubit
          BlocProvider<PostCubit>(
              create: (context) => PostCubit(
                    postRepo: firebasePostRepo,
                    storageRepo: firebasestorageRepo,
                  )),

          //Search Cubit
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(
              searchRepo: firebaseSearchRepo,
            ),
          ),

          // Dark/light Mode cubit
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
          )
        ],
        child: BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, currentTheme) => MaterialApp(
              theme: currentTheme,
              debugShowCheckedModeBanner: false,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(authState.message)));
                  }
                },
              )),
        ));
  }
}
