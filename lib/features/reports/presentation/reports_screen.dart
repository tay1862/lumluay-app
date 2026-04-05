import 'package:shadcn_flutter/shadcn_flutter.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64),
          SizedBox(height: 16),
          Text(
            'Reports & Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Phase 8 — Coming soon'),
        ],
      ),
    );
  }
}
