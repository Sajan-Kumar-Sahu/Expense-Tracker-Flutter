import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../datasources/settlement_remote_datasource.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final SettlementRemoteDataSource remoteDataSource;

  SettlementRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SettlementEntity>> getSettlements() async {
    final list = await remoteDataSource.getSettlements();
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<SettlementEntity>> getReceivables() async {
    final list = await remoteDataSource.getReceivables();
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<SettlementEntity>> getPayables() async {
    final list = await remoteDataSource.getPayables();
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<SettlementEntity> getSettlementById(String id) async {
    final response = await remoteDataSource.getSettlementById(id);
    return response.toEntity();
  }

  @override
  Future<SettlementSummaryEntity> getSummary() async {
    final response = await remoteDataSource.getSummary();
    return response.toEntity();
  }

  @override
  Future<SettlementEntity> createSettlement(Map<String, dynamic> data) async {
    final response = await remoteDataSource.createSettlement(data);
    return response.toEntity();
  }

  @override
  Future<SettlementEntity> updateSettlement(
      String id, Map<String, dynamic> data) async {
    final response = await remoteDataSource.updateSettlement(id, data);
    return response.toEntity();
  }

  @override
  Future<void> deleteSettlement(String id) async {
    await remoteDataSource.deleteSettlement(id);
  }

  @override
  Future<SettlementEntity> receivePayment(
      String id, Map<String, dynamic> data) async {
    final response = await remoteDataSource.receivePayment(id, data);
    return response.toEntity();
  }

  @override
  Future<SettlementEntity> pay(String id, Map<String, dynamic> data) async {
    final response = await remoteDataSource.pay(id, data);
    return response.toEntity();
  }

  @override
  Future<SettlementEntity> cancel(String id) async {
    final response = await remoteDataSource.cancel(id);
    return response.toEntity();
  }
}
