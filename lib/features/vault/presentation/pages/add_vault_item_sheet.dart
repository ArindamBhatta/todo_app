import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo/features/vault/presentation/logic/vault_cubit.dart';

class AddVaultItemSheet extends StatefulWidget {
  final VaultCubit cubit;

  const AddVaultItemSheet({super.key, required this.cubit});

  @override
  State<AddVaultItemSheet> createState() => _AddVaultItemSheetState();
}

class _AddVaultItemSheetState extends State<AddVaultItemSheet> {
  bool _isCreatingNote = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      final name = image.name.isNotEmpty ? image.name : 'Photo ${DateTime.now().millisecond}';
      await widget.cubit.addVaultFile(
        title: name,
        category: 'photo',
        filePath: image.path,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null && mounted) {
      final name = video.name.isNotEmpty ? video.name : 'Video ${DateTime.now().millisecond}';
      await widget.cubit.addVaultFile(
        title: name,
        category: 'video',
        filePath: video.path,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null && mounted) {
      final file = result.files.single;
      await widget.cubit.addVaultFile(
        title: file.name,
        category: 'doc',
        filePath: file.path!,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null && mounted) {
      final file = result.files.single;
      await widget.cubit.addVaultFile(
        title: file.name,
        category: 'audio',
        filePath: file.path!,
      );
      if (mounted) Navigator.pop(context);
    }
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) return;
    widget.cubit.addSecretNote(
      title: _titleController.text,
      content: _noteController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (!_isCreatingNote) ...[
              const Text(
                'Add to Private Vault',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select item type to import into local encrypted vault',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              _buildOptionTile(
                icon: Icons.note_add_rounded,
                color: const Color(0xFF6366F1),
                title: 'Secret Note',
                subtitle: 'Write an encrypted private note',
                onTap: () => setState(() => _isCreatingNote = true),
              ),
              const SizedBox(height: 12),
              _buildOptionTile(
                icon: Icons.photo_library_rounded,
                color: const Color(0xFFEC4899),
                title: 'Import Photo',
                subtitle: 'Add a private image from gallery',
                onTap: _pickPhoto,
              ),
              const SizedBox(height: 12),
              _buildOptionTile(
                icon: Icons.videocam_rounded,
                color: const Color(0xFFF59E0B),
                title: 'Import Video',
                subtitle: 'Add a private video file',
                onTap: _pickVideo,
              ),
              const SizedBox(height: 12),
              _buildOptionTile(
                icon: Icons.audio_file_rounded,
                color: const Color(0xFF10B981),
                title: 'Import Audio',
                subtitle: 'Add voice memos or audio recordings',
                onTap: _pickAudio,
              ),
              const SizedBox(height: 12),
              _buildOptionTile(
                icon: Icons.insert_drive_file_rounded,
                color: const Color(0xFF3B82F6),
                title: 'Import Document',
                subtitle: 'Store confidential PDF or text files',
                onTap: _pickDocument,
              ),
            ] else ...[
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _isCreatingNote = false),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Create Secret Note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Note Title',
                  hintText: 'e.g. Bank Account Pin or Personal Journal',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Secret Content',
                  hintText: 'Write your private note here...',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E42EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save to Vault',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
