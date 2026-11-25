import 'package:material_ui/material_ui.dart';

class DestinationDetailsScreen extends StatelessWidget {
  const DestinationDetailsScreen({super.key, required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Destination')),
      body: Center(child: Text('Details for "$destinationId" coming in 2.7')),
    );
  }
}