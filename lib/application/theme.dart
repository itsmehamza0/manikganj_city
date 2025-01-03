import 'package:flutter/material.dart';
import 'package:manikganj_city/application/color.dart';

class Themes{
  final lightTheme = ThemeData.light().copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appMainColor,
      foregroundColor: Colors.white,
    )
  );

}