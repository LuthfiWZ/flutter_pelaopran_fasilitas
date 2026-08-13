import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:image_picker/image_picker.dart' show XFile;

import '../models/category.dart';
import '../models/report.dart';
import '../services/api_client.dart';
import '../services/category_service.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  final CategoryService _categoryService = CategoryService();

  List<Report> _reports = [];
  List<Category> _categories = [];
  Map<String, dynamic>? _stats;

  bool _loading = false;
  final bool _loadingMore = false;
  String? _error;

  // Filter untuk admin
  String? _filterStatus;
  int? _filterCategoryId;
  String? _searchQuery;

  List<Report> get reports => _reports;
  List<Category> get categories => _categories;
  Map<String, dynamic>? get stats => _stats;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  String? get filterStatus => _filterStatus;
  int? get filterCategoryId => _filterCategoryId;

  /// Mengambil daftar laporan (otomatis menyesuaikan role user/admin).
  Future<void> loadReports() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _reportService.getReports(
        status: _filterStatus,
        categoryId: _filterCategoryId,
        search: _searchQuery,
      );
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _categoryService.getCategories();
      notifyListeners();
    } catch (_) {
      // kategori opsional untuk form; error ditampilkan saat submit
    }
  }

  /// CRUD kategori (hanya admin).
  Future<bool> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      final category = await _categoryService.createCategory(
        name: name,
        description: description,
      );
      _categories = [..._categories, category]
        ..sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory({
    required int id,
    required String name,
    String? description,
  }) async {
    try {
      final updated = await _categoryService.updateCategory(
        id: id,
        name: name,
        description: description,
      );
      _categories = _categories.map((c) => c.id == id ? updated : c).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _categoryService.deleteCategory(id);
      _categories = _categories.where((c) => c.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
      return false;
    }
  }

  /// Statistik dashboard admin.
  Future<void> loadStats() async {
    try {
      _stats = await _reportService.getStats();
      notifyListeners();
    } catch (e) {
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
    }
  }

  Future<Report?> getReportById(int id) async {
    try {
      final report = await _reportService.getReport(id);
      _reports = _reports
          .map((r) => r.id == id ? report : r)
          .toList(growable: false);
      notifyListeners();
      return report;
    } catch (e) {
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
      return null;
    }
  }

  Future<bool> createReport({
    required int categoryId,
    required String title,
    required String description,
    required String location,
    String? building,
    String? room,
    XFile? photo,
  }) async {
    try {
      await _reportService.createReport(
        categoryId: categoryId,
        title: title,
        description: description,
        location: location,
        building: building,
        room: room,
        photo: photo,
      );
      await loadReports();
      return true;
    } catch (e) {
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus({
    required int reportId,
    required String status,
    String? note,
    XFile? photo,
  }) async {
    try {
      final updated = await _reportService.updateStatus(
        reportId: reportId,
        status: status,
        note: note,
        photo: photo,
      );
      _reports = _reports.map((r) => r.id == reportId ? updated : r).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReport(int id) async {
    try {
      await _reportService.deleteReport(id);
      _reports = _reports.where((r) => r.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = ApiClient.errorMessage(e as dynamic);
      notifyListeners();
      return false;
    }
  }

  void setFilterStatus(String? status) {
    _filterStatus = status;
    loadReports();
  }

  void setFilterCategory(int? categoryId) {
    _filterCategoryId = categoryId;
    loadReports();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    loadReports();
  }
}
