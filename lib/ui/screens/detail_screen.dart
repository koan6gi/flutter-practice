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
    final provider = Provider.of<MotoProvider>(context);

    Motorcycle currentMoto = moto;
    if (!isFromSearch) {
      currentMoto = provider.collection.firstWhere(
        (m) => m.id == moto.id, 
        orElse: () => moto
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentMoto.make} ${currentMoto.model}'),
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
                          provider.removeFromCollection(currentMoto);
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
                provider.addToCollection(currentMoto);
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
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: currentMoto.imageUrl != null
                    ? Image.network(
                        currentMoto.imageUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.motorcycle, 
                        size: 150, 
                        color: Colors.grey[400]
                      ),
                ),
                const SizedBox(height: 20),
                Text('${settings.translate('make')}: ${currentMoto.make}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('${settings.translate('model')}: ${currentMoto.model}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('${settings.translate('year')}: ${currentMoto.year}', style: const TextStyle(fontSize: 18)),
                const Divider(),
                Text('${settings.translate('type')}: ${currentMoto.type}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('${settings.translate('engine')}: ${currentMoto.engine}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('${settings.translate('power')}: ${currentMoto.power}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('${settings.translate('transmission')}: ${currentMoto.transmission}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('${settings.translate('weight')}: ${currentMoto.weight}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                
                if (!isFromSearch) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(settings.translate('attachPhoto')),
                      onPressed: () => provider.attachPhoto(currentMoto),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.notifications_active),
                      label: Text(settings.translate('remindMaint')),
                      onPressed: () {
                        provider.scheduleReminder(
                          settings.translate('notifyTitle'),
                          settings.translate('remindMaint')
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(settings.translate('notifyScheduled')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
    );
  }
}