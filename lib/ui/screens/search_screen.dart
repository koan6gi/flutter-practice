import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/moto_provider.dart';
import '../../logic/settings_provider.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() async {
    final query = _searchController.text.trim();
    FocusScope.of(context).unfocus(); 

    final provider = Provider.of<MotoProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final messageKey = await provider.searchMotorcycles(query);

    if (messageKey != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.translate(messageKey)), 
          duration: const Duration(seconds: 3)
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('searchTitle')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: settings.translate('searchHint'),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<MotoProvider>(
              builder: (context, motoData, child) {
                if (motoData.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (motoData.searchResults.isEmpty) {
                  return const Center(child: Text(''));
                }

                return ListView.builder(
                  itemCount: motoData.searchResults.length,
                  itemBuilder: (context, index) {
                    final moto = motoData.searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.cloud_download),
                        title: Text('${moto.make} ${moto.model}'),
                        subtitle: Text('${moto.year} | ${moto.type}'),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => DetailScreen(moto: moto, isFromSearch: true),
                          ));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}