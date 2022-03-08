import 'package:flutter/material.dart';

class ViewHistoryProvider with ChangeNotifier {
  List<Map?> _items = [];
  List<int> _selectedIndexList = [];
  bool _selectionMode = false;

  List<Map?> get items => _items;
  List<int> get selectedIndexList => _selectedIndexList;
  bool get selectionMode => _selectionMode;

  void toggleSelectionMode() {
    _selectionMode = !_selectionMode;
    _selectedIndexList.clear();
    notifyListeners();
  }

  void resetSelection(){
    _selectionMode = false;
    _selectedIndexList.clear();
    notifyListeners();
  }

  void addSelected(int index) {
    _selectedIndexList.add(index);
    notifyListeners();
  }

  void removeSelected(int index) {
    _selectedIndexList.remove(index);
    notifyListeners();
  }

  void clearAllSelected() {
    _selectedIndexList.clear();
    notifyListeners();
  }

  bool contains(int index) {
    notifyListeners();
    return _selectedIndexList.contains(index);
  }

  void setAllPhotos(List<Map?> photos) {
    _items = List<Map?>.from(photos);
    notifyListeners();
  }

  void changeSelection({required bool enable, required int index}) {
    _selectionMode = enable;
    _selectedIndexList.add(index);
    if (index == -1) {
      _selectedIndexList.clear();
    }
    notifyListeners();
  }
}
