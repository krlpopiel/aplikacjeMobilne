import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiKeyController = TextEditingController();
  AiProvider _selectedProvider = AiProvider.anthropic;
  bool _obscureKey = true;
  bool _loading = true;
  final _secureStorage = GetIt.I<FlutterSecureStorage>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final apiKey = await _secureStorage.read(key: AppConstants.apiKeyKey);
    final provider = await _secureStorage.read(key: AppConstants.apiProviderKey);

    setState(() {
      _apiKeyController.text = apiKey ?? '';
      _selectedProvider = provider == 'openai' ? AiProvider.openai : AiProvider.anthropic;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _secureStorage.write(key: AppConstants.apiKeyKey, value: _apiKeyController.text.trim());
    await _secureStorage.write(
      key: AppConstants.apiProviderKey,
      value: _selectedProvider == AiProvider.openai ? 'openai' : 'anthropic',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ustawienia zapisane'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Konfiguracja AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dostawca AI', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<AiProvider>(
                    segments: [
                      ButtonSegment(value: AiProvider.anthropic, label: Text('Anthropic'),
                          icon: Icon(Icons.auto_awesome)),
                      ButtonSegment(value: AiProvider.openai, label: Text('OpenAI'),
                          icon: Icon(Icons.psychology)),
                    ],
                    selected: {_selectedProvider},
                    onSelectionChanged: (v) => setState(() => _selectedProvider = v.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedProvider == AiProvider.anthropic
                        ? 'Model: ${ApiConstants.anthropicModel}'
                        : 'Model: ${ApiConstants.openAiModel}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Klucz API', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      hintText: _selectedProvider == AiProvider.anthropic
                          ? 'sk-ant-...' : 'sk-...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klucz jest przechowywany bezpiecznie w zaszyfrowanym magazynie urządzenia.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Zapisz ustawienia'),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
          ),

          const SizedBox(height: 32),
          Text('Informacje', style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('AI Study App'),
                  subtitle: Text('Wersja 1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.description_outlined),
                  title: Text('Architektura'),
                  subtitle: Text('Clean Architecture + flutter_bloc'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
