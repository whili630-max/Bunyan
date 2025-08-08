import 'package:flutter/material.dart';

void main() {
  runApp(const ClientApp());
}

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bunyan Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ClientHomePage(title: 'Bunyan Client Portal'),
    );
  }
}

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: const Text('Welcome to Bunyan Client Portal'),
      ),
    );
  }
}
