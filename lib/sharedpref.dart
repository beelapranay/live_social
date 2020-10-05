import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  static String urlKey = "urlKey";

  static Future<bool> saveurl(String url) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(urlKey, url);
  }

  static Future<String> getUrl() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString(urlKey);
  }
}