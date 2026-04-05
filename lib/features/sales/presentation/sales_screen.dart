import 'package:shadcn_flutter/shadcn_flutter.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.point_of_sale, size: 64),
          SizedBox(height: 16),
          Text(
            'Sales Screen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Phase 2 — Coming soon'),
        ],
      ),
    );
  }
}
