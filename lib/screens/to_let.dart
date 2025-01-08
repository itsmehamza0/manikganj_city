import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ToLet extends StatelessWidget {
  const ToLet({super.key});

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
        title: Text('টু লেট', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tolet') // পরিবর্তন করুন হোটেল থেকে টু লেট
            .where('isApproved', isEqualTo: true) // শুধুমাত্র অনুমোদিত ডাটা দেখাবে
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('কোনো তথ্য পাওয়া যায়নি।', style: TextStyle(fontSize: 18)));
          }

          final toLetDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: toLetDocs.length,
            itemBuilder: (context, index) {
              final toLet = toLetDocs[index];

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
                      // Display the details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toLet['category'] ?? 'ক্যাটাগরি পাওয়া যায়নি',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'নাম: ${toLet['name'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ঠিকানা: ${toLet['address'] ?? 'তথ্য নেই'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ফোন: ${toLet['phone'] ?? 'তথ্য নেই'}',
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
                          if (toLet['address'] != null && toLet['address'] != '') {
                            _openMap(toLet['address']);
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
              String? selectedCategory;

              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: Text(
                  'নতুন তথ্য যোগ করুন',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'বিভাগ নির্বাচন করুন',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: ['আবাসিক হোটেল', 'ফ্ল্যাট', 'ম্যাচ ভাড়া']
                            .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                            .toList(),
                        onChanged: (value) {
                          selectedCategory = value;
                        },
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'নাম',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'ঠিকানা',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'ফোন নম্বর',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.phone,
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (selectedCategory == null ||
                          nameController.text.isEmpty ||
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

                      FirebaseFirestore.instance.collection('tolet').add({
                        'category': selectedCategory,
                        'name': nameController.text,
                        'address': addressController.text,
                        'phone': phoneController.text,
                        'isApproved': false, // অনুমোদন পেন্ডিং
                      });

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('তথ্য সফলভাবে যুক্ত হয়েছে। যাচাইয়ের পর এটি শীঘ্রই আপডেট হবে।'),
                          backgroundColor: Colors.green.shade300,
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
        backgroundColor: Colors.green.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
