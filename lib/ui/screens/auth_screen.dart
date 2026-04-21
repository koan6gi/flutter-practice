import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/moto_provider.dart';
import '../../logic/settings_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MotoProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(settings.translate(_isLogin ? 'login' : 'register'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController, 
              decoration: InputDecoration(labelText: settings.translate('email'))
            ),
            TextField(
              controller: _passController, 
              obscureText: true, 
              decoration: InputDecoration(labelText: settings.translate('password'))
            ),
            const SizedBox(height: 20),
            if (provider.isLoading) 
              const CircularProgressIndicator()
            else 
              ElevatedButton(
                onPressed: () async {
                  try {
                    await provider.authAction(_emailController.text, _passController.text, _isLogin);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: Text(settings.translate(_isLogin ? 'login' : 'register')),
              ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(settings.translate(_isLogin ? 'createAccount' : 'haveAccount')),
            )
          ],
        ),
      ),
    );
  }
}