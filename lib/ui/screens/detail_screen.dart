import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/motorcycle.dart';
import '../../logic/moto_provider.dart';
import '../../logic/settings_provider.dart';

class DetailScreen extends StatelessWidget {
  final Motorcycle moto;
  final bool isFromSearch;

  const DetailScreen({super.key, required this.moto, required this.isFromSearch});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${moto.make} ${moto.model}'),
        actions: [
          if (!isFromSearch)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('${settings.translate('delete')}?'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<MotoProvider>(context, listen: false).removeFromCollection(moto.id!);
                          Navigator.of(ctx).pop(); 
                          Navigator.of(context).pop(); 
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: () {
                Provider.of<MotoProvider>(context, listen: false).addToCollection(moto);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(settings.translate('addedSuccess')), 
                    duration: const Duration(seconds: 2)
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.motorcycle, 
                size: 150, 
                color: Colors.grey[400]
              )
            ),
            const SizedBox(height: 20),
            Text('${settings.translate('make')}: ${moto.make}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('${settings.translate('model')}: ${moto.model}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('${settings.translate('year')}: ${moto.year}', style: const TextStyle(fontSize: 18)),
            const Divider(),
            Text('${settings.translate('type')}: ${moto.type}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('${settings.translate('engine')}: ${moto.engine}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('${settings.translate('power')}: ${moto.power}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('${settings.translate('transmission')}: ${moto.transmission}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('${settings.translate('weight')}: ${moto.weight}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}