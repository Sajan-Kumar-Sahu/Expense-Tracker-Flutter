import '../entities/settlement_entity.dart';

abstract class SettlementRepository {
  Future<List<SettlementEntity>> getSettlements();
  Future<List<SettlementEntity>> getReceivables();
  Future<List<SettlementEntity>> getPayables();
  Future<SettlementEntity> getSettlementById(String id);
  Future<SettlementSummaryEntity> getSummary();
  Future<SettlementEntity> createSettlement(Map<String, dynamic> data);
  Future<SettlementEntity> updateSettlement(String id, Map<String, dynamic> data);
  Future<void> deleteSettlement(String id);
  Future<SettlementEntity> receivePayment(String id, Map<String, dynamic> data);
  Future<SettlementEntity> pay(String id, Map<String, dynamic> data);
  Future<SettlementEntity> cancel(String id);
}
