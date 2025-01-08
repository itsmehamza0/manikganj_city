import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // কপি ফিচারের জন্য

class JobService extends StatefulWidget {
  const JobService({super.key});

  @override
  _ServiceCenterState createState() => _ServiceCenterState();
}

class _ServiceCenterState extends State<JobService> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedServiceType;

  // সার্ভিস টাইপের লিস্ট
  final List<String> _serviceTypes = [
    'টিউটর',
    'প্লাম্বার',
    'মিস্ত্রি',
    'হেল্পিং হ্যান্ড',
    'অন্যান্য',
  ];

  Future<List<Map<String, String>>> _fetchServices() async {
    // Firestore থেকে শুধুমাত্র isApproved == true সার্ভিস ফেচ করা
    QuerySnapshot querySnapshot = await _firestore
        .collection('services')
        .where('isApproved', isEqualTo: true)  // ফিল্টার প্রয়োগ
        .get();

    List<Map<String, String>> services = [];
    for (var doc in querySnapshot.docs) {
      services.add({
        'name': doc['name'],
        'serviceType': doc['serviceType'],
        'phone': doc['phone'],
        'address': doc['address'], // ঠিকানা ফিল্ড
      });
    }
    return services;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জব সার্ভিস'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, String>>>(

          future: _fetchServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('কোনো সার্ভিস পাওয়া যায়নি'));
            } else {
              List<Map<String, String>> services = snapshot.data!;
              return ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return _buildServiceCard(
                    context,
                    services[index]['name']!,
                    services[index]['serviceType']!,
                    services[index]['phone']!,
                    services[index]['address']!,
                  );
                },
              );
            }
          },
        ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: Text(
                  'নতুন সার্ভিস তথ্য যোগ করুন',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'নাম',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 12),
                      // সার্ভিস টাইপের জন্য ড্রপডাউন
                      DropdownButtonFormField<String>(
                        value: _selectedServiceType,
                        hint: Text('সার্ভিস টাইপ নির্বাচন করুন'),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedServiceType = newValue;
                          });
                        },
                        items: _serviceTypes.map((serviceType) {
                          return DropdownMenuItem(
                            value: serviceType,
                            child: Text(serviceType),
                          );
                        }).toList(),
                        decoration: InputDecoration(
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
                      SizedBox(height: 12),
                      // ঠিকানা ইনপুট
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'ঠিকানা',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          _selectedServiceType == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('সব ফিল্ড পূরণ করা আবশ্যক!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FirebaseFirestore.instance.collection('services').add({
                        'name': nameController.text,
                        'serviceType': _selectedServiceType!,
                        'phone': phoneController.text,
                        'address': addressController.text,
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

  Widget _buildServiceCard(
      BuildContext context, String name, String serviceType, String phone, String address) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'সার্ভিস টাইপ: $serviceType',
              style: const TextStyle(fontSize: 16, color: Colors.red,fontWeight: FontWeight.w700),
            ),

            Row(
              children: [
                Text(
                    'ফোনঃ $phone',
                    style: const TextStyle(fontSize: 15, color: Colors.green)),
               const SizedBox(width: 200,),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.green), // কপি আইকন
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: phone)); // ফোন নম্বর কপি করা
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ফোন নম্বর কপি হয়েছে')),
                    );
                  },
                ),
              ],
            ),
            Text(
              'ঠিকানা: $address',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
