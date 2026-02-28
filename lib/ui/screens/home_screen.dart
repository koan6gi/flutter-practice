import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/moto_provider.dart';
import '../../logic/settings_provider.dart';
import 'settings_screen.dart';
import 'save_moto_screen.dart';
import 'detail_screen.dart';   

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MotoProvider>(context, listen: false).fetchAndSetMotorcycles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context); 

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('title')), 
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: Consumer<MotoProvider>(
        builder: (context, motoData, child) {
          if (motoData.items.isEmpty) {
            return const Center(child: Text('Список пуст / List is empty'));
          }
          return ListView.builder(
            itemCount: motoData.items.length,
            itemBuilder: (context, index) {
              final moto = motoData.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.motorcycle),
                  title: Text('${moto.brand} ${moto.model}'),
                  subtitle: Text(moto.year),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => DetailScreen(moto: moto),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SaveMotoScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
