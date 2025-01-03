import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manikganj_city/application/color.dart';
import 'package:text_scroll/text_scroll.dart';
import '../widgets/grid_item_widget.dart';
import '../widgets/carousel_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of online image URLs
    List<String> images = [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSifk84PNoLETKdAEqML0UQWI1Y6reGrJd1ug&s',
      // Replace with your online image URLs
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
                  child: Text("Drawer Header",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                  )),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Add the ImageCarousel widget here, passing the list of online image URLs
            ImageCarousel(imageUrls: images),
            // Carousel widget
            SizedBox(height: 10),

            // Text Scroll code
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10), // TextScroll-এর চারপাশে প্যাডিং
              decoration: BoxDecoration(
                gradient: LinearGradient( // সুন্দর গ্রেডিয়েন্ট ব্যাকগ্রাউন্ড
                  colors: [
                    Colors.blue.shade100,  // হালকা নীল ব্যাকগ্রাউন্ড
                    Colors.blue.shade200, // হালকা নীল
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10), // কোণের গোলাকারতা
              ),
              child: TextScroll(
                velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                'জীবের মধ্যে সবচেয়ে সম্পূর্ণতা মানুষের। কিন্তু সবচেয়ে অসম্পূর্ণ হয়ে সে জন্মগ্রহণ করে। বাঘ ভালুক তার জীবনযাত্রার পনেরো- আনা মূলধন নিয়ে আসে প্রকৃতির মালখানা থেকে। জীবরঙ্গভূমিতে মানুষ এসে দেখা দেয় দুই শূন্য হাতে মুঠো বেঁধে।',
                style: GoogleFonts.notoSerifBengali(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black, // টেক্সট রঙ সাদা
                ),
              ),
            ),



            SizedBox(height: 10),
            // GridView to display the items in a grid
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns in the grid
                  crossAxisSpacing: 16.0, // Horizontal spacing between items
                  mainAxisSpacing: 16.0, // Vertical spacing between items
                ),
                children: [
                  _buildGridItem('assets/images/doctor.png', "ডাক্তার"),
                  _buildGridItem('assets/images/hospital.png', "হাসপাতাল"),
                  _buildGridItem('assets/images/bus.png', "বাসের সময়সূচী"),
                  _buildGridItem('assets/images/blood-test.png', "রক্ত"),
                  _buildGridItem('assets/images/hotel.png', "হোটেল"),
                  _buildGridItem('assets/images/policeman.png', "পুলিশ"),
                  _buildGridItem('assets/images/robot.png', "ফায়ার সার্ভিস"),
                  _buildGridItem('assets/images/trolley.png', "শপিং"),
                  _buildGridItem('assets/images/idea.png', "বিদ্যুৎ অফিস"),
                  _buildGridItem('assets/images/destination.png', "দর্শনীয় স্থান"),
                  _buildGridItem('assets/images/mosque.png', "মাদরাসা"),
                  _buildGridItem('assets/images/graduation-hat.png', "কলেজ"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build each grid item (image + title)
  Widget _buildGridItem(String image, String title) {
    return GridItemWidget(
        image: image, title: title); // Pass imageUrl instead of icon
  }
}
