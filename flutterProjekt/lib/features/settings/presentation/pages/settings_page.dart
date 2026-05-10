import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../chat/data/models/ollama_model.dart';
import '../../domain/usecases/get_ollama_models.dart';
import '../../domain/usecases/test_ollama_connection.dart';

enum OllamaConnectionStatus { idle, testing, ok, error }

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiKeyController = TextEditingController();
  final _ollamaUrlController = TextEditingController();
  AiProvider _selectedProvider = AiProvider.anthropic;
  bool _obscureKey = true;
  bool _loading = true;
  final _secureStorage = GetIt.I<FlutterSecureStorage>();

  // Ollama state
  OllamaConnectionStatus _ollamaStatus = OllamaConnectionStatus.idle;
  String? _ollamaError;
  List<OllamaModel> _ollamaModels = [];
  String? _selectedOllamaModel;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final apiKey = await _secureStorage.read(key: AppConstants.apiKeyKey);
    final provider =
        await _secureStorage.read(key: AppConstants.apiProviderKey);
    final ollamaUrl =
        await _secureStorage.read(key: AppConstants.ollamaBaseUrlKey);
    final ollamaModel =
        await _secureStorage.read(key: AppConstants.ollamaModelKey);

    setState(() {
      _apiKeyController.text = apiKey ?? '';
      _ollamaUrlController.text =
          ollamaUrl ?? ApiConstants.ollamaDefaultBaseUrl;
      _selectedOllamaModel = ollamaModel;
      _selectedProvider = switch (provider) {
        'openai' => AiProvider.openai,
        'ollama' => AiProvider.ollama,
        _ => AiProvider.anthropic,
      };
      _loading = false;
    });

    // Auto-fetch models if Ollama is selected
    if (_selectedProvider == AiProvider.ollama) {
      _testOllamaConnection();
    }
  }

  Future<void> _saveSettings() async {
    await _secureStorage.write(
      key: AppConstants.apiKeyKey,
      value: _apiKeyController.text.trim(),
    );
    await _secureStorage.write(
      key: AppConstants.apiProviderKey,
      value: switch (_selectedProvider) {
        AiProvider.openai => 'openai',
        AiProvider.ollama => 'ollama',
        _ => 'anthropic',
      },
    );
    await _secureStorage.write(
      key: AppConstants.ollamaBaseUrlKey,
      value: _ollamaUrlController.text.trim(),
    );
    if (_selectedOllamaModel != null) {
      await _secureStorage.write(
        key: AppConstants.ollamaModelKey,
        value: _selectedOllamaModel!,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ustawienia zapisane'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _testOllamaConnection() async {
    setState(() {
      _ollamaStatus = OllamaConnectionStatus.testing;
      _ollamaError = null;
      _ollamaModels = [];
    });

    final testUseCase = GetIt.I<TestOllamaConnection>();
    final result = await testUseCase(_ollamaUrlController.text.trim());

    result.fold(
      onSuccess: (_) async {
        // Connection OK — now fetch model list
        final getModels = GetIt.I<GetOllamaModels>();
        final modelsResult =
            await getModels(_ollamaUrlController.text.trim());

        modelsResult.fold(
          onSuccess: (models) {
            if (mounted) {
              setState(() {
                _ollamaStatus = OllamaConnectionStatus.ok;
                _ollamaModels = models;
                // Auto-select first model if none selected
                if (_selectedOllamaModel == null && models.isNotEmpty) {
                  _selectedOllamaModel = models.first.name;
                }
                // Validate current selection still exists
                final currentModel = _selectedOllamaModel;
                if (currentModel != null &&
                    !models.any((m) => m.name == currentModel)) {
                  _selectedOllamaModel =
                      models.isNotEmpty ? models.first.name : null;
                }
              });
            }
          },
          onError: (failure) {
            if (mounted) {
              setState(() {
                _ollamaStatus = OllamaConnectionStatus.error;
                _ollamaError = failure.message;
              });
            }
          },
        );
      },
      onError: (failure) {
        if (mounted) {
          setState(() {
            _ollamaStatus = OllamaConnectionStatus.error;
            _ollamaError = failure.message;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _ollamaUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Konfiguracja AI',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Provider selection
          _buildProviderCard(),
          const SizedBox(height: 16),

          // API Key (hidden for Ollama)
          if (_selectedProvider != AiProvider.ollama) ...[
            _buildApiKeyCard(),
            const SizedBox(height: 16),
          ],

          // Ollama settings (visible only for Ollama)
          if (_selectedProvider == AiProvider.ollama) ...[
            _buildOllamaCard(),
            const SizedBox(height: 16),
          ],

          FilledButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Zapisz ustawienia'),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
          ),

          const SizedBox(height: 32),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildProviderCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dostawca AI',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<AiProvider>(
              segments: [
                ButtonSegment(
                    value: AiProvider.anthropic,
                    label: Text('Anthropic'),
                    icon: Icon(Icons.auto_awesome)),
                ButtonSegment(
                    value: AiProvider.openai,
                    label: Text('OpenAI'),
                    icon: Icon(Icons.psychology)),
                ButtonSegment(
                    value: AiProvider.ollama,
                    label: Text('Ollama'),
                    icon: Icon(Icons.computer)),
              ],
              selected: {_selectedProvider},
              onSelectionChanged: (v) {
                setState(() => _selectedProvider = v.first);
                if (v.first == AiProvider.ollama) {
                  _testOllamaConnection();
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getModelDescription(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  String _getModelDescription() {
    return switch (_selectedProvider) {
      AiProvider.anthropic => 'Model: ${ApiConstants.anthropicModel}',
      AiProvider.openai => 'Model: ${ApiConstants.openAiModel}',
      AiProvider.ollama => _selectedOllamaModel != null
          ? 'Model: $_selectedOllamaModel'
          : 'Wybierz model lokalny',
    };
  }

  Widget _buildApiKeyCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Klucz API',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                hintText: _selectedProvider == AiProvider.anthropic
                    ? 'sk-ant-...'
                    : 'sk-...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(_obscureKey
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Klucz jest przechowywany bezpiecznie w zaszyfrowanym magazynie urządzenia.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOllamaCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.computer,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Konfiguracja Ollama',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),

            // Server URL
            Text('Adres serwera',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ollamaUrlController,
                    decoration: InputDecoration(
                      hintText: ApiConstants.ollamaDefaultBaseUrl,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.link),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed:
                      _ollamaStatus == OllamaConnectionStatus.testing
                          ? null
                          : _testOllamaConnection,
                  icon: _ollamaStatus ==
                          OllamaConnectionStatus.testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_find),
                  label: const Text('Test'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Na emulatorze Android użyj 10.0.2.2 zamiast localhost.\n'
              'Na fizycznym urządzeniu podaj IP komputera w sieci lokalnej.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),

            // Connection status
            _buildConnectionStatus(),
            const SizedBox(height: 16),

            // Model list
            if (_ollamaStatus == OllamaConnectionStatus.ok &&
                _ollamaModels.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Wykryte modele (${_ollamaModels.length})',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _testOllamaConnection,
                    tooltip: 'Odśwież listę modeli',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...List.generate(_ollamaModels.length, (index) {
                final model = _ollamaModels[index];
                final isSelected = _selectedOllamaModel == model.name;
                return ListTile(
                  leading: Radio<String>(
                    value: model.name,
                    groupValue: _selectedOllamaModel,
                    onChanged: (v) =>
                        setState(() => _selectedOllamaModel = v),
                  ),
                  title: Text(model.displayName,
                      style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500)),
                  subtitle: Text(
                      '${model.tag} • ${model.sizeFormatted}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onTap: () => setState(
                      () => _selectedOllamaModel = model.name),
                );
              }),
            ],

            const SizedBox(height: 12),

            // Privacy notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color:
                          Theme.of(context).colorScheme.primary,
                      size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ollama działa lokalnie — dane nie opuszczają Twojego urządzenia.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return switch (_ollamaStatus) {
      OllamaConnectionStatus.idle => const SizedBox.shrink(),
      OllamaConnectionStatus.testing => Row(
          children: [
            SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(width: 8),
            Text('Sprawdzanie połączenia...',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      OllamaConnectionStatus.ok => Row(
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Połączono — znaleziono ${_ollamaModels.length} modeli',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.green.shade700),
              ),
            ),
          ],
        ),
      OllamaConnectionStatus.error => Row(
          children: [
            const Icon(Icons.error_outline,
                color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _ollamaError ?? 'Nie można połączyć z Ollama',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red.shade700),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
    };
  }

  Widget _buildInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informacje',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: const Column(
            children: [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('AI Study App'),
                subtitle: Text('Wersja 1.1.0'),
              ),
              ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text('Architektura'),
                subtitle: Text('Clean Architecture + flutter_bloc'),
              ),
              ListTile(
                leading: Icon(Icons.dns_outlined),
                title: Text('Dostawcy AI'),
                subtitle: Text('Anthropic Claude, OpenAI GPT, Ollama (lokalny)'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
