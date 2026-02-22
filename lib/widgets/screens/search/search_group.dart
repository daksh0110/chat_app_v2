import 'package:flutter/material.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/modal/screens/search/search_item_group.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/search/search_group_item.dart';

class SearchGroup extends StatelessWidget {
  const SearchGroup({super.key, required this.list});
  final SearchItemGroup list;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        PrimaryText(list.name, fontSize: 16, fontWeight: FontWeight.w500),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return SearchGroupItem(
              item: list.items[index],
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/message",
                  arguments: MessageScreenArguments(id: list.items[index].id),
                );
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 30),
          itemCount: list.items.length,
        ),
      ],
    );
  }
}
