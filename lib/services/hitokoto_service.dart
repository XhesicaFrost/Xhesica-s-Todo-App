import 'package:http/http.dart' as http;

class HitokotoService {
  static const String _apiUrl =
      'https://v1.hitokoto.cn/?c=a&c=b&c=c&c=d&c=h&c=i&c=k&encode=text';

  /// 获取一言文本
  /// 返回获取到的文本，或者在失败时返回默认文本
  static Future<String> fetchHitokoto() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Wiki is the cutest neko.";
      }
    } catch (e) {
      return "Xhesica says hello to you.";
    }
  }
}
