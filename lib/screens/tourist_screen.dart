import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TouristSpots extends StatelessWidget {
  const TouristSpots({super.key});

  void _openMap(String location) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$location');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('দর্শনীয় স্থানসমূহ'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tourist_spots')
            .where('isApproved', isEqualTo: true) // শুধুমাত্র অনুমোদিত তথ্য দেখাবে
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('কোনো দর্শনীয় স্থানের তথ্য পাওয়া যায়নি।'));
          }

          final touristDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: touristDocs.length,
            itemBuilder: (context, index) {
              final spot = touristDocs[index];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(5, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Spot Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spot['name'] ?? 'নাম পাওয়া যায়নি',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'ঠিকানা: ${spot['location'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              spot['description'] ?? 'বর্ণনা পাওয়া যায়নি।',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (spot['location'] != null && spot['location'] != '') {
                            _openMap(spot['location']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ঠিকানা পাওয়া যায়নি।'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.location_on, color: Colors.blue),
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
              final locationController = TextEditingController();
              final descriptionController = TextEditingController();

              return AlertDialog(
                title: Text('নতুন স্থান যোগ করুন'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'নাম',
                        ),
                      ),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'ঠিকানা',
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'বর্ণনা',
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('বাতিল'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          locationController.text.isEmpty ||
                          descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('সব ফিল্ড পূরণ করা আবশ্যক!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FirebaseFirestore.instance.collection('tourist_spots').add({
                        'name': nameController.text,
                        'location': locationController.text,
                        'description': descriptionController.text,
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
                    child: Text('যোগ করুন'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
