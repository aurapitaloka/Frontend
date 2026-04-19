import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_quiz_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../routes/app_routes.dart';

class ProfileQuizView extends GetView<ProfileQuizController> {
  const ProfileQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Kuis',
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
                  onRefresh: controller.fetchKuis,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _podiumCard(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle('Kuis Umum'),
                          TextButton(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.profileQuizHistory),
                            child: const Text('Riwayat Kuis'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (controller.kuisUmum.isEmpty)
                        _emptyCard('Belum ada kuis umum tersedia.')
                      else
                        ...controller.kuisUmum.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _openQuiz(item),
                              child: _quizCard(
                                title: _quizTitle(item, fallback: 'Kuis'),
                                subtitle:
                                    '${item['pertanyaan_count'] ?? 0} soal • Nilai ${_scoreText(item)}',
                                status: _statusText(item),
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      _sectionTitle('Kuis Materi'),
                      const SizedBox(height: 10),
                      if (controller.kuisMateri.isEmpty)
                        _emptyCard('Belum ada kuis materi tersedia.')
                      else
                        ...controller.kuisMateri.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _openQuiz(item, isMateri: true),
                              child: _quizMateriCard(item),
                            ),
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

  Future<void> _openQuiz(
    Map<String, dynamic> item, {
    bool isMateri = false,
  }) async {
    final completed = _isCompleted(item);
    final args = <String, dynamic>{
      'kuis_id': _quizId(item),
      'is_completed': completed,
      'score': _scoreText(item),
    };
    if (isMateri) {
      args['materi_id'] = _materiId(item);
    }
    await Get.toNamed(AppRoutes.profileQuizDetail, arguments: args);
    await controller.fetchKuis();
  }

  Widget _podiumCard() {
    final top = _topHistory();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Podium nilai terbaik',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textBlack,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 14),
          if (top.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Belum ada riwayat kuis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _podiumResult(
                  item: top.length > 1 ? top[1] : null,
                  height: 86,
                  color: const Color(0xFF81D4FA),
                  rank: '2',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _podiumResult(
                    item: top.first,
                    height: 118,
                    color: const Color(0xFFFFB300),
                    rank: '1',
                    isWinner: true,
                  ),
                ),
                const SizedBox(width: 8),
                _podiumResult(
                  item: top.length > 2 ? top[2] : null,
                  height: 72,
                  color: const Color(0xFFA5D6A7),
                  rank: '3',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _podiumResult({
    required Map<String, dynamic>? item,
    required double height,
    required Color color,
    required String rank,
    bool isWinner = false,
  }) {
    final title = item == null ? '-' : _historyTitle(item);
    final score = item == null ? '-' : _historyScoreText(item);
    return Column(
      children: [
        if (isWinner)
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFB300),
            size: 30,
          ),
        Text(
          score,
          style: TextStyle(
            fontSize: isWinner ? 26 : 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 54,
          height: height,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rank,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: isWinner ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quizCard({
    required String title,
    required String subtitle,
    required String status,
    required Color color,
  }) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.task_alt_rounded, color: color, size: 22),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizMateriCard(Map<String, dynamic> item) {
    final materi = item['materi'] as Map<String, dynamic>? ?? {};
    return _quizCard(
      title: _quizTitle(item, fallback: 'Kuis Materi'),
      subtitle: '${materi['judul'] ?? 'Materi'} • Nilai ${_scoreText(item)}',
      status: _statusText(item),
      color: const Color(0xFF3F51B5),
    );
  }

  List<Map<String, dynamic>> _topHistory() {
    final items = [...controller.riwayatKuis];
    items.sort(
      (a, b) => (_historyScore(b) ?? -1).compareTo(_historyScore(a) ?? -1),
    );
    return items.take(3).toList();
  }

  int _quizId(Map<String, dynamic> item) {
    final nested = item['kuis'];
    final raw =
        item['id'] ??
        item['kuis_id'] ??
        item['quiz_id'] ??
        (nested is Map ? nested['id'] ?? nested['kuis_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  int _materiId(Map<String, dynamic> item) {
    final nested = item['materi'];
    final raw =
        item['materi_id'] ??
        (nested is Map ? nested['id'] ?? nested['materi_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  String _quizTitle(Map<String, dynamic> item, {required String fallback}) {
    final nested = item['kuis'];
    final raw =
        item['judul'] ??
        item['title'] ??
        item['kuis_judul'] ??
        (nested is Map ? nested['judul'] ?? nested['title'] : null);
    final title = raw?.toString() ?? '';
    return title.isNotEmpty ? title : fallback;
  }

  bool _isCompleted(Map<String, dynamic> item) {
    if (_historyForQuiz(item) != null) return true;
    final score = _scoreValue(item);
    return item['is_completed'] == true ||
        item['completed'] == true ||
        item['sudah_dikerjakan'] == true ||
        item['has_submitted'] == true ||
        item['hasil_id'] != null ||
        score != null;
  }

  String _statusText(Map<String, dynamic> item) {
    if (_isCompleted(item)) return 'Selesai';
    return (item['status_aktif'] == false) ? 'Nonaktif' : 'Mulai';
  }

  String _scoreText(Map<String, dynamic> item) {
    final history = _historyForQuiz(item);
    if (history != null) return _historyScoreText(history);
    final score = _scoreValue(item);
    return score == null ? '-' : score.toStringAsFixed(score % 1 == 0 ? 0 : 1);
  }

  double? _scoreValue(Map<String, dynamic> item) {
    final materiId = _materiId(item);
    final progress = materiId > 0 ? controller.progressMap['$materiId'] : null;
    final raw =
        item['skor'] ??
        item['nilai'] ??
        item['score'] ??
        item['best_score'] ??
        item['skor_terbaik'] ??
        item['nilai_terbaik'] ??
        (progress is Map
            ? progress['skor'] ??
                  progress['nilai'] ??
                  progress['score'] ??
                  progress['best_score']
            : null);
    return double.tryParse(raw?.toString() ?? '');
  }

  Map<String, dynamic>? _historyForQuiz(Map<String, dynamic> item) {
    final quizId = _quizId(item);
    final materiId = _materiId(item);
    final title = _normalize(_quizTitle(item, fallback: ''));
    for (final history in controller.riwayatKuis) {
      final historyQuizId = _historyQuizId(history);
      final historyMateriId = _historyMateriId(history);
      final historyTitle = _normalize(_historyTitle(history));
      if (quizId > 0 && historyQuizId == quizId) return history;
      if (materiId > 0 && historyMateriId == materiId) return history;
      if (title.isNotEmpty && title == historyTitle) return history;
    }
    return null;
  }

  int _historyQuizId(Map<String, dynamic> item) {
    final nested = item['kuis'];
    final raw =
        item['kuis_id'] ??
        item['quiz_id'] ??
        item['id_kuis'] ??
        (nested is Map ? nested['id'] ?? nested['kuis_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  int _historyMateriId(Map<String, dynamic> item) {
    final nested = item['materi'];
    final raw =
        item['materi_id'] ??
        item['id_materi'] ??
        (nested is Map ? nested['id'] ?? nested['materi_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  String _historyTitle(Map<String, dynamic> item) {
    final nested = item['kuis'];
    final raw =
        item['kuis_judul'] ??
        item['judul'] ??
        item['title'] ??
        (nested is Map ? nested['judul'] ?? nested['title'] : null);
    final title = raw?.toString() ?? '';
    return title.isNotEmpty ? title : 'Kuis';
  }

  double? _historyScore(Map<String, dynamic> item) {
    final raw =
        item['skor'] ??
        item['nilai'] ??
        item['score'] ??
        item['best_score'] ??
        item['skor_terbaik'] ??
        item['nilai_terbaik'];
    return double.tryParse(raw?.toString() ?? '');
  }

  String _historyScoreText(Map<String, dynamic> item) {
    final score = _historyScore(item);
    return score == null ? '-' : score.toStringAsFixed(score % 1 == 0 ? 0 : 1);
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textBlack,
        fontFamily: 'Roboto',
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
        style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
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
              onPressed: controller.fetchKuis,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
