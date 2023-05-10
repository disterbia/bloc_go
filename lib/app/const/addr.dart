
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Address{
  // static final String addr= "http://192.168.0.161:8080/";
  // static final String wsAddr= "ws://192.168.0.161:8080/";

  static final String addr= "http://ec2-3-39-226-206.ap-northeast-2.compute.amazonaws.com:8080/";
  static final String wsAddr= "ws://ec2-3-39-226-206.ap-northeast-2.compute.amazonaws.com:8080/";
  static final Color color =  Color(0xFF00D9E9);
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