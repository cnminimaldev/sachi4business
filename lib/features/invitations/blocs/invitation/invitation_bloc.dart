import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/invitation.dart';
import 'invitation_event.dart';
import 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  InvitationBloc() : super(InvitationInitial()) {
    on<LoadInvitations>(_onLoadInvitations);
    on<DeleteInvitation>(_onDeleteInvitation);
    on<CloneInvitation>(_onCloneInvitation);
  }

  // --- TẢI DANH SÁCH ---
  Future<void> _onLoadInvitations(
    LoadInvitations event,
    Emitter<InvitationState> emit,
  ) async {
    emit(InvitationLoading());
    try {
      final response = await Supabase.instance.client
          .from('invitations')
          .select()
          .order('created_at', ascending: false);

      final invitations = (response as List)
          .map((json) => Invitation.fromJson(json))
          .toList();
      emit(InvitationsLoaded(invitations));
    } catch (e) {
      emit(InvitationError('Lỗi tải danh sách thiệp: $e'));
    }
  }

  // --- XÓA THIỆP ---
  Future<void> _onDeleteInvitation(
    DeleteInvitation event,
    Emitter<InvitationState> emit,
  ) async {
    emit(InvitationLoading());
    try {
      await Supabase.instance.client
          .from('invitations')
          .delete()
          .eq('id', event.id);

      emit(InvitationOperationSuccess('Đã xóa thiệp thành công! 🗑️'));
      add(LoadInvitations());
    } catch (e) {
      emit(InvitationError('Lỗi khi xóa thiệp: $e'));
    }
  }

  // --- NHÂN BẢN THIỆP ---
  Future<void> _onCloneInvitation(
    CloneInvitation event,
    Emitter<InvitationState> emit,
  ) async {
    emit(InvitationLoading());
    try {
      final old = event.oldInvitation;

      // Xử lý tạo ID mới cho các section
      final List<Map<String, dynamic>> sectionsJson = old.sections.map((
        section,
      ) {
        return {
          'id': '${DateTime.now().millisecondsSinceEpoch}_${section.type}',
          'type': section.type,
          'title': section.title,
          'isActive': section.isActive,
          'content': section.content,
        };
      }).toList();

      final payload = {
        'template_id': old.templateId,
        'bride_name': '${old.brideName} (Bản sao)',
        'groom_name': old.groomName,
        'event_date': old.eventDate.toIso8601String(),
        'status': 'draft',
        'sections': sectionsJson,
        'cover_url': old.coverUrl,
      };

      await Supabase.instance.client.from('invitations').insert(payload);

      emit(InvitationOperationSuccess('Nhân bản thành công! 🎉'));
      add(LoadInvitations());
    } catch (e) {
      emit(InvitationError('Lỗi khi nhân bản: $e'));
    }
  }
}
