import 'package:flutter/material.dart';
import 'package:my_app/data/navigation_menu.dart';
import 'package:my_app/widgets/screens/home/bottom_nav_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentActive = 0;

  @override
  Widget build(BuildContext context) {
    final currentItem = menu[currentActive];

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: currentItem.appBar(context),

      body: currentItem.screen(),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(
              menu.length,
              (index) => Expanded(
                child: BottomNavItem(
                  icon: menu[index].icon,
                  label: menu[index].label,
                  isActive: currentActive == index,
                  onTap: () {
                    setState(() {
                      currentActive = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
