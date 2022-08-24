import 'package:shared_preferences/shared_preferences.dart';

Future<bool> getTheme() async {
  late bool theme;
  var key = 'theme';
  SharedPreferences pref = await SharedPreferences.getInstance();
  theme = (pref.getBool(key) ?? false);
  return theme;
}