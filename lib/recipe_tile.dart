import 'dart:io';

import 'package:flutter/material.dart';
import './models/recipe.dart';

class RecipeTile extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onPickImage;

  const RecipeTile(
      {super.key, required this.recipe, required this.onPickImage});

  @override
  _RecipeTileState createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4, // Add shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Add border radius
          side:
              const BorderSide(color: Colors.orange, width: 2.0), // Add border
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                title: Text(
                  widget.recipe.name,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                leading: widget.recipe.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                            8.0), // Add border radius to the image
                        child: Image.file(
                          File(widget.recipe.imagePath!),
                          width: 50.0,
                          height: 50.0,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 50.0, color: Colors.orange),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: IconButton(
                        icon:
                            const Icon(Icons.camera_alt, color: Colors.orange),
                        onPressed: widget.onPickImage,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Flexible(
                      child: IconButton(
                        icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.orange),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    widget.recipe.description,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
