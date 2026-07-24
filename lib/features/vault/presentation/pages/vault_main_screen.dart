import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/features/vault/data/models/vault_item.dart';
import 'package:todo/features/vault/presentation/logic/vault_cubit.dart';
import 'package:todo/features/vault/presentation/logic/vault_state.dart';
import 'package:todo/features/vault/presentation/pages/add_vault_item_sheet.dart';

class VaultMainScreen extends StatelessWidget {
  final VaultUnlockedState state;
  final VaultCubit cubit;

  const VaultMainScreen({
    super.key,
    required this.state,
    required this.cubit,
  });

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddVaultItemSheet(cubit: cubit),
    );
  }

  void _showItemDetails(BuildContext context, VaultItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                _getCategoryIcon(item.category),
                color: const Color(0xFF5E42EB),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.category == 'note' && item.secretNote != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      item.secretNote!,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (item.category == 'photo' && item.filePath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item.filePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Text('Image unavailable'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Category: ${item.category.toUpperCase()}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${_formatBytes(item.fileSize)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Added: ${DateFormat('MMM dd, yyyy • hh:mm a').format(item.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmDelete(context, item);
              },
              child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E42EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, VaultItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vault Item?'),
        content: Text('Are you sure you want to permanently delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteItem(item.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'photo':
        return Icons.photo_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
        return Icons.audio_file_rounded;
      case 'doc':
        return Icons.insert_drive_file_rounded;
      case 'note':
        return Icons.note_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'photo':
        return const Color(0xFFEC4899);
      case 'video':
        return const Color(0xFFF59E0B);
      case 'audio':
        return const Color(0xFF10B981);
      case 'doc':
        return const Color(0xFF3B82F6);
      case 'note':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF5E42EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = state.items;
    final totalSize = items.fold<int>(0, (sum, item) => sum + item.fileSize);

    final categories = [
      {'key': 'all', 'label': 'All', 'icon': Icons.grid_view_rounded},
      {'key': 'photo', 'label': 'Photos', 'icon': Icons.photo_rounded},
      {'key': 'video', 'label': 'Videos', 'icon': Icons.videocam_rounded},
      {'key': 'audio', 'label': 'Audio', 'icon': Icons.audio_file_rounded},
      {'key': 'doc', 'label': 'Docs', 'icon': Icons.insert_drive_file_rounded},
      {'key': 'note', 'label': 'Notes', 'icon': Icons.note_rounded},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: Color(0xFF5E42EB)),
            SizedBox(width: 10),
            Text(
              'Encrypted Vault',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Lock Vault',
            onPressed: () => cubit.lockVault(),
            icon: const Icon(Icons.lock_rounded, color: Color(0xFF5E42EB)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFF5E42EB),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Item',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Storage Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E42EB), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E42EB).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_special_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${items.length} Saved Items',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Vault Usage: ${_formatBytes(totalSize)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final cat = categories[index];
                  final isSelected = state.selectedCategory == cat['key'];
                  final icon = cat['icon'] as IconData;

                  return ChoiceChip(
                    showCheckmark: false,
                    avatar: Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    label: Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF5E42EB),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF5E42EB)
                          : const Color(0xFFE2E8F0),
                    ),
                    onSelected: (_) => cubit.setCategoryFilter(cat['key'] as String),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Items Content
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF5E42EB)),
                    )
                  : items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_open_rounded,
                                size: 54,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Your Vault is empty',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tap "+ Add Item" to store secret notes & files',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final catColor = _getCategoryColor(item.category);

                            return InkWell(
                              onTap: () => _showItemDetails(context, item),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFEEF2F6),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(
                                              alpha: 0.12,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _getCategoryIcon(item.category),
                                            color: catColor,
                                            size: 20,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          onPressed: () =>
                                              _confirmDelete(context, item),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatBytes(item.fileSize),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMM dd').format(
                                            item.createdAt,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
