import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/category/category_model.dart';

abstract class MockCategoriesRepository {
  Future<List<CategoryModel>> fetchAll();
}

class McokCategoriesRepositoryImpl implements MockCategoriesRepository {
  final _baseUrl = 'https://shmr-finance.ru/api';

  @override
  Future<List<CategoryModel>> fetchAll() async {
    final url = Uri.parse('$_baseUrl/categories');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить категории');
    }
  }
}
