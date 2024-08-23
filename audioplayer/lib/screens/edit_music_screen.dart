import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMusicScreen extends StatefulWidget {
  final DocumentSnapshot musicDoc;

  EditMusicScreen({required this.musicDoc});

  @override
  _EditMusicScreenState createState() => _EditMusicScreenState();
}

class _EditMusicScreenState extends State<EditMusicScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _artist;

  @override
  void initState() {
    super.initState();
    _title = widget.musicDoc['title'];
    _artist = widget.musicDoc['artist'];
  }

  Future<void> _updateMusic() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('music')
          .doc(widget.musicDoc.id)
          .update({
        'title': _title,
        'artist': _artist,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Music')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                onChanged: (value) => setState(() => _title = value),
              ),
              TextFormField(
                initialValue: _artist,
                decoration: InputDecoration(labelText: 'Artist'),
                validator: (value) => value!.isEmpty ? 'Enter an artist' : null,
                onChanged: (value) => setState(() => _artist = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Update Music'),
                onPressed: _updateMusic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}