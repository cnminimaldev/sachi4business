import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../repositories/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc({required DashboardRepository repository})
    : _repository = repository,
      super(DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final data = await _repository.getDashboardSummary();
      emit(DashboardLoaded(data));
    } catch (e) {
      // Bắt lỗi và hiển thị thông báo an toàn
      emit(
        DashboardError('Không thể tải dữ liệu tổng quan. Vui lòng thử lại.'),
      );
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // Không emit Loading để tránh nháy màn hình nếu đang dùng Pull-to-refresh
    try {
      final data = await _repository.getDashboardSummary();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError('Lỗi khi làm mới dữ liệu.'));
    }
  }
}
