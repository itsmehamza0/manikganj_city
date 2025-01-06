import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Notice extends StatelessWidget {
  const Notice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('নোটিশ পেইজ'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notices')
              .orderBy('timestamp', descending: true) // Latest notice first
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'কোন নোটিশ পাওয়া যায়নি।',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              );
            }

            final noticeDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: noticeDocs.length,
              itemBuilder: (context, index) {
                final notice = noticeDocs[index];
                final timestamp = (notice['timestamp'] as Timestamp).toDate();
                final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);

                return NoticeCard(
                  title: notice['title'] ?? 'নাম পাওয়া যায়নি',
                  content: notice['content'] ?? 'তথ্য নেই',
                  date: formattedDate,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const NoticeCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.teal.shade50, // Light teal background color
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal.shade800, // Title color
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'তারিখ: $date',
              style: TextStyle(
                fontSize: 14,
                color: Colors.teal.shade400, // Date color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
