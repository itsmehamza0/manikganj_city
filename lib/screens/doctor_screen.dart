import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorPage extends StatelessWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ডাক্তারের তালিকা'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('isApproved', isEqualTo: true) // Show only approved doctors
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('কোন ডাক্তার পাওয়া যায়নি।'));
          }

          final doctorDocs = snapshot.data!.docs;

          // List of background colors
          final List<Color> backgroundColors = [
            Colors.blue.shade200,
            Colors.green.shade200,
            Colors.orange.shade200,
            Colors.purple.shade200,
            Colors.teal.shade200,
          ];

          return ListView.builder(
            itemCount: doctorDocs.length,
            itemBuilder: (context, index) {
              final doctor = doctorDocs[index];
              final backgroundColor =
              backgroundColors[index % backgroundColors.length]; // Cycle colors

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: backgroundColor,
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
                      // Static doctor image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.asset(
                          'assets/images/medical-team.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 20),
                      // Doctor Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['name'] ?? 'নাম পাওয়া যায়নি',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'বিশেষজ্ঞতা: ${doctor['specialization'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'ফোন: ${doctor['phone'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'ঠিকানা: ${doctor['address'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Call button
                      IconButton(
                        icon: Icon(
                          Icons.call,
                          color: Colors.teal,
                          size: 30,
                        ),
                        onPressed: () async {
                          final phone = doctor['phone'];
                          if (phone != null) {
                            final Uri telUri = Uri.parse('tel:$phone');
                            try {
                              if (await canLaunch(telUri.toString())) {
                                await launch(telUri.toString());
                              } else {
                                throw 'Could not launch $telUri';
                              }
                            } catch (e) {
                              print('Error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('ফোন কল শুরু করা সম্ভব হয়নি'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      // Map button (Google Maps)
                      IconButton(
                        icon: Icon(
                          Icons.map,
                          color: Colors.teal,
                          size: 30,
                        ),
                        onPressed: () async {
                          final address = doctor['address'];
                          if (address != null) {
                            final String googleMapsUrl =
                                'https://www.google.com/maps/search/?q=${Uri.encodeComponent(address)}';
                            try {
                              if (await canLaunch(googleMapsUrl)) {
                                await launch(googleMapsUrl);
                              } else {
                                throw 'Could not launch $googleMapsUrl';
                              }
                            } catch (e) {
                              print('Error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('গুগল ম্যাপে ঠিকানা খোলার সময় সমস্যা হয়েছে'),
                                ),
                              );
                            }
                          }
                        },
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
              final specializationController = TextEditingController();
              final phoneController = TextEditingController();
              final addressController = TextEditingController();

              return AlertDialog(
                title: Text('নতুন ডাক্তার যোগ করুন'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'নাম',
                          errorText: nameController.text.isEmpty ? 'ফিল্ডটি পূরণ করুন' : null,
                        ),
                      ),
                      TextField(
                        controller: specializationController,
                        decoration: InputDecoration(
                          labelText: 'বিশেষজ্ঞতা',
                        ),
                      ),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'ফোন',
                        ),
                        keyboardType: TextInputType.phone,
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
                    child: Text('বাতিল'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          specializationController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('সব ফিল্ড পূরণ করা আবশ্যক!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FirebaseFirestore.instance.collection('doctors').add({
                        'name': nameController.text,
                        'specialization': specializationController.text,
                        'phone': phoneController.text,
                        'address': addressController.text,
                        'isApproved': false, // Initially false
                      });

                      Navigator.of(context).pop();

                      // Show a success message after adding
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('আপনার ডাক্তারের তথ্য সফলভাবে যুক্ত হয়েছে। যাচাইয়ের পর এটি শীঘ্রই আপডেট হবে।'),
                          backgroundColor: Colors.red.shade300,
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
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }
}
