import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalPage extends StatelessWidget {
  const HospitalPage({super.key});

  // ফোন কল লঞ্চ ফাংশন
  void _makePhoneCall(String phone, BuildContext context) async {
    final phoneUrl = 'tel:$phone';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ফোন কল শুরু করা সম্ভব হয়নি')),
      );
    }
  }

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
        title: Text('হাসপাতালের তালিকা'),
        centerTitle: true,
        backgroundColor: Colors.purple.shade600,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hospitals')
            .where('isApproved', isEqualTo: true) // Show only approved hospitals
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('কোন হাসপাতাল পাওয়া যায়নি।',
                    style: TextStyle(fontSize: 18, color: Colors.black54)));
          }

          final hospitalDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: hospitalDocs.length,
            itemBuilder: (context, index) {
              final hospital = hospitalDocs[index];

              return GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white38],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(5, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(bottom: 10),
                  margin: EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/hospitals.jpg',
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      Text(
                        hospital['name'] ?? 'নাম পাওয়া যায়নি',
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
                        'ফোন: ${hospital['phone'] ?? 'তথ্য নেই'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'ঠিকানা: ${hospital['address'] ?? 'তথ্য নেই'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => _makePhoneCall(hospital['phone'] ?? '', context),
                            icon: Icon(Icons.phone, color: Colors.green.shade600),
                          ),
                          IconButton(
                            onPressed: () => _openMaps(hospital['address'] ?? '', context),
                            icon: Icon(Icons.map, color: Colors.blue.shade300),
                          ),
                        ],
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
              final phoneController = TextEditingController();
              final addressController = TextEditingController();

              return AlertDialog(
                title: Text('নতুন হাসপাতাল যোগ করুন',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'হাসপাতালের নাম',
                          errorText: nameController.text.isEmpty
                              ? 'ফিল্ডটি পূরণ করুন'
                              : null,
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
                    child: Text('বাতিল', style: TextStyle(fontSize: 16)),
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

                      FirebaseFirestore.instance.collection('hospitals').add({
                        'name': nameController.text,
                        'phone': phoneController.text,
                        'address': addressController.text,
                        'isApproved': false, // Initially false
                      });

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'আপনার হাসপাতালের তথ্য সফলভাবে যুক্ত হয়েছে। আমরা যাচাই করার পর এটি শীঘ্রই আপডেট হবে।'),
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
        backgroundColor: Colors.purple.shade100,
        child: Icon(Icons.add),
      ),
    );
  }
}