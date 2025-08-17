

import 'package:finance_app/view/ProfileScreen.dart';
import 'package:finance_app/view/home_view.dart';
import 'package:finance_app/view/lock_create_view.dart' show CreatePinScreen;
import 'package:finance_app/view/lock_view.dart';
import 'package:finance_app/view/login_view.dart';

import 'package:finance_app/view/otp_screen.dart';
import 'package:finance_app/view/phone_number_auth.dart';
import 'package:finance_app/view/signup_view.dart';
import 'package:finance_app/view/splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:get/route_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',

      // 🌟 Main Home Logic: Fully Reactive
      home: const SplashScreen(),

      // Optional: App routes
      getPages: [
        GetPage(name: '/login', page: () =>  LoginView()),
        GetPage(name: '/signup', page: () => SignupView()),
        GetPage(name: '/home', page: () =>  HomeView()),
        GetPage(name: '/phone', page: () => PhoneLoginView()),
        GetPage(name: '/otp', page: () => OtpView()),
        GetPage(name: '/profile', page: () =>  Profileview()),
        GetPage(name: '/lock', page: () =>  LockScreen()),
        GetPage(name: '/create-lock', page: () => CreatePinScreen()),
       
    
       
        
      ],
    );
  }
}
