import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Model/recipeModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class RecipeController {
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImageToFirebase(String path, Uint8List imageData) async {
    try {
      print('Starting image upload...');
      // Create a reference to Firebase Storage
      Reference storageRef = _storage.ref().child(path);
      print('Storage reference created: $storageRef');

      // Upload the image data
      UploadTask uploadTask = storageRef.putData(imageData);
      print('Upload task started');

      // Wait until the upload is complete
      TaskSnapshot snapshot = await uploadTask;
      print('Upload task completed');

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> addRecipe(RecipeModel recipe, Uint8List? file) async {
    try {
      print('Adding recipe to Firestore...');

      String? imageUrl;
      if (file != null) {
        imageUrl = await uploadImageToFirebase(
            'images/${DateTime.now().millisecondsSinceEpoch}', file);
        print('Image uploaded successfully: $imageUrl');
      }

      await _recipeCollection.add({
        'title': recipe.title,
        'weight': recipe.weight,
        'calories': recipe.calories,
        'ingredients': recipe.ingredients,
        'description': recipe.description,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Recipe added successfully');
    } catch (e) {
      print('Failed to add recipe: $e');
      rethrow;
    }
  }

  // Stream to retrieve recipes
  Stream<List<RecipeModel>> getRecipes() {
    return _recipeCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return RecipeModel(
          title: data['title'] ?? '',
          weight: data['weight'] ?? '',
          calories: data['calories'] ?? '',
          ingredients: List<String>.from(data['ingredients'] ?? []),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'],
        );
      }).toList();
    });
  }

  // Method to find and delete recipe based on attributes (alternative to using docId)
  Future<void> deleteRecipe(RecipeModel recipe) async {
    try {
      // Query recipe to get document
      QuerySnapshot querySnapshot = await _recipeCollection
          .where('title', isEqualTo: recipe.title)
          .where('weight', isEqualTo: recipe.weight)
          .where('calories', isEqualTo: recipe.calories)
          .where('description', isEqualTo: recipe.description)
          .where('imageUrl', isEqualTo: recipe.imageUrl)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          // Delete image from Firebase Storage if exists
          if (recipe.imageUrl != null) {
            await FirebaseStorage.instance
                .refFromURL(recipe.imageUrl!.toString())
                .delete();
            print('Image deleted from storage');
          }
          // Delete recipe document
          await doc.reference.delete();
        }
        print('Recipe and image deleted successfully');
      } else {
        print('No matching recipe found to delete');
      }
    } catch (e) {
      print('Failed to delete recipe: $e');
      rethrow;
    }
  }
}
