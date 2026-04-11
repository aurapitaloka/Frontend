import 'package:get/get.dart';
import '../../../core/services/sesi_baca_service.dart';

class ReadingSessionController extends GetxController {
  final RxInt lastPage = 1.obs;
  final RxInt progress = 0.obs;

  int? materiId;

  Future<void> loadLastSession(int id) async {
    materiId = id;
    try {
      final res = await SesiBacaService.getLast(id);
      if (res.containsKey('id')) {
        lastPage.value = res['halaman_terakhir'] ?? 1;
        progress.value = res['progres_persen'] ?? 0;
      }
    } catch (_) {}
  }

  Future<void> saveSession({
    required int page,
    required int totalPage,
  }) async {
    if (materiId == null) return;

    final persen = ((page / totalPage) * 100).round();

    await SesiBacaService.upsert({
      'materi_id': materiId,
      'halaman_terakhir': page,
      'progres_persen': persen,
    });
  }
}
