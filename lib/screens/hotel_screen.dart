import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Hotel extends StatelessWidget {
  const Hotel({super.key});

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
        title: Text('হোটেল সমূহ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hotels')
            .where('isApproved', isEqualTo: true) // শুধুমাত্র অনুমোদিত হোটেল দেখাবে
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('কোনো হোটেল তথ্য পাওয়া যায়নি।', style: TextStyle(fontSize: 18)));
          }

          final hotelDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: hotelDocs.length,
            itemBuilder: (context, index) {
              final hotel = hotelDocs[index];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Hotel Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel['name'] ?? 'নাম পাওয়া যায়নি',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ঠিকানা: ${hotel['address'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ফোন: ${hotel['phone'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (hotel['address'] != null && hotel['address'] != '') {
                            _openMap(hotel['address']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ঠিকানা পাওয়া যায়নি।'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.location_on, color: Colors.blue.shade700),
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
              final phoneController = TextEditingController();

              return AlertDialog(
                title: Text('নতুন হোটেল যোগ করুন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'হোটেল নাম',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'ঠিকানা',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'ফোন নম্বর',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
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
                    child: Text('বাতিল', style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('সব ফিল্ড পূরণ করা আবশ্যক!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FirebaseFirestore.instance.collection('hotels').add({
                        'name': nameController.text,
                        'address': addressController.text,
                        'phone': phoneController.text,
                        'isApproved': false, // অনুমোদন পেন্ডিং
                      });

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'তথ্য সফলভাবে যুক্ত হয়েছে। যাচাইয়ের পর এটি শীঘ্রই আপডেট হবে।'),
                          backgroundColor: Colors.green.shade300,
                        ),
                      );
                    },
                    child: Text('যোগ করুন', style: TextStyle(fontSize: 16, color: Colors.green)),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.green.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
