import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

import '../../models/guest.dart';
import 'guest_event.dart';
import 'guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  GuestBloc() : super(GuestInitial()) {
    on<LoadGuests>(_onLoadGuests);
    on<AddGuest>(_onAddGuest);
    on<DeleteGuest>(_onDeleteGuest);
  }

  // HÀM HỖ TRỢ: Sinh mã ngắn
  String _generateShortCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  // HÀM HỖ TRỢ: Tải lại danh sách (để tái sử dụng)
  Future<List<Guest>> _fetchGuestsList(String invitationId) async {
    final response = await Supabase.instance.client
        .from('guests')
        .select()
        .eq('invitation_id', invitationId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Guest.fromJson(json)).toList();
  }

  // --- XỬ LÝ SỰ KIỆN TẢI DANH SÁCH ---
  Future<void> _onLoadGuests(LoadGuests event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    try {
      final guests = await _fetchGuestsList(event.invitationId);
      emit(GuestLoaded(guests));
    } catch (e) {
      emit(GuestError('Lỗi tải danh sách khách: $e'));
    }
  }

  // --- XỬ LÝ SỰ KIỆN THÊM KHÁCH MỜI ---
  Future<void> _onAddGuest(AddGuest event, Emitter<GuestState> emit) async {
    emit(GuestLoading());
    try {
      final guestCode = _generateShortCode();

      await Supabase.instance.client.from('guests').insert({
        'invitation_id': event.invitationId,
        'guest_title': event.title.trim(),
        'guest_name': event.name.trim(),
        'guest_suffix': event.suffix.trim().isEmpty
            ? null
            : event.suffix.trim(),
        'note': event.note.trim().isEmpty ? null : event.note.trim(),
        'guest_code': guestCode,
      });

      // Báo thành công để UI hiện Toast
      emit(GuestOperationSuccess('Thêm khách mời thành công!'));

      // Tải lại danh sách mới nhất
      final guests = await _fetchGuestsList(event.invitationId);
      emit(GuestLoaded(guests));
    } catch (e) {
      emit(GuestError('Lỗi khi thêm khách: $e'));
    }
  }

  // --- XỬ LÝ SỰ KIỆN XÓA KHÁCH MỜI ---
  Future<void> _onDeleteGuest(
    DeleteGuest event,
    Emitter<GuestState> emit,
  ) async {
    emit(GuestLoading());
    try {
      await Supabase.instance.client
          .from('guests')
          .delete()
          .eq('id', event.guestId);

      emit(GuestOperationSuccess('Đã xóa khách mời!'));

      // Tải lại danh sách
      final guests = await _fetchGuestsList(event.invitationId);
      emit(GuestLoaded(guests));
    } catch (e) {
      emit(GuestError('Lỗi khi xóa khách: $e'));
    }
  }
}
