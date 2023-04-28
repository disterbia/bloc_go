import 'package:DTalk/app/bloc/image_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadPage extends StatelessWidget {
  UploadPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed:()=> context.read<ImageBloc>().add(ImageUploadEvent()),
              child: Text('Select Image(s)'),
            ),
          ],
        ),
      ),
    );
  }
}