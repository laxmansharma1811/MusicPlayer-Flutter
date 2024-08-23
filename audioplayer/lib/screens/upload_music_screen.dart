import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class UploadMusicScreen extends StatefulWidget {
  @override
  _UploadMusicScreenState createState() => _UploadMusicScreenState();
}

class _UploadMusicScreenState extends State<UploadMusicScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _artist = '';

  Future<void> _uploadMusic() async {
    if (_formKey.currentState!.validate()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        withData: true,
      );

      if (result != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.mp3';
        Reference storageRef = FirebaseStorage.instance.ref().child('music/$fileName');

        UploadTask uploadTask;
        if (result.files.single.bytes != null) {
          uploadTask = storageRef.putData(result.files.single.bytes!);
        } else {
          uploadTask = storageRef.putFile(File(result.files.single.path!));
        }

        await uploadTask.whenComplete(() async {
          String audioUrl = await storageRef.getDownloadURL();
          
          await FirebaseFirestore.instance.collection('music').add({
            'title': _title,
            'artist': _artist,
            'audioUrl': audioUrl,
            'uploadedBy': FirebaseAuth.instance.currentUser!.uid,
            'uploadedAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Music uploaded successfully')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              onChanged: (value) => setState(() => _title = value),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Artist'),
              validator: (value) => value!.isEmpty ? 'Enter an artist' : null,
              onChanged: (value) => setState(() => _artist = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Upload Music'),
              onPressed: _uploadMusic,
            ),
          ],
        ),
      ),
    );
  }
}