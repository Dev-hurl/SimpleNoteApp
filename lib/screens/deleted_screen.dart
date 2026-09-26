import 'package:flutter/material.dart';

class DeletedScreen extends StatelessWidget {
  const DeletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      body: Center(child: Text('Deleted Screen')),
    );
  }
}
