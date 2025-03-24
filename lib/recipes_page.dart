import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import './models/recipe.dart';
import 'recipe_tile.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
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

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data != null) {
          setState(() {
            _recipes.clear(); // Clear the list before adding new data
            data.forEach((id, recipeData) {
              _recipes.add(Recipe(
                name: recipeData['name'],
                description: recipeData['description'],
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
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _recipes.add(Recipe(
            name: name,
            description: description,
          ));
        });
      } else {
        print('Failed to save recipe: ${response.statusCode}');
      }
    } catch (error) {
      print('Error saving recipe: $error');
    }
  }

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
                return RecipeTile(
                  recipe: _recipes[index],
                  onPickImage: () {
                    // Add your logic for picking an image here
                    print(
                        'Image picker triggered for recipe: ${_recipes[index].name}');
                  },
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
