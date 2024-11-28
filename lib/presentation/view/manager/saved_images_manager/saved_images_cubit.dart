import 'package:camera_detection/presentation/view/manager/saved_images_manager/saved_images_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/firebase/firebase.dart';
import '../../../../data/local/hive.dart';
import '../../../../data/local/models/image.dart';

class SavedImagesCubit extends Cubit<SavedImagesState> {
  SavedImagesCubit() : super(SavedImagesInitial());

  Future<void> loadPhotos() async {
    emit(SavedImagesLoading());
    try {
      final photos = await loadPhotosFromHive();
      emit(SavedImagesLoaded(photos: photos));
    } catch (e) {
      emit(SavedImagesError(error: e.toString()));
    }
  }

  Future<void> uploadImage(BuildContext context, Photo photo) async {
    try {
      emit(SavedImagesUploading());
      final imageUrl = await uploadImageToFirebase(photo);

      await updatePhotoInHive(photo, true);

      emit(SavedImagesUploaded(imageUrl: imageUrl));
      loadPhotos();
    } catch (e) {
      emit(SavedImagesError(error: e.toString()));
    }
  }

  Future<void> deleteImage(BuildContext context, Photo photo) async {
    try {
      emit(SavedImagesDeleting());
      await deleteImageFromFirebase(photo);

      await updatePhotoInHive(photo, false);
      loadPhotos();
    } catch (e) {
      emit(SavedImagesError(error: e.toString()));
    }
  }
}