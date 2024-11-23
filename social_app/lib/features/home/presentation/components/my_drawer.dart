import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/home/presentation/components/my_drawer_tile.dart';
import 'package:social_app/features/profle/presentation/pages/profile_page.dart';
import 'package:social_app/features/search/presentation/pages/search_page.dart';
import 'package:social_app/features/settings/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Icon(
                  Icons.person,
                  size: 80,
                ),
                MyDrawerTile(
                  title: 'H O M E ',
                  icon: Icons.home,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                MyDrawerTile(
                  title: 'P R O F I L E ',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context);
                    final user = context.read<AuthCubit>().currentUser;
                    String? uid = user!.uid;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: uid),
                        ));
                  },
                ),
                MyDrawerTile(
                  title: 'S E A R C H ',
                  icon: Icons.search,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                        ));
                  },
                ),
                MyDrawerTile(
                  title: 'S E T T I N G S',
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ));
                  },
                ),
                const Spacer(),
                MyDrawerTile(
                  title: 'L O G O U T ',
                  icon: Icons.logout,
                  onTap: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
