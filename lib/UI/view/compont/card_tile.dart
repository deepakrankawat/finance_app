import 'package:finance_app/UI/screen_assets/Colors.dart';
import 'package:finance_app/UI/model/cardmodel.dart';
import 'package:finance_app/UI/screen_assets/Size.dart';
import 'package:flutter/material.dart';


class CardTile extends StatelessWidget {
  final CardModel data;

  const CardTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(data.imagePath, height:SizeConfig.screenHeight /5),
          const SizedBox(height: 10),
          Text(data.title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
