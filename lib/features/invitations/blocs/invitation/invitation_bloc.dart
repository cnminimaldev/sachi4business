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
    on<SaveInvitation>(_onSaveInvitation); // Đăng ký sự kiện lưu
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

  // --- NHÂN BẢN THIỆP (BẢN SẠCH KHÔNG KÈM ẢNH) ---
  Future<void> _onCloneInvitation(
    CloneInvitation event,
    Emitter<InvitationState> emit,
  ) async {
    emit(InvitationLoading());
    try {
      final old = event.oldInvitation;

      // 1. Tạo một bản sao của dynamic_data cũ để xử lý làm sạch dữ liệu ảnh
      final cleanDynamicData = Map<String, dynamic>.from(old.dynamicData);

      // 2. Loại bỏ ảnh QR Code nhận quà
      cleanDynamicData.remove('qr_code_url');

      // 3. Duyệt qua danh sách Our Stories (nếu có) để gỡ bỏ liên kết ảnh của từng cột mốc
      if (cleanDynamicData.containsKey('our_stories') &&
          cleanDynamicData['our_stories'] is List) {
        final List<dynamic> oldStories = cleanDynamicData['our_stories'];

        final cleanStories = oldStories.map((story) {
          if (story is Map) {
            final newStory = Map<String, dynamic>.from(story);
            newStory['image_url'] = ''; // Đưa đường dẫn ảnh minh họa về rỗng
            return newStory;
          }
          return story;
        }).toList();

        cleanDynamicData['our_stories'] = cleanStories;
      }

      final payload = {
        'title': '(Bản sao) ${old.title}',
        'template_id': old.templateId,
        'bride_name': old.brideName,
        'groom_name': old.groomName,
        'event_date': old.eventDate.toIso8601String(),
        'status': 'draft',
        'uploaded_images': <String>[],
        'cover_image_index': null,
        'dynamic_data': cleanDynamicData,
      };

      await Supabase.instance.client.from('invitations').insert(payload);

      emit(InvitationOperationSuccess('Nhân bản thiệp sạch thành công! 🎉'));
      add(LoadInvitations()); // Tải lại danh sách thiệp mới nhất
    } catch (e) {
      emit(InvitationError('Lỗi khi nhân bản thiệp: $e'));
    }
  }

  // --- LOGIC LƯU THIỆP ĐƯỢC THÊM MỚI ---
  Future<void> _onSaveInvitation(
    SaveInvitation event,
    Emitter<InvitationState> emit,
  ) async {
    emit(InvitationLoading());
    try {
      final invite = event.invitation;
      final payload = invite.toJson(); // Chuyển đổi Model thành JSON chuẩn

      if (invite.id.isEmpty) {
        // Tình huống: TẠO MỚI (Insert)
        // Bóc tách cột id ra để Supabase tự sinh UUID tự động
        payload.remove('id');
        await Supabase.instance.client.from('invitations').insert(payload);
        emit(InvitationOperationSuccess('Tạo thiệp mới thành công! 🌸'));
      } else {
        // Tình huống: CẬP NHẬT (Update)
        await Supabase.instance.client
            .from('invitations')
            .update(payload)
            .eq('id', invite.id);
        emit(InvitationOperationSuccess('Cập nhật thay đổi thành công! 🎉'));
      }
    } catch (e) {
      emit(InvitationError('Không thể lưu dữ liệu: $e'));
    }
  }
}
