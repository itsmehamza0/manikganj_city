import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/grid_item_widget.dart';
import 'blood_screen.dart';
import 'bus_screen.dart';
import 'doctor_screen.dart';
import 'educational_screen.dart';
import 'electricity_screen.dart';
import 'fireservice_screen.dart';
import 'helplines_screen.dart';
import 'history_screen.dart';
import 'hospital_screen.dart';
import 'hotel_screen.dart';
import 'mosque_screen.dart';
import 'notice_screen.dart';
import 'police_screen.dart';
import 'tourist_screen.dart';
import 'veterinary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manikganj City"),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notice()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  "Drawer Header",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Dynamic Image Carousel
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('carouselImages').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading images!'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No images available.'));
                }

                List<String> imageUrls = snapshot.data!.docs.map((doc) {
                  return doc['imageUrl'] as String;
                }).toList();

                return CarouselSlider.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index, realIndex) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // Scrolling Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('scrollingText')
                    .doc('textDocumentID')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading text!'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text('No text available.'));
                  }

                  String text = snapshot.data!['text'];

                  return Text(
                    text,
                    style: GoogleFonts.notoSerifBengali(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // GridView
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                children: [
                  _buildGridItem(context, 'assets/images/map.png', "ইতিহাস ও সংস্কৃতি", HistoryCulture()),
                  _buildGridItem(context, 'assets/images/doctor.png', "ডাক্তার", DoctorPage()),
                  _buildGridItem(context, 'assets/images/hospital.png', "হাসপাতাল", HospitalPage()),
                  _buildGridItem(context, 'assets/images/blood-test.png', "রক্ত", BloodDonor()),
                  _buildGridItem(context, 'assets/images/bus.png', "বাসের সময়সূচি", BusSchedule()),
                  _buildGridItem(context, 'assets/images/destination.png', "দর্শনীয় স্থান", TouristSpots()),
                  _buildGridItem(context, 'assets/images/graduation-hat.png', "শিক্ষা প্রতিষ্ঠান", EducationalInstitutes()),
                  _buildGridItem(context, 'assets/images/hotel.png', "হোটেল", Hotel()),
                  _buildGridItem(context, 'assets/images/idea.png', "বিদ্যুৎ অফিস", ElectricityOffice()),
                  _buildGridItem(context, 'assets/images/mosque.png', "মসজিদ", Mosque()),
                  _buildGridItem(context, 'assets/images/police-station.png', "পুলিশ", Police()),
                  _buildGridItem(context, 'assets/images/robot.png', "ফায়ার সার্ভিস", FireService()),
                  _buildGridItem(context, 'assets/images/veterinarian.png', "পশু হাসপাতাল", Veterinary()),
                  _buildGridItem(context, 'assets/images/helpline.png', "জরুরি হেল্পলাইন", Helplines()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grid Item Builder
  Widget _buildGridItem(BuildContext context, String image, String title, Widget targetPage) {
    return GridItemWidget(
      image: image,
      title: title,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
    );
  }
}
