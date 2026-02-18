import 'package:flutter/material.dart';
import 'package:my_app/modal/chat_list_modal.dart';
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
            children: Expanded(
              child: ListView.separated(
                itemCount: widget.data.length,
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemBuilder: (context, index) {
                  return ChatListItem(chat: widget.data[index], onTap: () {});
                },
                separatorBuilder: (_, __) => const SizedBox(height: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
