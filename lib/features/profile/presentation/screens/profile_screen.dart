import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('App Theme'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text('Export Quality'),
            trailing: Text('High (100%)'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About PhotoFrame'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
