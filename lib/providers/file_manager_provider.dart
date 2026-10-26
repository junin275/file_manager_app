import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/file_item.dart';

enum ViewMode { list, grid }
enum SortBy { name, size, date, type }

class FileManagerProvider extends ChangeNotifier {
  Directory _currentDir = Directory('/storage/emulated/0');
  ViewMode _viewMode = ViewMode.list;
  SortBy _sortBy = SortBy.name;
  bool _sortAsc = true;
  String? _searchQuery;
  bool _isSelectionMode = false;
  final Set<String> _selectedPaths = {};

  Directory get currentDir => _currentDir;
  ViewMode get viewMode => _viewMode;
  SortBy get sortBy => _sortBy;
  bool get sortAsc => _sortAsc;
  String? get searchQuery => _searchQuery;
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedPaths => _selectedPaths;

  List<FileItem> _items = [];
  List<FileItem> get items {
    var filtered = _items.where((item) {
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        return item.name.toLowerCase().contains(_searchQuery!.toLowerCase());
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      int cmp;
      switch (_sortBy) {
        case SortBy.name:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.size:
          cmp = a.size.compareTo(b.size);
          break;
        case SortBy.date:
          cmp = a.lastModified.compareTo(b.lastModified);
          break;
        case SortBy.type:
          cmp = a.fileType.name.compareTo(b.fileType.name);
          break;
      }
      return _sortAsc ? cmp : -cmp;
    });
    return filtered;
  }

  bool get isEmpty => items.isEmpty;
  bool get isSearching => _searchQuery != null && _searchQuery!.isNotEmpty;

  Future<void> requestPermissions() async {
    if (await Permission.manageExternalStorage.isGranted) {
      loadCurrentFolder();
      return;
    }
    if (await Permission.storage.isGranted) {
      loadCurrentFolder();
      return;
    }
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    loadCurrentFolder();
  }

  void loadCurrentFolder() {
    try {
      final entities = _currentDir.listSync();
      _items = entities
          .map((e) => FileItem.fromFile(File(e.path)))
          .toList();
      notifyListeners();
    } catch (e) {
      _items = [];
      notifyListeners();
    }
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSortBy(SortBy sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortAsc = !_sortAsc;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query?.isEmpty == true ? null : query;
    notifyListeners();
  }

  void navigateTo(Directory dir) {
    _currentDir = dir;
    _searchQuery = null;
    exitSelectionMode();
    loadCurrentFolder();
  }

  void navigateUp() {
    if (_currentDir.parent.path != _currentDir.path) {
      _currentDir = _currentDir.parent;
      loadCurrentFolder();
    }
  }

  void onItemTap(FileItem item) {
    if (_isSelectionMode) {
      toggleSelection(item.path);
    } else if (item.isDirectory) {
      navigateTo(Directory(item.path));
    } else if (item.name.toLowerCase().endsWith('.zip')) {
      // Decompress handled elsewhere
    } else {
      // Open file handled elsewhere
    }
  }

  void onItemLongPress(FileItem item) {
    if (!_isSelectionMode) {
      _isSelectionMode = true;
      _selectedPaths.add(item.path);
      notifyListeners();
    }
  }

  void toggleSelection(String path) {
    if (_selectedPaths.contains(path)) {
      _selectedPaths.remove(path);
    } else {
      _selectedPaths.add(path);
    }
    if (_selectedPaths.isEmpty) _isSelectionMode = false;
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedPaths.clear();
    notifyListeners();
  }

  String get selectionCountText => '${_selectedPaths.length} selecionado(s)';
}