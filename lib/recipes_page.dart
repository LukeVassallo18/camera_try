import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:http/http.dart' as http; // For HTTP requests
import './models/recipe.dart';
import 'recipe_tile.dart';
import 'package:permission_handler/permission_handler.dart'; // For Firebase initialization

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  // create a list of recipes
  final List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes(); // Fetch recipes from Firebase when the page loads
  }

  // Fetch recipes from Firebase Realtime Database
  Future<void> _fetchRecipes() async {
    var url = Uri.https(
        "recipekeeper-c9509-default-rtdb.europe-west1.firebasedatabase.app",
        "/recipes.json"); // Firebase Realtime Database URL

    try {
      final response = await http.get(url);
      // wait for positive repsonse from firebase
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data != null) {
          setState(() {
            _recipes.clear(); // Clear the list before adding new data
            data.forEach((id, recipeData) {
              _recipes.add(Recipe(
                id: id,
                name: recipeData['name'],
                description: recipeData['description'],
                imagePath: recipeData['imagePath'], // Load image path
              ));
            });
          });
        }
      } else {
        print('Failed to fetch recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }
  }

  // Save recipe to Firebase Realtime Database
  Future<void> _addRecipe(String name, String description) async {
    var url = Uri.https(
        "recipekeeper-c9509-default-rtdb.europe-west1.firebasedatabase.app",
        "/recipes.json"); // Firebase Realtime Database URL

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'imagePath': null, // Initially no image
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _recipes.add(Recipe(
            id: responseData['name'], // Firebase-generated unique ID
            name: name,
            description: description,
            imagePath: null,
          ));
        });
      } else {
        print('Failed to save recipe: ${response.statusCode}');
      }
    } catch (error) {
      print('Error saving recipe: $error');
    }
  }

  // Pick an image using the camera and update the recipe's image in Firebase
  Future<void> _pickImage(String recipeId, int index) async {
    // Request camera permission
    var status = await Permission.camera.request();

    if (status.isGranted) {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage == null) return;

      final imagePath = pickedImage.path;

      // Update the image path in Firebase
      var url = Uri.https(
          "recipekeeper-c9509-default-rtdb.europe-west1.firebasedatabase.app",
          "/recipes/$recipeId.json"); // Firebase Realtime Database URL

      try {
        final response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'imagePath': imagePath,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _recipes[index].imagePath = imagePath; // Update local list
          });
          print('Image updated successfully in Firebase.');
        } else {
          print('Failed to update image: ${response.statusCode}');
        }
      } catch (error) {
        print('Error updating image: $error');
      }
      // if request is denied, show a message
    } else if (status.isDenied) {
      print('Camera permission denied.');
    } else if (status.isPermanentlyDenied) {
      print(
          'Camera permission permanently denied. Please enable it in settings.');
    }
  }

  // Remove recipe from Firebase Realtime Database
  Future<void> _removeRecipe(String id) async {
    var url = Uri.https(
        "recipekeeper-c9509-default-rtdb.europe-west1.firebasedatabase.app",
        "/recipes/$id.json"); // Firebase Realtime Database URL

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Recipe removed successfully from Firebase.');
      } else {
        print('Failed to remove recipe: ${response.statusCode}');
      }
    } catch (error) {
      print('Error removing recipe: $error');
    }
  }

// add recipe form
  void _showAddRecipeDialog() {
    final formKey = GlobalKey<FormState>();
    String recipeName = '';
    String recipeDescription = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Recipe'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name',
                    icon: Icon(Icons.fastfood),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a recipe name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    recipeName = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    icon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    recipeDescription = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  _addRecipe(recipeName, recipeDescription);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

// main layout of page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes"),
      ),
      body: _recipes.isEmpty
          ? const Center(
              child: Text(
                'No recipes available',
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'Roboto',
                  color: Colors.black54,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                return Dismissible(
                  key: Key(recipe.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _removeRecipe(recipe.id); // Remove from Firebase
                    setState(() {
                      _recipes.removeAt(index); // Remove from local list
                    });
                  },
                  child: RecipeTile(
                    recipe: recipe,
                    onPickImage: () => _pickImage(recipe.id, index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecipeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
