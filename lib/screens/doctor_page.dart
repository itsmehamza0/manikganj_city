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
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
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
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Static doctor image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/images/doctor.png',
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
                            SizedBox(height: 8),
                            Text(
                              'বিশেষজ্ঞতা: ${doctor['specialization'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8),
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
                            final Uri telUri = Uri(scheme: 'tel', path: phone);
                            if (await canLaunch(telUri.toString())) {
                              await launch(telUri.toString());
                            } else {
                              throw 'Could not launch $telUri';
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
                      });

                      Navigator.of(context).pop();
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
