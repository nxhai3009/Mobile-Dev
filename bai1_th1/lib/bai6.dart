import 'package:flutter/material.dart';

void main() {
  runApp(const RichTextApp());
}

class RichTextApp extends StatelessWidget {
  const RichTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RichText Demo',
      debugShowCheckedModeBanner: false,
      home: const RichTextPage(),
    );
  }
}

class RichTextPage extends StatelessWidget {
  const RichTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RichText"), backgroundColor: Colors.blue,),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hello World
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                      text: "Hello ",
                      style: TextStyle(fontSize: 24, color: Colors.green)),
                  TextSpan(
                      text: "World",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Hello World + Emoji
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Hello ",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  TextSpan(
                    text: "World ",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  TextSpan(
                    text: "👋",
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contact me via: Email
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(text: "Contact me via: "),
                  WidgetSpan(
                    child: Icon(Icons.email, color: Colors.blue, size: 18),
                  ),
                  TextSpan(
                    text: " Email",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Call me: phone
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: "Call Me: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "+1234987654321",
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Read my blog
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: "Read My Blog ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "HERE",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
