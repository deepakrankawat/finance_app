import 'package:finance_app/UI/Controller/deshbord_controller.dart';
import 'package:finance_app/UI/view/dashbord_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() {
   WidgetsFlutterBinding.ensureInitialized();
   Get.put(DashboardController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced GetX UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),
      home: HomeScreen(),
    );
  }
}
