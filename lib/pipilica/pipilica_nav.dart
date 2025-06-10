import 'package:bazar_new_web/pipilica/pipilick_home.dart';
import 'package:flutter/material.dart';

class PipilickNav extends StatefulWidget {
  final Map<String, dynamic> userData;
  const PipilickNav({super.key, required this.userData});

  @override
  State<PipilickNav> createState() => _PipilickNavState();
}

class _PipilickNavState extends State<PipilickNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      PipilickHome(userData: widget.userData),
      ShoppingPage(),
      SearchPage(),
      SchemesPage(),
      MyCartPage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Shopping",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: "Schemes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "MyCart",
          ),
        ],
      ),
    );
  }
}

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Shopping Page"));
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Search Page"));
  }
}

class SchemesPage extends StatelessWidget {
  const SchemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Schemes Page"));
  }
}

class MyCartPage extends StatelessWidget {
  const MyCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("My Cart Page"));
  }
}
