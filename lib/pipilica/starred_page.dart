import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StarredPage extends StatefulWidget {
  final String userId;

  const StarredPage({super.key, required this.userId});

  @override
  State<StarredPage> createState() => _StarredPageState();
}

class _StarredPageState extends State<StarredPage> {
  List<Map<String, dynamic>> starredUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStarredUsers();
  }

  Future<void> fetchStarredUsers() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('pipilikas')
              .doc(widget.userId)
              .get();

      List<String> starredIds = List<String>.from(
        userDoc.data()?['starred'] ?? [],
      );

      if (starredIds.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('pipilikas')
              .where('id', whereIn: starredIds)
              .get();

      setState(() {
        starredUsers = querySnapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching starred users: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : starredUsers.isEmpty
        ? const Center(child: Text("No starred users found."))
        : ListView.builder(
          itemCount: starredUsers.length,
          itemBuilder: (context, index) {
            final user = starredUsers[index];
            return _starredCard(
              name: user['name'] ?? "No Name",
              id: user['id'] ?? "Unknown",
              level: user['level']?.toString() ?? "0",
              phone: user['myPhone'] ?? "",
              profileUrl: user['profilePicture'] ?? "",
            );
          },
        );
  }

  Widget _starredCard({
    required String name,
    required String id,
    required String level,
    required String phone,
    required String profileUrl,
  }) {
    return Card(
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
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
            color: Colors.blueAccent,
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
        trailing: const Icon(Icons.star, color: Colors.orange),
      ),
    );
  }
}
