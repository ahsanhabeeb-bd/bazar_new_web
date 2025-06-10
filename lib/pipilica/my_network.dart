import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyNetworkPage extends StatefulWidget {
  final String userId;

  const MyNetworkPage({super.key, required this.userId});

  @override
  State<MyNetworkPage> createState() => _MyNetworkPageState();
}

class _MyNetworkPageState extends State<MyNetworkPage> {
  List<Map<String, dynamic>> downlines = [];
  bool isLoading = true;
  String? uplineId;
  List<String> starredIds = [];

  @override
  void initState() {
    super.initState();
    fetchDownlines();
    fetchUpline();
    fetchStarredList();
  }

  Future<void> fetchStarredList() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('pipilikas')
              .doc(widget.userId)
              .get();

      if (doc.exists) {
        List<dynamic> starred = doc.data()?['starred'] ?? [];
        setState(() {
          starredIds = List<String>.from(starred);
        });
      }
    } catch (e) {
      print("❌ Error fetching starred: $e");
    }
  }

  Future<void> toggleStar(String downlineId) async {
    final ref = FirebaseFirestore.instance
        .collection('pipilikas')
        .doc(widget.userId);
    final isStarred = starredIds.contains(downlineId);

    setState(() {
      isStarred ? starredIds.remove(downlineId) : starredIds.add(downlineId);
    });

    try {
      await ref.update({
        'starred':
            isStarred
                ? FieldValue.arrayRemove([downlineId])
                : FieldValue.arrayUnion([downlineId]),
      });
    } catch (e) {
      print("❌ Error updating starred list: $e");
    }
  }

  Future<void> fetchUpline() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('pipilikas')
              .doc(widget.userId)
              .get();

      if (doc.exists) {
        setState(() {
          uplineId = doc.data()?['uplines'] ?? '';
        });
      }
    } catch (e) {
      print("❌ Error fetching upline: $e");
    }
  }

  Future<void> fetchDownlines() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('pipilikas')
              .where('referredBy', isEqualTo: widget.userId)
              .get();

      setState(() {
        downlines = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching downlines: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Network of ${widget.userId}",
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text(
                  "Your Upline",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "Distributor ID-${uplineId ?? '...'}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : downlines.isEmpty
                    ? const Center(child: Text("No downlines found."))
                    : ListView.builder(
                      itemCount: downlines.length,
                      itemBuilder: (context, index) {
                        final user = downlines[index];
                        return _distributorCard(
                          name: user['name'] ?? "No Name",
                          id: user['id'] ?? "Unknown",
                          email: user['email'] ?? "",
                          level: user['level']?.toString() ?? "0",
                          phone: user['myPhone'] ?? "",
                          profileUrl: user['profilePicture'] ?? "",
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _distributorCard({
    required String name,
    required String id,
    required String email,
    required String level,
    required String phone,
    required String profileUrl,
  }) {
    final isStarred = starredIds.contains(id);

    return Card(
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyNetworkPage(userId: id), // 🔁 Recursive open
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage:
              profileUrl.isNotEmpty
                  ? NetworkImage(profileUrl)
                  : const AssetImage("assets/images/default_avatar.png")
                      as ImageProvider,
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: $id"),
            Text("Phone: $phone"),
            Text("Level: $level"),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.star,
            color: isStarred ? Colors.orange : Colors.grey,
          ),
          onPressed: () => toggleStar(id),
        ),
      ),
    );
  }
}
