import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Clipboard ব্যবহার করার জন্য

class FireService extends StatelessWidget {
  const FireService({super.key});

  // ক্লিপবোর্ডে ফোন নম্বর কপি ফাংশন
  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ফোন নম্বর কপি করা হয়েছে: $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ফায়ার সার্ভিস স্টেশন সমূহ'),
        centerTitle: true,
        backgroundColor: Colors.red.shade600,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fireStations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'কোন ফায়ার সার্ভিস স্টেশন পাওয়া যায়নি।',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final fireStationDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: fireStationDocs.length,
            itemBuilder: (context, index) {
              final fireStation = fireStationDocs[index];

              return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/fire-station.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  title: Text(
                    fireStation['name'] ?? 'নাম পাওয়া যায়নি',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.red.shade800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ঠিকানা: ${fireStation['address'] ?? 'তথ্য নেই'}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        'ফোন: ${fireStation['phone'] ?? 'তথ্য নেই'}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.copy, color: Colors.blue),
                    onPressed: () => _copyToClipboard(fireStation['phone'] ?? 'তথ্য নেই', context),
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
