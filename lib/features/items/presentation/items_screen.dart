import 'package:shadcn_flutter/shadcn_flutter.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64),
          SizedBox(height: 16),
          Text(
            'Items & Categories',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Phase 1 — Coming soon'),
        ],
      ),
    );
  }
}
