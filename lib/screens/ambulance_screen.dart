import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Ambulance extends StatelessWidget {
  const Ambulance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যাম্বুলেন্স সেবা'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ambulances')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'কোনো অ্যাম্বুলেন্সের তথ্য পাওয়া যায়নি।',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final ambulances = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ambulances.length,
            itemBuilder: (context, index) {
              return _buildAmbulanceCard(context, ambulances[index]);
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
              final phoneController = TextEditingController();
              final addressController = TextEditingController();

              return AlertDialog(
                title: Text('নতুন অ্যাম্বুলেন্স যোগ করুন'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'অ্যাম্বুলেন্স নাম',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          errorText: nameController.text.isEmpty ? 'ফিল্ডটি পূরণ করুন' : null,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'ফোন',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'অ্যাম্বুলেন্সের ঠিকানা',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 10),
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

                      FirebaseFirestore.instance.collection('ambulances').add({
                        'name': nameController.text,
                        'phone': phoneController.text,
                        'address': addressController.text,
                      });

                      Navigator.of(context).pop();

                      // Show a success message after adding
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('অ্যাম্বুলেন্সের তথ্য সফলভাবে যুক্ত হয়েছে।'),
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAmbulanceCard(BuildContext context, QueryDocumentSnapshot ambulance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ambulance['name'] ?? 'নাম পাওয়া যায়নি',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'ফোন: ${ambulance['phone'] ?? 'তথ্য নেই'}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 2),
            Text(
              'ঠিকানা: ${ambulance['address'] ?? 'তথ্য নেই'}',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.green),
                  onPressed: () {
                    final phone = ambulance['phone'];
                    Clipboard.setData(ClipboardData(text: phone));
                    _showSnackbar(context, 'ফোন নম্বর কপি হয়েছে');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.location_on, color: Colors.green),
                  onPressed: () async {
                    final address = ambulance['address'];
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
