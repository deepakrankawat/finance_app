import 'package:finance_app/UI/model/cardmodel.dart';
import 'package:get/get.dart';


class DashboardController extends GetxController {
  var filter = 'All'.obs;

  final allCards = <CardModel>[
    CardModel(title: 'Match Making', imagePath: 'assets/match.png', category: 'Astro'),
    CardModel(title: 'Subh Muhurat', imagePath: 'assets/muhurat.png', category: 'Astro'),
    CardModel(title: 'Finance Tips', imagePath: 'assets/finance.png', category: 'Finance'),
  ].obs;

  List<CardModel> get filteredCards {
    if (filter.value == 'All') {
      return allCards;
    } else {
      return allCards.where((card) => card.category == filter.value).toList();
    }
  }

  void changeFilter(String newFilter) {
    filter.value = newFilter;
  }
}
