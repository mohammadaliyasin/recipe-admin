import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_admin/controller/recipeController.dart';
import 'package:recipe_admin/main.dart';
import 'package:recipe_admin/screen/Add%20Recipe.dart';

import '../Model/recipeModel.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final RecipeController _recipeController = RecipeController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff11151E),
      appBar: AppBar(
        backgroundColor: const Color(0xff11151E),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Recipe',
          style: GoogleFonts.outfit(
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<RecipeModel>>(
          stream: _recipeController.getRecipes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No recipes found.'));
            }

            final recipes = snapshot.data!;

            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return recipeCard(context, recipe);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipe(),
            ),
          );
        },
        backgroundColor: const Color(0xffd6fc51),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget recipeCard(BuildContext context, RecipeModel recipe) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xff11151E),
              title: Text(
                recipe.title,
                style: GoogleFonts.outfit(
                  color: const Color(0xffd6fc51),
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'Are you sure you want to delete this recipe?',
                style: GoogleFonts.outfit(
                  color: const Color(0xffffffff),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(
                      color: const Color(0xffffffff),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await _recipeController.deleteRecipe(recipe);
                      Fluttertoast.showToast(
                        msg: "Recipe deleted successfully",
                        backgroundColor: const Color(0xff11151E),
                        textColor: Colors.white,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "Failed to delete recipe: $e",
                        backgroundColor: const Color(0xff11151E),
                        textColor: Colors.white,
                      );
                    }
                  },
                  child: Text(
                    'Remove',
                    style: GoogleFonts.outfit(
                      color: Colors.red,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        height: 130.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 211, 211, 218),
          borderRadius: BorderRadius.circular(6.r),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
        ),
        child: Card(
          color: const Color(0xff171D2B),
          child: Row(
            children: [
              SizedBox(width: 10.w),
              CircleAvatar(
                backgroundImage: recipe.imageUrl != null ? NetworkImage(recipe.imageUrl!) : null,
                radius: 55.r,
                backgroundColor: const Color.fromARGB(255, 99, 101, 114),
                child: recipe.imageUrl == null
                    ? const Icon(Icons.image,
                        color:
                            Colors.white)
                    : null,
              ),
              SizedBox(width: 20.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      Text(
                        '${recipe.weight} g',
                        style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xffd6fc51)),
                      ),
                      SizedBox(width: 20.h),
                      Text(
                        '${recipe.calories} cal',
                        style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xffd6fc51)),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    recipe.title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xffECEDEE)),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    recipe.description,
                    style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff777A82)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
