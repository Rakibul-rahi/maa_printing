import 'package:flutter/material.dart';

class DailyProductionHishab extends StatelessWidget {
  const DailyProductionHishab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Production Hishab'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          'Daily Production Accounting',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new production record
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}