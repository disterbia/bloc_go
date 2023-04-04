
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInButton extends StatelessWidget {

  void signInWithApple() async {

  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 40, right: 40, top: 30),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final AuthorizationCredentialAppleID credential =
                  await SignInWithApple.getAppleIDCredential(
                    scopes: [
                      AppleIDAuthorizationScopes.email,
                      AppleIDAuthorizationScopes.fullName,
                    ],
                    webAuthenticationOptions: WebAuthenticationOptions(
                      clientId: "eatall.eatall.dmonster.com",
                      redirectUri: Uri.parse(
                        "https://flawless-gem-chestnut.glitch.me/callbacks/sign_in_with_apple",
                      ),
                    ),
                  );

                  print('credential.state = $credential');
                  print('credential.state = ${credential.email}');
                  print('credential.state = ${credential.userIdentifier}');
                  context.push("/video",extra: credential.userIdentifier);
                } catch (error) {
                  print('error = $error');
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 20),
                  SizedBox(width: 7),
                  Text(
                    'Continue with Apple',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}