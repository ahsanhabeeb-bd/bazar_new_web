import 'package:bazar_new_web/pipilica/my_network_tap.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PipilickHome extends StatelessWidget {
  final Map<String, dynamic> userData;
  const PipilickHome({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: Row(
          children: [
            SizedBox(width: 4),
            Text(
              "Self (${userData['id']})",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _topItem("Top Products", Icons.star),
                    _topItem("New Products", Icons.new_releases),
                    _topItem("Vcare", Icons.local_florist),
                    _topItem("Download", Icons.download),
                    _topItem("My Order", Icons.receipt_long),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  _profileCard(),
                  SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _miniAction("Repeat Order", Icons.replay),
                                    _miniAction(
                                      "Invite Friends",
                                      Icons.group_add,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _miniAction(
                                      "My Bonus",
                                      Icons.card_giftcard,
                                    ),
                                    _miniAction("My Order", Icons.shopping_bag),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Expand our network with more distributors.",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text(
                                    "Add Distributor",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "My Insights",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _insightItem("Vestige AR", Icons.view_in_ar),
                  _insightItem("My Group PV", Icons.people_alt),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MyNetworkTap(userId: userData['id']),
                        ),
                      );
                    },
                    child: _insightItem("My Network", Icons.hub),
                  ),

                  _insightItem("My Wallet", Icons.card_membership),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            userData['profilePicture'],
                          ),
                          radius: 25,
                        ),
                        SizedBox(height: 5),
                        Text(userData['name'], style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, size: 32),
                      SizedBox(height: 6),
                      Text("View QR", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _drawerItem(Icons.card_giftcard, "My Voucher"),
                _drawerItem(Icons.card_giftcard, "My Bonus"),
                _drawerItem(Icons.shopping_bag, "My Orders"),
                _drawerItem(Icons.payment, "Make Payment"),
                _drawerItem(Icons.school, "My Training"),
                _drawerItem(Icons.location_on, "Branches"),
                _drawerItem(Icons.recommend, "Recommendation"),
                _drawerItem(Icons.person_add, "New Member Registration"),
                _drawerItem(Icons.group_add, "Refer a Friend"),
                _drawerItem(Icons.mobile_screen_share, "My Prospect"),
                ListTile(
                  leading: Icon(Icons.lock, color: Colors.blue),
                  title: Text("Change Password"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Change password clicked")),
                    );
                  },
                ),
                _drawerItem(Icons.info_outline, "About Us"),
                _drawerItem(Icons.support_agent, "Support"),
                _drawerItem(Icons.share, "Share App With Network"),
                _drawerItem(Icons.devices, "Logged-In Devices"),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Sign Out"),
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Version - 10.4.5", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {},
    );
  }

  Widget _topItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.deepOrange),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      width: 150,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 22,
            child: Icon(Icons.person, size: 28, color: Colors.blue.shade900),
          ),
          SizedBox(height: 10),
          Text(
            userData['name'],
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            "Distributor-${userData['id']}",
            style: TextStyle(color: Colors.greenAccent, fontSize: 12),
          ),
          SizedBox(height: 10),
          Text("0", style: TextStyle(color: Colors.white)),
          Text("MY PV", style: TextStyle(color: Colors.white)),
          SizedBox(height: 5),
          Text("0", style: TextStyle(color: Colors.white)),
          Text("GROUP PV", style: TextStyle(color: Colors.white)),
          SizedBox(height: 5),
          Text(
            "${userData['downlines']?.length ?? 0}",
            style: TextStyle(color: Colors.white),
          ),
          Text("MY NETWORK", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _miniAction(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: Colors.pinkAccent),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _insightItem(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade200,
              child: Icon(icon, color: Colors.black),
            ),
            SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
