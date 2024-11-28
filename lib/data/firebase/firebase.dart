import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../local/models/image.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';


final firestore = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instance.ref();
Future<String> uploadImageToFirebase(Photo photo) async {

  final imageId = const Uuid().v4();

  final uploadTask = storageRef.child("images/$imageId.jpg").putFile(File(photo.path));
  final snapshot = await uploadTask;
  final imageUrl = await snapshot.ref.getDownloadURL();

  await firestore.collection("images").add({
    "timestamp": DateTime.now(),
    "url": imageUrl,
  });

  return imageUrl;
}

Future<void> deleteImageFromFirebase(Photo photo) async {
  final querySnapshot = await firestore.collection("images").get();
  for (var doc in querySnapshot.docs) {
    if (doc["url"] == photo.path) {
      await doc.reference.delete();
      break;
    }
  }
}