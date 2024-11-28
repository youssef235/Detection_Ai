import 'package:hive/hive.dart';

part 'image.g.dart';

@HiveType(typeId: 0)
class Photo {
  @HiveField(0)
  final String path;
  @HiveField(1)
  final bool isUploaded;

  Photo({required this.path, this.isUploaded = false});
}
