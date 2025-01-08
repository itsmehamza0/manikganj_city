import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Police extends StatelessWidget {
  const Police({super.key});

  // কপি ফাংশন
  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('কপি করা হয়েছে: $text')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('পুলিশ স্টেশন সমূহ'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('policeStations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'কোন পুলিশ স্টেশন পাওয়া যায়নি।',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final policeStationDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: policeStationDocs.length,
            itemBuilder: (context, index) {
              final policeStation = policeStationDocs[index];

              return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/policeman.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  title: Text(
                    policeStation['name'] ?? 'নাম পাওয়া যায়নি',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ফোন: ${policeStation['phone'] ?? 'তথ্য নেই'}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        'ঠিকানা: ${policeStation['address'] ?? 'তথ্য নেই'}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.copy, color: Colors.green),
                    onPressed: () => _copyToClipboard(policeStation['phone'] ?? '', context),
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
