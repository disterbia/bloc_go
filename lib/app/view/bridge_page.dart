import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BridgePage extends StatelessWidget {
  const BridgePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero,()=>context.pop());
    return Center(child: CircularProgressIndicator(),);
  }
}
