import 'package:hive_flutter/hive_flutter.dart';
import 'models/image.dart';

Future<List<Photo>> loadPhotosFromHive() async {
  final photoBox = await Hive.openBox<Photo>('photos');
  return photoBox.values.toList().reversed.toList();
}

Future<void> updatePhotoInHive(Photo photo, bool isUploaded) async {
  final photoBox = await Hive.openBox<Photo>('photos');
  final updatedPhoto = Photo(path: photo.path, isUploaded: isUploaded);
  await photoBox.putAt(photoBox.values.toList().indexOf(photo), updatedPhoto);
}