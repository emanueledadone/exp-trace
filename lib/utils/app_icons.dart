import 'package:flutter/material.dart';

class AppIcons {
  static final Map<String, IconData> iconMapping = {
    // Spese domestiche
    'home': Icons.home,
    'bills': Icons.electrical_services,
    'rent': Icons.house,
    'groceries': Icons.shopping_cart,
    'renovation': Icons.construction,

    // Trasporti
    'car': Icons.directions_car,
    'gas': Icons.local_gas_station,
    'public_transport': Icons.train,
    'motorcycle': Icons.motorcycle,
    'maintenance': Icons.build,

    // Tempo libero
    'entertainment': Icons.movie,
    'restaurant': Icons.restaurant,
    'sports': Icons.sports_soccer,
    'shopping': Icons.shopping_bag,
    'travel': Icons.flight,

    // Finanza
    'credit_card': Icons.credit_card,
    'savings': Icons.account_balance,
    'investments': Icons.trending_up,
    'income': Icons.attach_money,
    'subscriptions': Icons.subscriptions,
  };
}

IconData? getIcon(String category) {
  return AppIcons.iconMapping[category] ?? Icons.help_outline;
}
