import 'package:flutter/cupertino.dart';

class PageCounter extends ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  set currentPage(int value) {
    _currentPage = value;
  }

  void incrementPage() {
    _currentPage++;
    notifyListeners(); // 通知监听器状态已更新
  }

  void decrementPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }
}