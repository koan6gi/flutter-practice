import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/moto_provider.dart';
import '../../logic/settings_provider.dart';
import 'settings_screen.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

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
      Provider.of<MotoProvider>(context, listen: false).loadCollection();
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
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: settings.translate('searchGarage'),
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => motoData.setGarageSearchQuery(value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: motoData.selectedType,
                      items: motoData.availableTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type == 'All' ? settings.translate('allTypes') : type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) motoData.setFilterType(value);
                      },
                    ),
                    TextButton.icon(
                      onPressed: () => motoData.toggleSort(),
                      icon: Icon(motoData.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                      label: Text(motoData.sortAscending 
                        ? settings.translate('sortAsc') 
                        : settings.translate('sortDesc')),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: motoData.filteredCollection.isEmpty
                  ? Center(child: Text(settings.translate('emptyGarage')))
                  : ListView.builder(
                      itemCount: motoData.filteredCollection.length,
                      itemBuilder: (context, index) {
                        final moto = motoData.filteredCollection[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: moto.imageUrl != null
                              ? Image.network(moto.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.motorcycle),
                            title: Text('${moto.make} ${moto.model}'),
                            subtitle: Text('${moto.year} | ${moto.type}'),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => DetailScreen(moto: moto, isFromSearch: false),
                              ));
                            },
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<MotoProvider>(context, listen: false).clearSearch();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}