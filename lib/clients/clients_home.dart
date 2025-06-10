import 'package:bazar_new_web/clients/client_accepted_orders.dart';
import 'package:bazar_new_web/clients/client_pending_orders.dart';
import 'package:bazar_new_web/clients/client_profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? profilePictureUrl;
  String? id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfilePicture();
    _loadId();
  }

  Future<void> _loadId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString("id") ?? "";
    });
  }

  Future<void> _loadProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePictureUrl = prefs.getString("profilePicture") ?? "";
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Home"),
        actions: [
          IconButton(
            icon:
                profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                    ? CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(profilePictureUrl!),
                    )
                    : const Icon(Icons.person, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientProfile()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black38,
          tabs: const [
            Tab(text: "Pending Orders"),
            Tab(text: "Accepted Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ClientPendingOrders(), ClientAcceptedOrders()],
      ),
    );
  }
}
