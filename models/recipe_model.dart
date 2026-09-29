class RecipeSummary {
  final String id;
  final String title;
  final String image;

  RecipeSummary({
    required this.id,
    required this.title,
    required this.image,
  });

  factory RecipeSummary.fromMealDb(Map<String, dynamic> json) {
    return RecipeSummary(
      id: (json['idMeal'] ?? '').toString(),
      title: (json['strMeal'] ?? '').toString(),
      image: (json['strMealThumb'] ?? '').toString(),
    );
  }
}

class RecipeDetail {
  final String id;
  final String title;
  final String image;
  final String instructions;
  final List<String> ingredients; // "ingredient - measure"
  final String category;
  final String area;

  RecipeDetail({
    required this.id,
    required this.title,
    required this.image,
    required this.instructions,
    required this.ingredients,
    required this.category,
    required this.area,
  });

  factory RecipeDetail.fromMealDb(Map<String, dynamic> json) {
    // TheMealDB: ingredient 1..20, measure 1..20
    final List<String> items = [];
    for (int i = 1; i <= 20; i++) {
      final ing = (json['strIngredient$i'] ?? '').toString().trim();
      final mea = (json['strMeasure$i'] ?? '').toString().trim();
      if (ing.isNotEmpty) {
        final line = mea.isNotEmpty ? '$ing - $mea' : ing;
        items.add(line);
      }
    }

    return RecipeDetail(
      id: (json['idMeal'] ?? '').toString(),
      title: (json['strMeal'] ?? '').toString(),
      image: (json['strMealThumb'] ?? '').toString(),
      instructions: (json['strInstructions'] ?? '').toString(),
      ingredients: items,
      category: (json['strCategory'] ?? '').toString(),
      area: (json['strArea'] ?? '').toString(),
    );
  }
}
