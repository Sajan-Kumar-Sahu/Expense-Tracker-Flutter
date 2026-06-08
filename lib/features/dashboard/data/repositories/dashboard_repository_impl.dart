import '../../../../core/common/result.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Skeleton implementation of the DashboardRepository contract.
class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<Result<DashboardSummaryEntity>> getSummary() async {
    return const Success(
      DashboardSummaryEntity(
        totalBalance: 0.00,
        totalIncome: 0.00,
        totalExpense: 0.00,
        recentTransactions: [],
      ),
    );
  }
}
