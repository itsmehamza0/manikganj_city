import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool isDownloading = false;
  double progress = 0.0;
  String? downloadUrl;

  @override
  void initState() {
    super.initState();
    fetchDownloadLink();
  }

  /// Firestore থেকে ডাউনলোড লিংক ফেচ করে
  Future<void> fetchDownloadLink() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('updates')
          .doc('latest_update')
          .get();

      if (snapshot.exists) {
        setState(() {
          downloadUrl = snapshot.data()?['download_url'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("কোনো আপডেট লিংক পাওয়া যায়নি!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("লিংক আনতে সমস্যা হয়েছে! Error: $e")),
      );
    }
  }

  /// ডাউনলোড পরিচালনা করা
  Future<void> downloadFile() async {
    if (downloadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ডাউনলোড লিংক পাওয়া যায়নি!")),
      );
      return;
    }

    final dio = Dio();

    try {
      // স্টোরেজ পারমিশন চেক
      if (await Permission.storage.request().isGranted) {
        setState(() {
          isDownloading = true;
          progress = 0.0;
        });

        // Download ফোল্ডারে ফাইল সেভ করার লোকেশন
        final dir = Directory('/storage/emulated/0/Download');
        final savePath = "${dir.path}/update.apk"; // Save in Downloads folder

        // ফাইল ডাউনলোড
        await dio.download(
          downloadUrl!,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                progress = received / total;
              });
            }
          },
        );

        setState(() {
          isDownloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ডাউনলোড সফল হয়েছে! Saved to: $savePath")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("স্টোরেজ পারমিশন ডিনাই হয়েছে।")),
        );
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ডাউনলোডে সমস্যা হয়েছে! Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update App"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (downloadUrl == null)
                Text(
                  "আপডেট লিংক লোড হচ্ছে...",
                  style: TextStyle(fontSize: 16),
                ),
              if (downloadUrl != null)
                isDownloading
                    ? Column(
                  children: [
                    CircularProgressIndicator(value: progress),
                    SizedBox(height: 10),
                    Text("${(progress * 100).toStringAsFixed(0)}%"),
                  ],
                )
                    : Column(
                  children: [
                    Text(
                      "নতুন আপডেট ডাউনলোড করতে নিচের বাটনে ক্লিক করুন।",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: downloadFile,
                      child: Text("ডাউনলোড করুন"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
