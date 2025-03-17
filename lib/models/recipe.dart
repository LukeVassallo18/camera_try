class Recipe {
  String name;
  String description;
  String? imagePath;

  Recipe({
    required this.name,
    required this.description,
    this.imagePath,
  });
}
