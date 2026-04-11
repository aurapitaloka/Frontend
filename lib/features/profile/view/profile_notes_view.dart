import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_notes_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/primary_header.dart';

class ProfileNotesView extends GetView<ProfileNotesController> {
  const ProfileNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Catatan',
              trailing: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded, color: AppColors.orange),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error.value.isNotEmpty) {
                  return _errorState(controller.error.value);
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchNotes,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _infoCard(),
                      const SizedBox(height: 14),
                      _actionRow(),
                      const SizedBox(height: 16),
                      if (controller.notes.isEmpty)
                        _emptyCard('Belum ada catatan.'),
                      ...controller.notes.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _noteCard(item),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.note_rounded, color: AppColors.orange),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Simpan catatan singkat agar materi lebih mudah diingat.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textBlack,
                height: 1.4,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showCreateNoteSheet,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah Catatan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: controller.fetchNotes,
          icon: const Icon(Icons.refresh_rounded, color: AppColors.orange),
        ),
      ],
    );
  }

  Widget _noteCard(Map<String, dynamic> item) {
    final materi = item['materi'] as Map<String, dynamic>?;
    final title = materi?['judul']?.toString() ?? 'Catatan Umum';
    final desc = item['isi']?.toString() ?? '';
    final time = DateTimeFormatter.short(item['created_at']?.toString());
    final color = const Color(0xFF2196F3);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sticky_note_2_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(item['id']),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.fetchNotes,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(dynamic id) async {
    final noteId = int.tryParse(id.toString());
    if (noteId == null) return;
    final result = await showDialog<bool>(
      context: Get.context!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus catatan'),
          content: const Text('Yakin ingin menghapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await controller.deleteNote(noteId);
    }
  }

  void _showCreateNoteSheet() {
    final context = Get.context;
    if (context == null) return;
    final isiController = TextEditingController();
    int? selectedMateriId;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Catatan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedMateriId,
                    isExpanded: true,
                    items: controller.materiList
                        .map(
                          (m) => DropdownMenuItem<int>(
                            value: int.tryParse(m['id'].toString()),
                            child: Text(m['judul']?.toString() ?? 'Materi'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedMateriId = value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Materi (opsional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: isiController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Isi catatan',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : () async {
                                    final ok = await controller.createNote(
                                      materiId: selectedMateriId,
                                      isi: isiController.text,
                                    );
                                    if (ok && Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: AppColors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
