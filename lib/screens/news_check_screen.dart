import 'package:fake_news_football/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NewsCheckScreen extends StatefulWidget {
  const NewsCheckScreen({super.key});

  @override
  _NewsCheckScreenState createState() => _NewsCheckScreenState();
}

class _NewsCheckScreenState extends State<NewsCheckScreen> {
  TextEditingController promptController = TextEditingController();
  String response = '';
  bool isLoading = false;

  Future<void> sendPrompt(String prompt) async {
    setState(() {
      isLoading = true;
    });

    if (await InternetConnection().hasInternetAccess) {
      const url = serverURL;

      try {
        String formattedPrompt = prompt;

        // Check if the prompt contains "today" or "yesterday"
        if (prompt.toLowerCase().contains('today') || prompt.toLowerCase().contains('yesterday')) {
          // Extract the exact date (you may need to enhance this logic based on your specific use case)
          final currentDate = DateTime.now();
          final formattedDate = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
          formattedPrompt = formattedPrompt.replaceAll(RegExp(r'\b(today|yesterday)\b', caseSensitive: false), formattedDate);
        }

        // Add a full stop and the additional phrase to the formatted prompt
        formattedPrompt += '. Is it True or False?';

        final http.Response httpResponse = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'prompt': formattedPrompt}),
        );

        if (httpResponse.statusCode == 200) {
          final Map<String, dynamic> decodedResponse = jsonDecode(httpResponse.body);
          final String generatedText = decodedResponse['generatedText'];

          setState(() {
            this.response = generatedText;
          });
        } else if (httpResponse.statusCode == 404) {
          setState(() {
            this.response = 'Error 404: Resource not found';
          });
        } else {
          setState(() {
            this.response = 'Error: ${httpResponse.reasonPhrase}';
          });
        }
      } catch (error) {
        setState(() {
          this.response = 'Error: $error';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
        this.response = 'No internet connection';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Fake News Detector', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_image.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(controller: promptController),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    sendPrompt(promptController.text);
                  },
                  child: const Text('Ask Question'),
                ),
                const SizedBox(height: 16),
                Text('Response:', style: TextStyle(color: Colors.white)),
                isLoading
                    ? Image.asset(
                  'assets/images/bouncing_ball.gif',
                  width: 100,
                  height: 100,
                )
                    : response.contains('Error 404')
                    ? Image.asset(
                  'assets/images/error_404.jpg',
                  width: 100,
                  height: 100,
                )
                    : Text(response, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;

  const CustomTextField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'Enter your question', labelStyle: TextStyle(color: Colors.white)),
    );
  }
}

