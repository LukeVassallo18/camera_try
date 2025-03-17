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
    return Container(
      color: Colors.orange[50],
      padding: const EdgeInsets.symmetric(
          vertical: 10.0), // Increase vertical padding
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 16.0), // Increase content padding
            title: Text(
              widget.recipe.name,
              style: const TextStyle(
                fontSize: 20.0, // Increase font size
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Use a different font family
              ),
            ),
            leading: widget.recipe.imagePath != null
                ? Image.file(
                    File(widget.recipe.imagePath!),
                    width: 50.0, // Increase image width
                    height: 50.0, // Increase image height
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image,
                    size: 50.0,
                    color:
                        Colors.orange), // Increase icon size and change color
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.orange),
                  onPressed: widget.onPickImage,
                ),
                IconButton(
                  icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.orange),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                widget.recipe.description,
                style: const TextStyle(
                  fontSize: 16.0, // Increase font size
                  fontFamily: 'Roboto', // Use a different font family
                  color: Colors.black87, // Ensure good color contrast
                ),
              ),
            ),
        ],
      ),
    );
  }
}
