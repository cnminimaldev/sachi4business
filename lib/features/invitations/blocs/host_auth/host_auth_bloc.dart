import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/invitation.dart';
import 'host_auth_event.dart';
import 'host_auth_state.dart';

class HostAuthBloc extends Bloc<HostAuthEvent, HostAuthState> {
  final SupabaseClient _supabase;

  HostAuthBloc({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client,
      super(HostAuthInitial()) {
    on<VerifyPinRequested>(_onVerifyPin);
  }

  Future<void> _onVerifyPin(
    VerifyPinRequested event,
    Emitter<HostAuthState> emit,
  ) async {
    emit(HostAuthLoading());
    try {
      // Gọi thẳng RPC trên server
      final response = await _supabase.rpc(
        'verify_host_pin',
        params: {'p_token': event.token, 'p_pin': event.pin},
      );

      final String status = response['status'];

      switch (status) {
        case 'SUCCESS':
          final invitation = Invitation.fromJson(response['invitation']);
          emit(HostAuthSuccess(invitation));
          break;
        case 'LOCKED':
          final lockoutTime = DateTime.parse(
            response['lockout_until'],
          ).toLocal();
          emit(HostAuthLocked(lockoutTime, response['message']));
          break;
        case 'WRONG_PIN':
          final remaining = response['remaining_attempts'];
          emit(
            HostAuthFailure(
              '${response['message']} Bạn còn $remaining lần thử!',
            ),
          );
          break;
        case 'NOT_FOUND':
        default:
          emit(HostAuthFailure(response['message'] ?? 'Lỗi không xác định.'));
      }
    } catch (e) {
      emit(HostAuthFailure('Lỗi kết nối máy chủ. Vui lòng thử lại.'));
    }
  }
}
