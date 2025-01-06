import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ElectricityOffice extends StatelessWidget {
  const ElectricityOffice({super.key});

  void _openMap(String address) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('বিদ্যুৎ অফিস সমূহ'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A237E), // Deep Blue color for AppBar
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('electricity_offices')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('কোনো অফিস তথ্য পাওয়া যায়নি।', style: TextStyle(color: Color(0xFF1A237E), fontSize: 18)));
          }

          final officeDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: officeDocs.length,
            itemBuilder: (context, index) {
              final office = officeDocs[index];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF176), // Bright Yellow background for uniqueness
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              office['name'] ?? 'নাম পাওয়া যায়নি',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF0D47A1), // Deep Blue text for title
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'ঠিকানা: ${office['address'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF388E3C), // Green for address
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'ফোন: ${office['phone'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (office['address'] != null && office['address'] != '') {
                            _openMap(office['address']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ঠিকানা পাওয়া যায়নি।'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.location_on, color: Color(0xFF0D47A1)), // Matching Deep Blue for Icon
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
