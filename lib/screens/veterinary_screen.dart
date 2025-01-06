import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Veterinary extends StatelessWidget {
  const Veterinary({super.key});

  void _makeCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      throw 'Could not call $phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('পশু চিকিৎসা কেন্দ্র সমূহ'),
        centerTitle: true,
        backgroundColor: Colors.teal, // Unique Teal color for AppBar
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('veterinary_services')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('কোনো পশু চিকিৎসা কেন্দ্র পাওয়া যায়নি।', style: TextStyle(fontSize: 18)));
          }

          final serviceDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: serviceDocs.length,
            itemBuilder: (context, index) {
              final service = serviceDocs[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(
                    service['name'] ?? 'নাম পাওয়া যায়নি',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text('ঠিকানা: ${service['address'] ?? 'তথ্য নেই'}'),
                      SizedBox(height: 3),
                      Text('ফোন: ${service['phone'] ?? 'তথ্য নেই'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.phone, color: Colors.teal),
                    onPressed: () {
                      if (service['phone'] != null && service['phone'] != '') {
                        _makeCall(service['phone']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ফোন নম্বর পাওয়া যায়নি।'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
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
