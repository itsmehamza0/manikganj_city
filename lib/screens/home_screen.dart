import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/grid_item_widget.dart';
import '../widgets/carousel_slider.dart';
import 'ambulance_screen.dart';
import 'bank_screen.dart';
import 'blood_screen.dart';
import 'road_screen.dart';
import 'doctor_screen.dart';
import 'educational_screen.dart';
import 'electricity_screen.dart';
import 'fireservice_screen.dart';
import 'helplines_screen.dart';
import 'history_screen.dart';
import 'service_center.dart';
import 'hospital_screen.dart';
import 'to_let.dart';
import 'drawer/main_drawer.dart';
import 'mosque_screen.dart';
import 'notice_screen.dart';
import 'police_screen.dart';
import 'tourist_screen.dart';
import 'veterinary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Future to fetch carousel images from Firestore
  Future<List<String>> fetchCarouselImages() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('carouselImages').get();
      return snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    } catch (e) {
      print('Error fetching carousel images: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // আপনার লোগো ইমেজের পাথ
              height: 40, // ইমেজের উচ্চতা নির্ধারণ করুন
            ),
          ],
        ),
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
      drawer: MainDrawer(),
      // drawer end
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Fetching and displaying carousel images dynamically from Firestore
            FutureBuilder<List<String>>(
              future: fetchCarouselImages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.connectionState == ConnectionState.none || snapshot.hasError) {
                  return Center(child: Text('ক্যারাউসেল লোড করতে ব্যর্থ হয়েছে।'));
                }

                List<String> images = snapshot.data ?? [];

                return images.isEmpty
                    ? Center(child: Text('কোনো ছবি পাওয়া যায়নি।'))
                    : ImageCarousel(
                  key: ValueKey(images), // Ensures refresh on new data
                  imageUrls: images,
                );
              },
            ),

            SizedBox(height: 10),
            // Text Scroll widget for dynamic scrolling text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade200,
                  ],
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

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text('স্ক্রল করার জন্য কোনো টেক্সট পাওয়া যায়নি।'));
                  }

                  String text = snapshot.data!['text'];

                  return TextScroll(
                    text,
                    velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                    style: GoogleFonts.notoSerifBengali(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 10),
            // GridView for displaying the categories
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                children: [
                  _buildGridItem(context, 'assets/images/book.png', "ইতিহাস ও সংস্কৃতি", HistoryCulture()),
                  _buildGridItem(context, 'assets/images/doctor.png', "ডাক্তার", DoctorPage()),
                  _buildGridItem(context, 'assets/images/hospital.png', "হাসপাতাল", HospitalPage()),
                  _buildGridItem(context, 'assets/images/ambulance.png', "এম্বুলেন্স", Ambulance()),
                  _buildGridItem(context, 'assets/images/blood-test.png', "রক্ত", BloodDonor()),
                  _buildGridItem(context, 'assets/images/bus.png', "রোড সার্ভিস", RoadService()),
                  _buildGridItem(context, 'assets/images/destination.png', "দর্শনীয় স্থান", TouristSpots()),
                  _buildGridItem(context, 'assets/images/graduation-hat.png', "শিক্ষা প্রতিষ্ঠান", EducationalInstitutes()),
                  _buildGridItem(context, 'assets/images/hotel.png', "টু লেট", ToLet()),
                  _buildGridItem(context, 'assets/images/idea.png', "বিদ্যুৎ অফিস", ElectricityOffice()),
                  _buildGridItem(context, 'assets/images/mosque.png', "মসজিদ", Mosque()),
                  _buildGridItem(context, 'assets/images/police-station.png', "পুলিশ", Police()),
                  _buildGridItem(context, 'assets/images/robot.png', "ফায়ার সার্ভিস", FireService()),
                  _buildGridItem(context, 'assets/images/veterinarian.png', "পশু হাসপাতাল", Veterinary()),
                  _buildGridItem(context, 'assets/images/helpline.png', "জরুরি হেল্পলাইন", Helplines()),
                  _buildGridItem(context, 'assets/images/service-center.png', "সার্ভিস সেন্টার", JobService()),
                  _buildGridItem(context, 'assets/images/bank.png', "ব্যাংক", BankPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated grid item widget that navigates to the specified page
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
