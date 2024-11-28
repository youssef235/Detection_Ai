import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../manager/saved_images_manager/saved_images_cubit.dart';
import '../manager/saved_images_manager/saved_images_state.dart';

class SavedImagesScreen extends StatelessWidget {
  const SavedImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedImagesCubit>().loadPhotos();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Images"),
      ),
      body: BlocListener<SavedImagesCubit, SavedImagesState>(
        listener: (context, state) {
          if (state is SavedImagesUploading || state is SavedImagesDeleting) {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(child: CircularProgressIndicator());
              },
            );
          } else {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
        child: BlocBuilder<SavedImagesCubit, SavedImagesState>(
          builder: (context, state) {
            if (state is SavedImagesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SavedImagesError) {
              return Center(child: Text(state.error));
            } else if (state is SavedImagesLoaded) {
              if (state.photos.isEmpty) {
                return const Center(child: Text("No images found."));
              }

              return ListView.builder(
                itemCount: state.photos.length,
                itemBuilder: (context, index) {
                  final photo = state.photos[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 30, // Makes the image round
                          backgroundImage: FileImage(File(photo.path)),
                        ),
                        title: Text(
                          "Image #${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              photo.isUploaded ? "Uploaded" : "Not Uploaded",
                              style: TextStyle(
                                color: photo.isUploaded
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (photo.isUploaded) {
                                  await context.read<SavedImagesCubit>().deleteImage(context, photo);
                                } else {
                                  await context.read<SavedImagesCubit>().uploadImage(context, photo);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: photo.isUploaded
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              child: Text(
                                photo.isUploaded ? "Delete" : "Upload",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
