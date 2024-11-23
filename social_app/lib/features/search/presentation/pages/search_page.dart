import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profle/presentation/components/follower_tile.dart';
import 'package:social_app/features/search/presentation/cubits/search_cubit.dart';
import 'package:social_app/features/search/presentation/cubits/search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanged() {
    final query = searchController.text;

    searchCubit.searchUser(query);
  }

  @override
  void initState() {
    searchController.addListener(onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
              hintText: "Search users",
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, searchState) {
          //loaded
          if (searchState is SearchLoaded) {
            if (searchState.users.isEmpty) {
              return const Center(
                child: Text('No users found!'),
              );
            }

            return ListView.builder(
              itemCount: searchState.users.length,
              itemBuilder: (context, index) {
                final user = searchState.users[index];

                return UserTile(
                  user: user!,
                );
              },
            );
          }
          //loadeding
          else if (searchState is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          //error

          else if (searchState is SearchError) {
            return Center(
              child: Text(searchState.message),
            );
          }

          return const Center(
            child: Text('Start Searching'),
          );
        },
      ),
    );
  }
}
