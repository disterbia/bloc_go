// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class GoogleSignInButton extends StatelessWidget {
//   final ValueSetter<String> onSignIn;
//
//   final _googleSignIn = GoogleSignIn(
//     scopes: [
//       'email',
//       'https://www.googleapis.com/auth/userinfo.profile',
//     ],
//   );
//
//   GoogleSignInButton({required this.onSignIn});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
//             child: ElevatedButton(
//               onPressed: () async {
//                 try {
//                   var account = await _googleSignIn.signIn();
//
//                   if (account != null) {
//                     var auth = await account.authentication;
//
//                     if (auth.idToken != null) {
//                       onSignIn(auth.idToken!);
//                     }
//                   }
//                 } catch (error) {
//                   print(error);
//                 }
//               },
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(width: 7),
//                   Text(
//                     'Continue with Google',
//                     style: TextStyle(fontSize:16, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }