import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:recipe_admin/controller/recipeController.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Model/recipeModel.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  TextEditingController titleController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<String> ingredients = [];
  Uint8List? _image;
  final RecipeController _recipeController = RecipeController();

  // Image Picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = await pickedFile.readAsBytes();
      setState(() {
        _image!;
      });
    }
  }

  void _addIngredient() {
    if (ingredientsController.text.isNotEmpty) {
      setState(() {
        ingredients.add(ingredientsController.text);
        ingredientsController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      ingredients.remove(ingredient);
    });
  }

  // Upload Recipe
  Future<void> _uploadRecipe() async {
    if (_image == null || titleController.text.isEmpty || ingredients.isEmpty) {
      print("Please complete all fields");
      return;
    }

    try {
      print('Starting recipe upload...');
      RecipeModel recipe = RecipeModel(
        title: titleController.text,
        weight: weightController.text,
        calories: caloriesController.text,
        ingredients: ingredients,
        description: descriptionController.text,
      );

      String? imageUrl;
      if (_image != null) {
        Uint8List imageBytes = _image!;
        imageUrl = await _recipeController.uploadImageToFirebase(
            'images/${DateTime.now().millisecondsSinceEpoch}.png', imageBytes);
      }

      print('Recipe data: ${recipe.toMap()}');
      await _recipeController.addRecipe(recipe, _image!);

      print("Recipe uploaded successfully");

      // Clear fields after successful upload

      titleController.clear();
      weightController.clear();
      caloriesController.clear();
      ingredients.clear();
      descriptionController.clear();
      setState(() {
        _image = null;
      });

      print('Recipe upload completed.');
    } catch (e) {
      print('Error uploading recipe: $e');
      print("Failed to upload recipe: $e");
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    weightController.dispose();
    caloriesController.dispose();
    ingredientsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff11151E),
      appBar: AppBar(
        backgroundColor: const Color(0xff11151E),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Add Recipe',
          style: GoogleFonts.outfit(
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _uploadRecipe,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                const Color(0xffd6fc51),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.outfit(
                color: const Color(0xff11151E),
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(width: 15.w),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: const Color.fromARGB(255, 25, 29, 39),
              ),
              child: TextField(
                controller: titleController,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xffFFFFFF),
                ),
                decoration: InputDecoration(
                  hintText: 'Recipe title...',
                  hintStyle: const TextStyle(
                    color: Color(0xff8F8F93),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8.0.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Row(
              children: [
                _buildTextField(weightController, 'Weight...'),
                SizedBox(width: 10.w),
                _buildTextField(caloriesController, 'Calories...'),
              ],
            ),
          ),
          _buildIngredientField(),
          _buildIngredientChips(),
          _buildImagePicker(),
          SizedBox(height: 15.h,),
          _buildDescriptionField(),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Container(
      width: 165.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: const Color.fromARGB(255, 25, 29, 39),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: TextStyle(
          fontSize: 16.sp,
          color: const Color(0xffFFFFFF),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xff8F8F93),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8.0.r),
        ),
      ),
    );
  }

  Widget _buildIngredientField() {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: const Color.fromARGB(255, 25, 29, 39),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: ingredientsController,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xffFFFFFF),
                ),
                decoration: InputDecoration(
                  hintText: 'Ingredients...',
                  hintStyle: const TextStyle(
                    color: Color(0xff8F8F93),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8.0.r),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xffd6fc51)),
              onPressed: _addIngredient,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientChips() {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: ingredients.map((ingredient) {
          return Chip(
            label: Text(ingredient, style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xff171D2B),
            deleteIcon: const Icon(Icons.close, color: Colors.white),
            onDeleted: () => _removeIngredient(ingredient),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 60.r,
        backgroundColor: const Color.fromARGB(255, 25, 29, 39),
        backgroundImage: _image != null ? MemoryImage(_image!) : null,
        child: _image == null
            ? Center(
                child: Text(
                  'Add Image',
                  style: GoogleFonts.outfit(
                    color: const Color(0xff8F8F93),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: EdgeInsets.all(8.0.r),
      child: Container(
        height: 300.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: const Color.fromARGB(255, 25, 29, 39),
        ),
        child: SingleChildScrollView(
          child: TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Description...',
              hintStyle: const TextStyle(
                color: Color(0xff8F8F93),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(8.0.r),
            ),
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
