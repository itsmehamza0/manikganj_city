import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manikganj_city/application/color.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/grid_item_widget.dart';
import '../widgets/carousel_slider.dart';
import 'blood_screen.dart';
import 'bus_screen.dart';
import 'doctor_screen.dart';
import 'educational_screen.dart';
import 'electricity_screen.dart';
import 'fireservice_screen.dart';
import 'history_screen.dart';
import 'hospital_screen.dart';
import 'hotel_screen.dart';
import 'mosque_screen.dart';
import 'police_screen.dart';
import 'tourist_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of online image URLs
    List<String> images = [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSifk84PNoLETKdAEqML0UQWI1Y6reGrJd1ug&s',
      'https://i.ytimg.com/vi/ZoBhGafetWM/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCa9fAnblU54iDatzC1jSSjkQMXew',
      'https://www.bssnews.net/assets/news_photos/2023/12/12/image-162816-1702360687.jpg',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manikganj City"),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.appMainColor,
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
            // ImageCarousel widget
            ImageCarousel(imageUrls: images),
            SizedBox(height: 10),
            // Text Scroll widget
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
                future: FirebaseFirestore.instance.collection('scrollingText').doc('textDocumentID').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong!'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text('No text found.'));
                  }

                  // Firebase থেকে টেক্সট নিয়ে আসা
                  String text = snapshot.data!['text'];

                  return TextScroll(
                    velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
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
            SizedBox(height: 10),
            // GridView
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                children: [
                  _buildGridItem(context, 'assets/images/map.png', "ইতিহাস ও সংস্কৃতি",  HistoryCulture()),
                  _buildGridItem(context, 'assets/images/doctor.png', "ডাক্তার",  DoctorPage()),
                  _buildGridItem(context, 'assets/images/hospital.png', "হাসঁসপাতাল",  HospitalPage()),
                  _buildGridItem(context, 'assets/images/blood-test.png', "রক্ত",  BloodDonor()),
                  _buildGridItem(context, 'assets/images/bus.png', "বাসের সময়সূচি",  BusSchedule()),
                  _buildGridItem(context, 'assets/images/destination.png', "দর্শনীয় স্থান",  TouristSpots()),
                  _buildGridItem(context, 'assets/images/graduation-hat.png', "শিক্ষা প্রতিষ্ঠান",  EducationalInstitutes()),
                  _buildGridItem(context, 'assets/images/hotel.png', "হোটেল",  Hotel()),
                  _buildGridItem(context, 'assets/images/idea.png', "বিদ্যুৎ অফিস",  ElectricityOffice()),
                  _buildGridItem(context, 'assets/images/mosque.png', "মসজিদ",  Mosque()),
                  _buildGridItem(context, 'assets/images/police-station.png', "পুলিশ",  Police()),
                  _buildGridItem(context, 'assets/images/robot.png', "ফায়ার সার্ভিস",  FireService()),
                  // Add more items here...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated _buildGridItem with navigation
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
