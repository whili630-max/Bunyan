import 'package:flutter/material.dart';

void main() {
  runApp(const SelectorPage());
}

class SelectorPage extends StatelessWidget {
  const SelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bunyan Selector',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SelectorHomePage(title: 'Bunyan - Select Mode'),
    );
  }
}

class SelectorHomePage extends StatelessWidget {
  const SelectorHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to client mode
              },
              child: const Text('Client Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to admin mode
              },
              child: const Text('Admin Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
