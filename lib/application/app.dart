import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manikganj_city/application/theme.dart';
import 'package:manikganj_city/screens/home_screen.dart';


class ManikganjCity extends StatelessWidget {
  const ManikganjCity({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: Themes().lightTheme,
      home: HomeScreen(),
    );
  }
}
