import 'package:flutter/material.dart';

class ViewHistoryProvider with ChangeNotifier {
  List<Map?> _historyItems = [];
  List<Map?> _memoryItems = [];
  String _memoryName = "";
  List<int> _selectedIndexList = [];

  bool _selectionMode = false;
  bool _selectedAll = false;
  bool _haveMemories = false;

  List<Map?> get historyItems => _historyItems;
  List<Map?> get memoryItems => _memoryItems;
  String get memoryName => _memoryName;
  List<int> get selectedIndexList => _selectedIndexList;
  bool get selectionMode => _selectionMode;
  bool get selectedAll => _selectedAll;
  bool get haveMemories => _haveMemories;

  void toggleSelectionMode() {
    _selectionMode = !_selectionMode;
    _selectedIndexList.clear();
    _selectedAll = false;
    notifyListeners();
  }

  void resetSelection() {
    _selectionMode = false;
    _selectedIndexList.clear();
  }

  void addSelected(int index) {
    _selectedIndexList.add(index);
    _selectedIndexList.sort();
    if (_selectedIndexList.length == _historyItems.length) {
      _selectedAll = true;
    }
    notifyListeners();
  }

  void removeSelected(int index) {
    _selectedIndexList.remove(index);
    _selectedIndexList.sort();
    _selectedAll = false;
    notifyListeners();
  }

  void selectAll() {
    for (int i = 0; i < _historyItems.length; i++) {
      if (!_selectedIndexList.contains(i)) {
        _selectedIndexList.add(i);
      }
    }
    _selectedAll = !_selectedAll;
    notifyListeners();
  }

  void clearAllSelected() {
    _selectedIndexList.clear();
    _selectedAll = !_selectedAll;
    notifyListeners();
  }

  List<int> readSelected() {
    return _selectedIndexList;
  }

  bool contains(int index) {
    return _selectedIndexList.contains(index);
  }

  void setAllPhotos(List<Map?> photos) {
    _historyItems = [];
    _historyItems.addAll(photos);
    // notifyListeners();
  }

  void setMemoryName(String name) {
    _memoryName = name;
  }

  void setAllMemory(List<Map?> memory) {
    _memoryItems = [];
    _memoryItems.addAll(memory);
    // notifyListeners();
  }

  void setHaveMemory(bool have){
    _haveMemories = have;
    notifyListeners();
  }

  void addedMemory(){
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
