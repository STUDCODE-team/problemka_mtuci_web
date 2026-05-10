import 'package:auto_route/auto_route.dart';
import 'package:admin_panel/features/users/bloc/users_bloc.dart';
import 'package:admin_panel/features/users/models/user_info.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  static const _roles = ['user', 'manager', 'admin'];

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(LoadUsers());
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRolePicker(UserInfo user) {
    final strings = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<UsersBloc>(),
        child: AlertDialog(
          title: Text(strings.usersRoleFor(user.email)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _roles.map((role) {
              return ListTile(
                leading: Icon(
                  user.role == role
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: user.role == role ? Theme.of(ctx).colorScheme.primary : null,
                ),
                title: Text(role),
                onTap: () {
                  if (role != user.role) {
                    ctx.read<UsersBloc>().add(
                          SetUserRole(userId: user.id, role: role),
                        );
                  }
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(S.of(context).usersTitle)),
        body: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, state) {
            final strings = S.of(context);
            if (state is UsersLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UsersLoaded) {
              final filtered = _searchQuery.isEmpty
                  ? state.users
                  : state.users
                      .where((u) =>
                          u.email.toLowerCase().contains(_searchQuery))
                      .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: strings.usersSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(child: Text(strings.usersNotFound))
                        : RefreshIndicator(
                            onRefresh: () async =>
                                context.read<UsersBloc>().add(LoadUsers()),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final user = filtered[index];
                                return ListTile(
                                  title: Text(user.email),
                                  subtitle: Text(
                                    strings.usersRegistered(_fmt(user.createdAt)),
                                    style: context.texts.bodySmall,
                                  ),
                                  trailing: Chip(
                                    label: Text(user.role),
                                    backgroundColor: _roleColor(user.role),
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                  ),
                                  onTap: () => _showRolePicker(user),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }
            return Center(child: Text(strings.usersLoading));
          },
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

String _fmt(DateTime dt) {
  final d = dt.toLocal();
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(d.day)}.${p(d.month)}.${d.year}';
}
