import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/motorcycle.dart';
import '../../logic/moto_provider.dart';
import '../../logic/settings_provider.dart';
import 'save_moto_screen.dart';

class DetailScreen extends StatelessWidget {
  final Motorcycle moto;

  const DetailScreen({super.key, required this.moto});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${moto.brand} ${moto.model}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SaveMotoScreen(moto: moto)),
              );
            },
          ),
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
                        Provider.of<MotoProvider>(context, listen: false).deleteMoto(moto.id!);
                        Navigator.of(ctx).pop(); 
                        Navigator.of(context).pop(); 
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
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
            
            Text('${settings.translate('brand')}: ${moto.brand}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('${settings.translate('model')}: ${moto.model}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('${settings.translate('year')}: ${moto.year}', style: const TextStyle(fontSize: 18)),
            const Divider(),
            const SizedBox(height: 10),
            Text(settings.translate('desc'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(moto.description, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
