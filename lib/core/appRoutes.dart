// lib/app_routes.dart
import 'package:firstapp/bleScanPage.dart';
import 'package:flutter/material.dart';
import '../page2.dart';

Route<dynamic>? onGenerateRoutes(RouteSettings route){

  switch(route.name){
    case '/':
      return MaterialPageRoute(builder: (context) => const BleScanPage());
    // case '/page2':
    //   return MaterialPageRoute(builder: (context) => const page2());
    default:
      return MaterialPageRoute(builder: (_)=> Scaffold(body: Center(child: Text("No route found ${route.name}"),),));
  }



}