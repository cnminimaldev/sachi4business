import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class UploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- HÀM UPLOAD ẢNH ĐÃ CÓ ---
  Future<String?> uploadImageToR2(Uint8List fileBytes, String fileName) async {
    try {
      // Gọi Edge Function để lấy Presigned URL
      final response = await _supabase.functions.invoke(
        'generate_r2_url',
        body: {'fileName': fileName, 'fileType': 'image/jpeg'},
      );

      final data = response.data as Map<String, dynamic>;
      final signedUrl = data['signedUrl'] as String;
      final publicUrl = data['publicUrl'] as String;

      // Dùng http package để đẩy byte ảnh thẳng lên R2 qua signedUrl
      final uploadResponse = await http.put(
        Uri.parse(signedUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: fileBytes,
      );

      if (uploadResponse.statusCode == 200) {
        return publicUrl;
      } else {
        print('Lỗi upload HTTP: ${uploadResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('Lỗi UploadService: $e');
      return null;
    }
  }

  // --- HÀM MỚI: XOÁ ẢNH TRÊN R2 ---
  Future<bool> deleteFromR2(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return false;

      // 1. Bóc tách URL để lấy Key (Tên file)
      // Ví dụ URL: https://custom-domain.com/invitations/171567_image.jpg
      // -> Cần lấy ra: "invitations/171567_image.jpg"
      final uri = Uri.parse(imageUrl);
      String fileKey = uri.path;

      // Xoá dấu '/' ở đầu nếu có (Uri.path thường trả về dạng "/invitations/...")
      if (fileKey.startsWith('/')) {
        fileKey = fileKey.substring(1);
      }

      print('🧹 Đang gọi lệnh xoá file mồ côi: $fileKey');

      // 2. Gọi Edge Function delete_r2_file
      final response = await _supabase.functions.invoke(
        'delete_r2_file',
        body: {'fileName': fileKey},
      );

      if (response.status == 200) {
        print('✅ Đã xoá file thành công trên R2.');
        return true;
      } else {
        print('❌ Lỗi từ Supabase Function: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Lỗi ngoại lệ khi xoá file trên R2: $e');
      return false; // Nuốt lỗi, không làm gián đoạn UI của người dùng
    }
  }
}
