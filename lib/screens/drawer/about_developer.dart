import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloper extends StatelessWidget {
  const AboutDeveloper({super.key});

  // Firebase থেকে ডেভেলপার তথ্য ফেচ করার জন্য ফাংশন
  Future<DocumentSnapshot> fetchDeveloperInfo() async {
    return await FirebaseFirestore.instance.collection('developerInfo').doc('developer1').get();
  }

  // LinkedIn লিঙ্ক লঞ্চ করার জন্য ফাংশন
  Future<void> _launchLinkedIn(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch LinkedIn';
    }
  }

  // WhatsApp লিঙ্ক লঞ্চ করার জন্য ফাংশন
  Future<void> _launchWhatsApp(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Developer"),
        centerTitle: true,
        elevation: 2,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchDeveloperInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No developer information found"));
          }

          var developerData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Developer image
                Center(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(developerData['imageUrl']),
                  ),
                ),
                const SizedBox(height: 20),
                // Developer name
                Center(
                  child: Text(
                    developerData['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Description
                Text(
                  developerData['description'],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Contact Info with Icons and Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LinkedIn
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.account_circle),
                          onPressed: () => _launchLinkedIn(developerData['socialMediaLinkedIn']),
                        ),
                        Text(
                          'LinkedIn',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    // WhatsApp
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.chat),
                          onPressed: () => _launchWhatsApp(developerData['contactWhatsApp']),
                        ),
                        Text(
                          'WhatsApp',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
