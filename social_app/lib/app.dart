import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/data/firebase_auth_repo.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_state.dart';
import 'package:social_app/features/auth/presentation/pages/auth.dart';
import 'package:social_app/features/themes/light_mode.dart';

import 'features/home/presentation/pages/home.dart';

//root level

class MyApp extends StatelessWidget {
  //Authentication cubit
  final authRepo = FirebaseAuthRepo();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
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
