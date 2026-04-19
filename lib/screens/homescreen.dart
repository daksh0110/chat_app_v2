import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/screens/home/chat_list_item.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key, required this.data});

  final List<ChatListModal> data;

  @override
  ConsumerState<Homescreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<Homescreen> {
  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListProvider);

    return chatsAsync.when(
      data: (chats) {
        return Column(
          children: [
            // StatusBar(),
            Expanded(
              child: PrimaryContainer(
                children: ListView.separated(
                  itemCount: chats.length,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemBuilder: (context, index) {
                    final chat = chats[index];

                    return ChatListItem(
                      chat: chat,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.message,
                          arguments: MessageScreenArguments(
                            id: chat.id,
                            name: chat.name,
                            profilePic: chat.profilePic,
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 1),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(e.toString()),
    );
  }
}
