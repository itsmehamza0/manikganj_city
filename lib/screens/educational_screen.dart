import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationalInstitutes extends StatefulWidget {
  const EducationalInstitutes({super.key});

  @override
  _EducationalInstitutesPageState createState() => _EducationalInstitutesPageState();
}

class _EducationalInstitutesPageState extends State<EducationalInstitutes> {
  String? _selectedCategory = 'কলেজ'; // ডিফল্ট মান 'কলেজ'

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
        title: const Text('শিক্ষা প্রতিষ্ঠান'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('educational_institutes')
            .where('isApproved', isEqualTo: true) // শুধুমাত্র অনুমোদিত তথ্য দেখাবে
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('কোনো প্রতিষ্ঠান পাওয়া যায়নি।'));
          }

          final instituteDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: instituteDocs.length,
            itemBuilder: (context, index) {
              final institute = instituteDocs[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(5, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Institute Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              institute['name'] ?? 'নাম পাওয়া যায়নি',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'ঠিকানা: ${institute['location'] ?? 'তথ্য নেই'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'শ্রেণী/বিভাগ: ${institute['category'] ?? 'তথ্য নেই'}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (institute['location'] != null &&
                              institute['location'] != '') {
                            _openMap(institute['location']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ঠিকানা পাওয়া যায়নি।'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.location_on, color: Colors.green),
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

              return AlertDialog(
                title: const Text('নতুন শিক্ষা প্রতিষ্ঠান যোগ করুন'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'নাম',
                        ),
                      ),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'ঠিকানা',
                        ),
                      ),
                      // ড্রপডাউন সিস্টেম
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'শ্রেণী/বিভাগ',
                        ),
                        items: ['কলেজ', 'স্কুল', 'মাদ্রাসা']
                            .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                            .toList(),
                        onChanged: (newCategory) {
                          setState(() {
                            _selectedCategory = newCategory;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('বাতিল'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          locationController.text.isEmpty ||
                          _selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('সব ফিল্ড পূরণ করা আবশ্যক!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FirebaseFirestore.instance
                          .collection('educational_institutes')
                          .add({
                        'name': nameController.text,
                        'location': locationController.text,
                        'category': _selectedCategory,
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
                    child: const Text('যোগ করুন'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
