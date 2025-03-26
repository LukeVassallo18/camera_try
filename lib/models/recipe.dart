// recipe model for firebase and tile format
class Recipe {
  String id;
  String name;
  String description;
  String? imagePath;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
  });
}
