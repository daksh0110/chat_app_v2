import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/secure_storage_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/user_bubble.dart';

class SelectMembersScreen extends ConsumerStatefulWidget {
  final List<UserModel> initialSelected;

  const SelectMembersScreen({super.key, required this.initialSelected});

  @override
  ConsumerState<SelectMembersScreen> createState() =>
      _SelectMembersScreenState();
}

class _SelectMembersScreenState extends ConsumerState<SelectMembersScreen> {
  final List<UserModel> _selectedUsers = [];
  final List<UserModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingResults = false;
  final ApiClient _apiClient = ApiClient();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedUsers.addAll(widget.initialSelected);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchResults.clear();
        });
      } else {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _isLoadingResults = true;
    });

    try {
      final token = ref.read(secureStorageProvider).value;
      final result = await UserApiService(
        _apiClient,
      ).getUsers(page: 1, search: query, token: token ?? "");

      if (result.data != null) {
        setState(() {
          _searchResults.clear();
          _searchResults.addAll(
            result.data!.map(
              (item) => UserModel(
                id: item.id,
                name: item.name,
                email: item.email,
                profilePic: item.profilePic,
                bio: item.bio,
              ),
            ),
          );
        });
      }
    } catch (e) {
    } finally {
      setState(() {
        _isLoadingResults = false;
      });
    }
  }

  void _toggleUser(UserModel user) {
    setState(() {
      final index = _selectedUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _selectedUsers.removeAt(index);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: DefaultColorSheet.lightBlack,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Column(
                  children: [
                    const PrimaryText(
                      "Select Members",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    PrimaryText(
                      "${_selectedUsers.length} selected",
                      fontSize: 12,
                      color: DefaultColorSheet.grey500,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _selectedUsers),
                  child: const PrimaryText(
                    "Done",
                    color: DefaultColorSheet.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: DefaultColorSheet.disbaledButton,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.search,
                    size: 20,
                    color: DefaultColorSheet.grey500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: "Search users...",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: _isSearching ? _buildSearchResults() : _buildContactsList(),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoadingResults) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(child: PrimaryText("No users found"));
    }

    return _buildList(_searchResults);
  }

  Widget _buildContactsList() {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(err.toString())),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: PrimaryText("No contacts found"));
        }

        return _buildList(users);
      },
    );
  }

  Widget _buildList(List<UserModel> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelected = _selectedUsers.any((u) => u.id == user.id);

        return ListTile(
          onTap: () => _toggleUser(user),
          leading: UserBubble(
            profilePicUrl: user.profilePic,
            name: user.name,
            size: 44,
          ),
          title: PrimaryText(
            user.name,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          subtitle: PrimaryText(
            user.email,
            fontSize: 12,
            color: DefaultColorSheet.grey500,
          ),
          trailing: Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected
                ? DefaultColorSheet.primary
                : DefaultColorSheet.grey300,
            size: 24,
          ),
        );
      },
    );
  }
}
