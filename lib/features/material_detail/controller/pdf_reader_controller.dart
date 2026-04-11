import 'package:get/get.dart';

class PdfReaderController extends GetxController {
  final RxInt currentPage = 1.obs;
  final RxInt totalPage = 1.obs;

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void setTotalPage(int total) {
    totalPage.value = total;
  }

  double get progress =>
      (currentPage.value / totalPage.value) * 100;
}
