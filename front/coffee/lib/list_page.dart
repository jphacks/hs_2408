import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog List'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('name 1'),
            subtitle: Text('age 1'),
          ),
          ListTile(
            title: Text('name 2'),
            subtitle: Text('age 2'),
          ),
          ListTile(
            title: Text('name 3'),
            subtitle: Text('age 3'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
