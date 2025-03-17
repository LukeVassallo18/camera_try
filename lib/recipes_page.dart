import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './models/recipe.dart';
import 'recipe_tile.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final List<Recipe> _recipes = [];

  Future _pickImage(int index) async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;

    setState(() {
      _recipes[index].imagePath = returnedImage.path;
    });
  }

  void _addRecipe(String name, String description) {
    setState(() {
      _recipes.add(Recipe(name: name, description: description));
    });
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
                  onPickImage: () => _pickImage(index),
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
