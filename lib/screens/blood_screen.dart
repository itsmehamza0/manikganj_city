import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodDonor extends StatelessWidget {
  const BloodDonor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('রক্তদাতা তালিকা'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donors')
            .where('isApproved', isEqualTo: true) // Filter only approved donors
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'কোনো রক্তদাতার তথ্য পাওয়া যায়নি।',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final donors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: donors.length,
            itemBuilder: (context, index) {
              return _buildDonorCard(context, donors[index]);
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
              final bloodGroupController = TextEditingController();
              final phoneController = TextEditingController();
              final addressController = TextEditingController();

              return AlertDialog(
                title: Text('নতুন রক্তদাতা যোগ করুন'),
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
                        controller: bloodGroupController,
                        decoration: InputDecoration(
                          labelText: 'রক্তের গ্রুপ',
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
                          bloodGroupController.text.isEmpty ||
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

                      FirebaseFirestore.instance.collection('donors').add({
                        'name': nameController.text,
                        'bloodGroup': bloodGroupController.text,
                        'phone': phoneController.text,
                        'address': addressController.text,
                        'isApproved': false,  // New 'isApproved' field added with a value of false
                      });

                      Navigator.of(context).pop();

                      // Show a success message after adding
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('রক্তদাতার তথ্য সফলভাবে যুক্ত হয়েছে। আমরা যাচাই করার পর এটি শীঘ্রই আপডেট হবে।'),
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
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDonorCard(BuildContext context, QueryDocumentSnapshot donor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              donor['name'] ?? 'নাম পাওয়া যায়নি',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'রক্তের গ্রুপ: ${donor['bloodGroup'] ?? 'তথ্য নেই'}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 2),
            Text(
              'ফোন: ${donor['phone'] ?? 'তথ্য নেই'}',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 2),
            Text(
              'ঠিকানা: ${donor['address'] ?? 'তথ্য নেই'}',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.red),
                  onPressed: () async {
                    final Uri telUri = Uri.parse('tel:${donor['phone']}');
                    if (await canLaunch(telUri.toString())) {
                      await launch(telUri.toString());
                    } else {
                      _showSnackbar(
                          context, 'ফোন কল শুরু করা সম্ভব হয়নি');
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.red),
                  onPressed: () async {
                    final address = donor['address'];
                    final String googleMapsUrl =
                        'https://www.google.com/maps/search/?q=${Uri.encodeComponent(address)}';
                    if (await canLaunch(googleMapsUrl)) {
                      await launch(googleMapsUrl);
                    } else {
                      _showSnackbar(
                          context, 'গুগল ম্যাপে ঠিকানা খোলার সময় সমস্যা হয়েছে');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
