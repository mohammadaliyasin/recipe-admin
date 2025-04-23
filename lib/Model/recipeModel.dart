class RecipeModel {
  String title;
  String weight;
  String calories;
  List<String> ingredients;
  String description;
  String? imageUrl;

  RecipeModel({
    required this.title,
    required this.weight,
    required this.calories,
    required this.ingredients,
    required this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'weight': weight,
      'calories': calories,
      'ingredients': ingredients,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      title: map['title'],
      weight: map['weight'],
      calories: map['calories'],
      ingredients: List<String>.from(map['ingredients']),
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }
}
