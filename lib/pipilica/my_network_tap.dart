import 'package:bazar_new_web/pipilica/my_network.dart';
import 'package:bazar_new_web/pipilica/starred_page.dart';
import 'package:flutter/material.dart';

class MyNetworkTap extends StatefulWidget {
  final String userId;
  const MyNetworkTap({super.key, required this.userId});

  @override
  State<MyNetworkTap> createState() => _MyNetworkTapState();
}

class _MyNetworkTapState extends State<MyNetworkTap>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // 🔵 Add this to fix the error
      child: Column(
        children: [
          SizedBox(height: 50),
          Material(
            // 🔵 Wrap TabBar with Material
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              tabs: const [Tab(text: "My Network"), Tab(text: "Starred")],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MyNetworkPage(userId: widget.userId),
                StarredPage(userId: widget.userId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
