import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BankPage extends StatefulWidget {
  const BankPage({super.key});

  @override
  _BankPageState createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, String>>> _fetchBanks() async {
    // Firestore থেকে ব্যাংক তথ্য ফেচ করা
    QuerySnapshot querySnapshot = await _firestore.collection('banks').where('isApproved', isEqualTo: true).get();

    List<Map<String, String>> banks = [];
    for (var doc in querySnapshot.docs) {
      banks.add({
        'bankName': doc['bankName'],
        'bankLocation': doc['bankLocation'],
        'phone': doc['phone'],
      });
    }
    return banks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ব্যাংক তথ্য'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, String>>>(

          future: _fetchBanks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('কোনো ব্যাংক তথ্য পাওয়া যায়নি'));
            } else {
              List<Map<String, String>> banks = snapshot.data!;
              return ListView.builder(
                itemCount: banks.length,
                itemBuilder: (context, index) {
                  return _buildBankCard(
                    context,
                    banks[index]['bankName']!,
                    banks[index]['bankLocation']!,
                    banks[index]['phone']!,
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
              final bankNameController = TextEditingController();
              final bankLocationController = TextEditingController();
              final phoneController = TextEditingController();

              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: Text(
                  'নতুন ব্যাংক তথ্য যোগ করুন',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: bankNameController,
                        decoration: InputDecoration(
                          labelText: 'ব্যাংকের নাম',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: bankLocationController,
                        decoration: InputDecoration(
                          labelText: 'ব্যাংকের লোকেশন',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'ফোন নম্বর',
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
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
                      if (bankNameController.text.isEmpty ||
                          bankLocationController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('সব ফিল্ড পূরণ করা আবশ্যক!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FirebaseFirestore.instance.collection('banks').add({
                        'bankName': bankNameController.text,
                        'bankLocation': bankLocationController.text,
                        'phone': phoneController.text,
                        'isApproved': false, // Default value is false
                      });

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ব্যাংক তথ্য সফলভাবে যুক্ত হয়েছে।'),
                          backgroundColor: Colors.blue.shade300,
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
        backgroundColor: Colors.blue.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBankCard(
      BuildContext context, String bankName, String bankLocation, String phone) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bankName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'লোকেশন: $bankLocation',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 5),
            Text(
              'ফোন নম্বর: $phone',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
