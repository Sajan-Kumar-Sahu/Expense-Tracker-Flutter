import '../../../../core/common/result.dart';
import '../entities/dashboard_entity.dart';

/// Contract definition for Dashboard data.
abstract class DashboardRepository {
  Future<Result<DashboardSummaryEntity>> getSummary();
}
