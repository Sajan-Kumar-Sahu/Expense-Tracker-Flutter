import '../../../../core/common/result.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart' as f;
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _dataSource;

  DashboardRepositoryImpl(this._dataSource);

  @override
  Future<Result<DashboardSummaryEntity>> getSummary() async {
    try {
      final response = await _dataSource.getDashboard();
      return Success(response.toEntity());
    } on ServerException catch (e) {
      return Failure(f.ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Failure(f.NetworkFailure(e.message));
    } catch (e) {
      return Failure(f.UnknownFailure(e.toString()));
    }
  }
}
