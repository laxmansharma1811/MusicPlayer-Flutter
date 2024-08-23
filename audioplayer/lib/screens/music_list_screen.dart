import 'package:audioplayer/screens/edit_music_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MusicListScreen extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('music').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snapshot.data!.docs[index];
            bool isOwner = doc['uploadedBy'] == currentUserId;

            return ListTile(
              title: Text(doc['title']),
              subtitle: Text(doc['artist']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () async {
                      await audioPlayer.setUrl(doc['audioUrl']);
                      audioPlayer.play();
                    },
                  ),
                  if (isOwner) ...[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMusicScreen(musicDoc: doc),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteMusic(context, doc),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMusic(BuildContext context, DocumentSnapshot doc) async {
    try {
      // Delete the Firestore document
      await FirebaseFirestore.instance.collection('music').doc(doc.id).delete();

      // Delete the audio file from Storage
      String filePath = doc['audioPath'];
      await FirebaseStorage.instance.ref(filePath).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Music deleted successfully')),
      );
    } catch (e) {
      print('Error deleting music: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting music')),
      );
    }
  }
}