import 'package:get/get.dart';
import '../../../core/services/catatan_service.dart';

class ProfileNotesController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> notes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> materiList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes({int page = 1, int perPage = 8}) async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await CatatanService.listWithMateri(page: page, perPage: perPage);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
      } else {
        final catatan = res['catatan'];
        if (catatan is Map && catatan['data'] is List) {
          notes.assignAll((catatan['data'] as List).cast<Map<String, dynamic>>());
        } else if (res['data'] is List) {
          notes.assignAll((res['data'] as List).cast<Map<String, dynamic>>());
        } else {
          notes.clear();
        }
        final materi = res['materi_list'];
        if (materi is List) {
          materiList.assignAll(materi.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createNote({
    int? materiId,
    required String isi,
  }) async {
    if (isi.trim().isEmpty) {
      error.value = 'Isi catatan tidak boleh kosong.';
      return false;
    }
    isSaving.value = true;
    error.value = '';
    try {
      final res = await CatatanService.create(materiId: materiId, isi: isi.trim());
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
        return false;
      }
      await fetchNotes();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteNote(int noteId) async {
    isSaving.value = true;
    error.value = '';
    try {
      final res = await CatatanService.delete(noteId);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
        return false;
      }
      notes.removeWhere((item) => item['id'] == noteId);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
