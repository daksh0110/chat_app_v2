import 'package:flutter/material.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/widgets/comman/primary_container.dart';
import 'package:my_app/widgets/screens/home/chat_list_item.dart';
import 'package:my_app/widgets/screens/home/status_bar.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key, required this.data});

  final List<ChatListModal> data;

  @override
  State<Homescreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatusBar(),
        Expanded(
          child: PrimaryContainer(
            children: ListView.separated(
              itemCount: widget.data.length,
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemBuilder: (context, index) {
                return ChatListItem(
                  chat: widget.data[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.message,
                      arguments: MessageScreenArguments(
                        id: widget.data[index].id,
                        name: widget.data[index].name,
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
  }
}
