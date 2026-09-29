import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class MealDbApi {
  static const String _base = 'https://www.themealdb.com/api/json/v1/1';

  /// ค้นหาอาหารด้วย keyword (เช่น "cake", "chicken")
  Future<List<RecipeSummary>> searchRecipes(String query) async {
    final uri = Uri.parse('$_base/search.php?s=${Uri.encodeComponent(query)}');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Search failed: ${res.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    final List<dynamic>? meals = data['meals'];

    if (meals == null) return [];
    return meals.map((e) => RecipeSummary.fromMealDb(e)).toList();
  }

  /// ดึงรายละเอียดสูตรด้วย id
  Future<RecipeDetail?> getDetail(String id) async {
    final uri = Uri.parse('$_base/lookup.php?i=${Uri.encodeComponent(id)}');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Detail failed: ${res.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    final List<dynamic>? meals = data['meals'];
    if (meals == null || meals.isEmpty) return null;

    return RecipeDetail.fromMealDb(meals.first);
  }
}
