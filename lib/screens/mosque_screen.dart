import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Mosque extends StatelessWidget {
  const Mosque({super.key});

  // গুগল ম্যাপসে লোকেশন ওপেন করার ফাংশন
  void _openMaps(String address, BuildContext context) async {
    final googleMapsUrl = 'https://www.google.com/maps/search/?q=$address';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('গুগল ম্যাপে ঠিকানা খোলার সময় সমস্যা হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('মসজিদের তালিকা'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mosques')
            .where('isApproved', isEqualTo: true) // Show only approved mosques
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('কোন মসজিদ পাওয়া যায়নি।',
                    style: TextStyle(fontSize: 18, color: Colors.black54)));
          }

          final mosqueDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: mosqueDocs.length,
            itemBuilder: (context, index) {
              final mosque = mosqueDocs[index];

              return GestureDetector(
                onTap: () => _openMaps(mosque['address'] ?? '', context),
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Image.asset(
                          'assets/images/mosques.jpg',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        mosque['name'] ?? 'নাম পাওয়া যায়নি',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'ঠিকানা: ${mosque['address'] ?? 'তথ্য নেই'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10),
                      IconButton(
                        onPressed: () => _openMaps(mosque['address'] ?? '', context),
                        icon: Icon(Icons.map, color: Colors.blue.shade300),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final nameController = TextEditingController();
              final addressController = TextEditingController();

              return AlertDialog(
                title: Text('নতুন মসজিদ যোগ করুন',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'মসজিদের নাম',
                          errorText: nameController.text.isEmpty
                              ? 'ফিল্ডটি পূরণ করুন'
                              : null,
                        ),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'ঠিকানা',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('বাতিল', style: TextStyle(fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('সব ফিল্ড পূরণ করা আবশ্যক!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FirebaseFirestore.instance.collection('mosques').add({
                        'name': nameController.text,
                        'address': addressController.text,
                        'isApproved': false, // Initially false
                      });

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'আপনার মসজিদের তথ্য সফলভাবে যুক্ত হয়েছে। আমরা যাচাই করার পর এটি শীঘ্রই আপডেট হবে।'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text('যোগ করুন', style: TextStyle(fontSize: 16)),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.teal.shade100,
        child: Icon(Icons.add,color: Colors.black,),
      ),
    );
  }
}
