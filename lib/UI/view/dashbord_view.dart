import 'package:finance_app/UI/Controller/deshbord_controller.dart';
import 'package:finance_app/UI/screen_assets/Size.dart';
import 'package:finance_app/UI/view/compont/card_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   
  @override
 
  Widget build(BuildContext context) {
 
  final DashboardController controller = Get.put(DashboardController());
     SizeConfig.init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: controller.changeFilter,
            itemBuilder: (context) => ['All', 'Astro', 'Finance']
                .map((e) => PopupMenuItem(value: e, child: Text(e)))
                .toList(),
          )
        ],
      ),
      body: Obx(() {
        final cards = controller.filteredCards;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => CardTile(data: cards[index]),
        );
      }),
    );
  }
}


 