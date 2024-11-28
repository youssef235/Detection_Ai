import '../../../../data/local/models/image.dart';

abstract class SavedImagesState {
  const SavedImagesState();
}

class SavedImagesInitial extends SavedImagesState {}

class SavedImagesLoading extends SavedImagesState {}

class SavedImagesLoaded extends SavedImagesState {
  final List<Photo> photos;

  const SavedImagesLoaded({required this.photos});
}

class SavedImagesUploaded extends SavedImagesState {
  final String imageUrl;

  const SavedImagesUploaded({required this.imageUrl});
}

class SavedImagesError extends SavedImagesState {
  final String error;

  const SavedImagesError({required this.error});
}

class SavedImagesUploading extends SavedImagesState {}

class SavedImagesDeleting extends SavedImagesState {}
