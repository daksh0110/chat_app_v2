import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/data/search_list.dart';
import 'package:my_app/modal/screens/search/search_item_group.dart';
import 'package:my_app/widgets/screens/search/search_group.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() {
    return _SearchState();
  }
}

class _SearchState extends State<Search> {
  final List<SearchItemGroup> data = searchList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        title: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DefaultColorSheet.disbaledButton,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.search, size: 20),

              const SizedBox(width: 8),

              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Icon(LucideIcons.x, size: 20),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsetsGeometry.directional(top: 20),
        padding: EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return SearchGroup(list: searchList[index]);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemCount: searchList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
