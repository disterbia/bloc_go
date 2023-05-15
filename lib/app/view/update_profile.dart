import 'package:DTalk/app/bloc/mypage_bloc.dart';
import 'package:DTalk/app/const/addr.dart';
import 'package:DTalk/app/repository/user_profile_repository.dart';
import 'package:DTalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
class UpdateProfileScreen extends StatefulWidget {
  String nickname;
  String intro;
  UpdateProfileScreen(this.nickname,this.intro);
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final UserService _userService = UserService();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _introductionController = TextEditingController();

  @override
  void initState() {
    _nicknameController.text=widget.nickname;
    _introductionController.text=widget.intro;
    super.initState();
  }
  @override
  void dispose() {
    _nicknameController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  void _updateUser() async {
    bool result=await _userService.updateUser(
      UserID.uid!,
      _nicknameController.text,
      _introductionController.text,
    );
    if(result){
      context.read<MyPageBloc>().add(GetMyPageEvent(userId: UserID.uid!));
      context.pop();
    }else {
      context.pop();
    }
    // Redirect to another screen or show a success message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                focusedBorder:OutlineInputBorder(
                  borderSide:  BorderSide(color: Address.color, width: 2.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _introductionController,
              decoration: InputDecoration(
                labelText: '자기소개',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                focusedBorder:OutlineInputBorder(
                  borderSide:  BorderSide(color: Address.color, width: 2.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              maxLines: 2,
              maxLength: 40,
            ),
            SizedBox(height: 16),
            ElevatedButton( style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Address.color),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    )
                )),
              onPressed: _updateUser,
              child: Text('수정완료'),
            ),
          ],
        ),
      ),
    );
  }
}
