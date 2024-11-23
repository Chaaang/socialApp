import 'package:flutter/material.dart';
import 'package:social_app/features/profle/domain/entities/profile_user.dart';

import '../pages/profile_page.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;
  const UserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            NetworkImage(user.profileImageUrl), // Load image from URL
        backgroundColor: Colors.grey, // Optional: Fallback color
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      subtitleTextStyle:
          TextStyle(color: Theme.of(context).colorScheme.primary),
      trailing: GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(uid: user.uid))),
          child: const Icon(Icons.navigate_next)),
    );
  }
}
