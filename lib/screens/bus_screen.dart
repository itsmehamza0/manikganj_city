import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BusSchedule extends StatelessWidget {
  const BusSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('বাসের সময়সূচী'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bus_schedule')
            .where('isApproved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'কোনো বাসের তথ্য পাওয়া যায়নি।',
                style: TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
            );
          }

          final busDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: busDocs.length,
            itemBuilder: (context, index) {
              final bus = busDocs[index];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Icon(Icons.directions_bus, color: Colors.indigo),
                  ),
                  title: Text(
                    bus['route'] ?? 'রুট তথ্য নেই',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text('সময়: ${bus['time'] ?? 'তথ্য নেই'}', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 3),
                      Text('ফোন: ${bus['phone'] ?? 'তথ্য নেই'}', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.call, color: Colors.green, size: 28),
                    onPressed: () async {
                      final phone = bus['phone'];
                      if (phone != null) {
                        final Uri telUri = Uri.parse('tel:$phone');
                        if (await canLaunch(telUri.toString())) {
                          await launch(telUri.toString());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ফোন কল শুরু করা সম্ভব হয়নি')),
                          );
                        }
                      }
                    },
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
              final routeController = TextEditingController();
              final timeController = TextEditingController();
              final phoneController = TextEditingController();

              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: Text('নতুন বাসের তথ্য যোগ করুন', textAlign: TextAlign.center),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: routeController,
                        decoration: InputDecoration(
                          labelText: 'রুট',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: timeController,
                        decoration: InputDecoration(
                          labelText: 'সময়',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('বাতিল', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (routeController.text.isEmpty ||
                          timeController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('সব ফিল্ড পূরণ করা আবশ্যক!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      FirebaseFirestore.instance.collection('bus_schedule').add({
                        'route': routeController.text,
                        'time': timeController.text,
                        'phone': phoneController.text,
                        'isApproved': false,
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('তথ্য সফলভাবে যুক্ত হয়েছে। আমরা যাচাই করার পর এটি শীঘ্রই আপডেট হবে।'),
                          backgroundColor: Colors.green,
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
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
