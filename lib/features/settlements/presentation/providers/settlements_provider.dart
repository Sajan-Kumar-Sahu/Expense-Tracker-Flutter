import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/dependency_injection/injection.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';

class SettlementsProvider extends ChangeNotifier {
  final SettlementRepository repository;

  SettlementsProvider(this.repository) {
    loadAll();
  }

  bool isLoading = false;
  bool isActionLoading = false;
  List<SettlementEntity> settlements = [];
  SettlementEntity? selectedSettlement;
  SettlementSummaryEntity? summary;
  String? lastError;

  Future<void> loadAll() async {
    try {
      isLoading = true;
      notifyListeners();
      final results = await Future.wait([
        repository.getSettlements(),
        repository.getSummary(),
      ]);
      settlements = results[0] as List<SettlementEntity>;
      summary = results[1] as SettlementSummaryEntity;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadById(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      selectedSettlement = await repository.getSettlementById(id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSettlement(Map<String, dynamic> data) async {
    lastError = null;
    try {
      isActionLoading = true;
      notifyListeners();
      final settlement = await repository.createSettlement(data);
      settlements.insert(0, settlement);
      await _refreshSummary();
      return true;
    } catch (e) {
      lastError = _extractMessage(e);
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSettlement(String id, Map<String, dynamic> data) async {
    lastError = null;
    try {
      isActionLoading = true;
      notifyListeners();
      final updated = await repository.updateSettlement(id, data);
      _replaceInList(updated);
      if (selectedSettlement?.id == id) selectedSettlement = updated;
      return true;
    } catch (e) {
      lastError = _extractMessage(e);
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSettlement(String id) async {
    lastError = null;
    try {
      isActionLoading = true;
      notifyListeners();
      await repository.deleteSettlement(id);
      settlements.removeWhere((s) => s.id == id);
      if (selectedSettlement?.id == id) selectedSettlement = null;
      await _refreshSummary();
      return true;
    } catch (e) {
      lastError = _extractMessage(e);
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> receivePayment(String id, Map<String, dynamic> data) async {
    lastError = null;
    try {
      isActionLoading = true;
      notifyListeners();
      final updated = await repository.receivePayment(id, data);
      _replaceInList(updated);
      if (selectedSettlement?.id == id) selectedSettlement = updated;
      await _refreshSummary();
      return true;
    } catch (e) {
      lastError = _extractMessage(e);
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pay(String id, Map<String, dynamic> data) async {
    lastError = null;
    try {
      isActionLoading = true;
      notifyListeners();
      final updated = await repository.pay(id, data);
      _replaceInList(updated);
      if (selectedSettlement?.id == id) selectedSettlement = updated;
      await _refreshSummary();
      return true;
    } catch (e) {
      lastError = _extractMessage(e);
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancel(String id) async {
    lastError = null;
    try {
      isActionLoading = true;
      notifyListeners();
      final updated = await repository.cancel(id);
      _replaceInList(updated);
      if (selectedSettlement?.id == id) selectedSettlement = updated;
      await _refreshSummary();
      return true;
    } catch (e) {
      lastError = _extractMessage(e);
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  String _extractMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is NetworkException) return e.message;
    if (e is UnknownException) return e.message;
    return e.toString();
  }

  Future<void> _refreshSummary() async {
    try {
      summary = await repository.getSummary();
    } catch (_) {}
  }

  void _replaceInList(SettlementEntity updated) {
    final index = settlements.indexWhere((s) => s.id == updated.id);
    if (index != -1) settlements[index] = updated;
  }

  void reset() {
    settlements = [];
    selectedSettlement = null;
    summary = null;
    isLoading = false;
    isActionLoading = false;
    notifyListeners();
  }
}

final settlementsProvider =
    ChangeNotifierProvider<SettlementsProvider>((ref) {
  return SettlementsProvider(locator<SettlementRepository>());
});
