import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/motorcycle.dart';
import '../../logic/moto_provider.dart';
import '../../logic/settings_provider.dart';

class SaveMotoScreen extends StatefulWidget {
  final Motorcycle? moto;

  const SaveMotoScreen({super.key, this.moto});

  @override
  State<SaveMotoScreen> createState() => _SaveMotoScreenState();
}

class _SaveMotoScreenState extends State<SaveMotoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.moto?.brand ?? '');
    _modelController = TextEditingController(text: widget.moto?.model ?? '');
    _yearController = TextEditingController(text: widget.moto?.year ?? '');
    _descController = TextEditingController(text: widget.moto?.description ?? '');
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<MotoProvider>(context, listen: false);

      if (widget.moto == null) {
        provider.addMoto(
          _brandController.text,
          _modelController.text,
          _yearController.text,
          _descController.text,
        );
      } else {
        final updatedMoto = Motorcycle(
          id: widget.moto!.id,
          brand: _brandController.text,
          model: _modelController.text,
          year: _yearController.text,
          description: _descController.text,
        );
        provider.updateMoto(updatedMoto);
      }
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moto == null ? settings.translate('add') : 'Edit'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: settings.translate('brand')),
                validator: (value) => value!.isEmpty ? 'Enter brand' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(labelText: settings.translate('model')),
                validator: (value) => value!.isEmpty ? 'Enter model' : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(labelText: settings.translate('year')),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: settings.translate('desc')),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(settings.translate('save')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
