import 'package:flutter/material.dart';
import 'package:manikganj_city/application/color.dart';
import 'package:manikganj_city/screens/drawer/update_page.dart';

import '../notice_screen.dart';
import 'about_developer.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.appMainColor, // Header background color
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'Manikganj City',
                  style: TextStyle(
                    color: AppColors.appWhiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Items
          ListTile(
            leading: Icon(Icons.home, color: AppColors.appMainColor),
            title: Text('Home', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Logout functionality
              Navigator.of(context).pop(); // Close the drawer

            },
          ),
          ListTile(
            leading: Icon(Icons.download, color: AppColors.appMainColor),
            title: Text('Update App', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdatePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: AppColors.appMainColor),
            title: Text('Notifications', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notice()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: AppColors.appMainColor),
            title: Text('About Developer', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutDeveloper()),
              );
            },
          ),

        ],
      ),
    );
  }
}
