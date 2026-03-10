import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/data/dummy_status_bar.dart';
import 'package:my_app/modal/status_bar_modal.dart';
import 'package:my_app/widgets/screens/home/status_bar_item.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StatusBarModal> data = dummyStatusBarModal;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 90,
        child: Row(
          children: [
            StatusBarItem(
              item: StatusBarModal(
                id: "0",
                name: "",
                profileUrl: "assets/no-image-icon.jpg",
              ),
              isMe: true,
            ),

            const SizedBox(width: 12),

            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Container(
                width: 1,
                height: 48,
                color: DefaultColorSheet.grey300,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: StatusBarItem(item: data[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
