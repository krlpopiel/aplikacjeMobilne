import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/study_material.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';

class MaterialsPage extends StatelessWidget {
  final String subjectId;

  const MaterialsPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiały'),
        centerTitle: true,
      ),
      body: BlocBuilder<MaterialsBloc, MaterialsState>(
        builder: (context, state) {
          if (state.status == MaterialsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MaterialsStatus.uploading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Przetwarzanie: ${state.uploadingFileName ?? "..."}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wyodrębnianie tekstu i tworzenie chunków...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            );
          }

          if (state.status == MaterialsStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Wystąpił błąd'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context
                        .read<MaterialsBloc>()
                        .add(LoadMaterials(subjectId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          }

          if (state.materials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Brak materiałów',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wgraj PDF lub zdjęcie notatek',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.materials.length,
            itemBuilder: (context, index) {
              final material = state.materials[index];
              return _MaterialTile(
                material: material,
                onDelete: () {
                  context.read<MaterialsBloc>().add(
                        DeleteMaterialEvent(
                          materialId: material.id,
                          subjectId: subjectId,
                        ),
                      );
                },
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                  .slideX(begin: 0.05, duration: 300.ms, delay: (50 * index).ms);
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'image',
            onPressed: () => _pickImage(context),
            child: const Icon(Icons.camera_alt_rounded),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'pdf',
            onPressed: () => _pickPdf(context),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Wgraj PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPdf(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // ensures bytes are available on all platforms
    );

    if (result != null && result.files.single.bytes != null) {
      if (context.mounted) {
        context.read<MaterialsBloc>().add(UploadPdfEvent(
              subjectId: subjectId,
              fileName: result.files.single.name,
              fileBytes: result.files.single.bytes!,
            ));
      }
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      if (context.mounted) {
        context.read<MaterialsBloc>().add(UploadImageEvent(
              subjectId: subjectId,
              fileName: image.name,
              fileBytes: bytes,
            ));
      }
    }
  }
}

class _MaterialTile extends StatelessWidget {
  final StudyMaterial material;
  final VoidCallback onDelete;

  const _MaterialTile({required this.material, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isPdf = material.type == MaterialType.pdf;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isPdf ? Colors.red : Colors.blue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
            color: isPdf ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          material.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${material.chunks.length} chunków • ${_formatDate(material.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onDelete,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
