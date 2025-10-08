import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header Text
                const Text(
                  'Flutter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                // Image + Play Button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: 150,
                      height: 150,
                      child: Image.network(
                        'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.play_arrow,
                        size: 36,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title and description
                const Text(
                  'Flutter Complete Course',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Created by Dear Programmer',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                const Text(
                  '55 Videos',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // Buttons Videos / Description
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Videos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Description'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // List of videos
                Expanded(
                  child: ListView(
                    children: const [
                      VideoListItem(
                          title: 'Introduction to Flutter',
                          duration: '20 min 50 sec'),
                      VideoListItem(
                          title: 'Installing Flutter on Windows',
                          duration: '20 min 50 sec'),
                      VideoListItem(
                          title: 'Setup Emulator on Windows',
                          duration: '20 min 50 sec'),
                      VideoListItem(
                          title: 'Creating Our First App',
                          duration: '20 min 50 sec'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoListItem extends StatelessWidget {
  final String title;
  final String duration;

  const VideoListItem({super.key, required this.title, required this.duration});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.play_arrow, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text(duration),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }
}
