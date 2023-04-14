
import 'package:shared_preferences/shared_preferences.dart';

class Address{
  static final String addr= "http://192.168.0.88:8080/";
  static final String wsAddr= "ws://192.168.0.88:8080/";
 }


 class SharedPreferencesHelper {
   static const String _uid = 'uid';

   static Future<void> saveUserUid(String uid) async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.setString(_uid, uid);
   }

   static Future<String?> getUserUid() async {
     final prefs = await SharedPreferences.getInstance();
     return prefs.getString(_uid);
   }

   static Future<void> removeUserUid() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove(_uid);
   }
 }