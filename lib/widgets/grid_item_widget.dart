import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GridItemWidget extends StatelessWidget {
  final String image;
  final String title;

  const GridItemWidget({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle navigation or actions
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                image, // Local asset path
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10.0),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.tiroBangla(
                  textStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
