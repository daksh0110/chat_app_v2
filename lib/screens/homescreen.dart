import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/util/route_observer.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/home/chat_list_item.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key, required this.data});

  final List<ChatListModal> data;

  @override
  ConsumerState<Homescreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<Homescreen> with RouteAware {
  late final SelectedChatListNotifier selectedChatListNotifier;

  @override
  void initState() {
    super.initState();

    selectedChatListNotifier = ref.read(selectedChatListProvider.notifier);
  }

  @override
  void dispose() {
    Future(() => selectedChatListNotifier.clearList());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPop() {
    selectedChatListNotifier.clearList();
  }

  @override
  void didPushNext() {
    selectedChatListNotifier.clearList();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListProvider);
    final selectedListNotifier = ref.watch(selectedChatListProvider.notifier);
    final selectedList = ref.watch(selectedChatListProvider);
    return chatsAsync.when(
      data: (chats) {
        return Column(
          children: [
            // StatusBar(),
            Expanded(
              child: PrimaryContainer(
                children: chats.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: DefaultColorSheet.green500,
                            ),
                            SizedBox(height: 16),
                            PrimaryText(
                              'No chats yet',

                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 8),
                            PrimaryText(
                              'Start a conversation to see your chats here.',
                              textAlign: TextAlign.center,
                              color: DefaultColorSheet.green500,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: chats.length,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        itemBuilder: (context, index) {
                          final chat = chats[index];

                          return ChatListItem(
                            chat: chat,
                            onTap: () {
                              if (selectedList.isEmpty) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.message,
                                  arguments: MessageScreenArguments(
                                    chatId: chat.chatId,
                                    name: chat.name ?? "",
                                    profilePicUrl: chat.profilePicUrl,
                                    isGroupChat: chat.type,
                                  ),
                                );
                                return;
                              } else {
                                selectedListNotifier.modifyList(chat.chatId);
                              }
                            },
                            onHold: () =>
                                selectedListNotifier.modifyList(chat.chatId),
                            isSelected: selectedList.contains(chat.chatId),
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
