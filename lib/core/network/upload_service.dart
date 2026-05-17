import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadImageToR2(Uint8List fileBytes, String fileName) async {
    try {
      // 1. Nhận diện loại file (MIME type) tự động
      final ext = fileName.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg'; // Mặc định
      if (ext == 'png') mimeType = 'image/png';
      if (ext == 'webp') mimeType = 'image/webp';
      if (ext == 'gif') mimeType = 'image/gif';

      // 2. Gọi Edge Function
      final response = await _supabase.functions.invoke(
        'generate_r2_url',
        body: {
          'fileName': fileName,
          'fileType': mimeType, // Truyền đúng MIME type xuống Backend
        },
      );

      final data = response.data;
      if (data == null || data['signedUrl'] == null) {
        throw Exception("Không thể lấy URL tải lên từ máy chủ.");
      }

      final String signedUrl = data['signedUrl'];
      final String publicUrl = data['publicUrl'];

      // 3. Đẩy file lên R2 (Đảm bảo Content-Type khớp 100%)
      final putResponse = await http.put(
        Uri.parse(signedUrl),
        headers: {'Content-Type': mimeType},
        body: fileBytes,
      );

      if (putResponse.statusCode == 200) {
        return publicUrl;
      } else {
        throw Exception(
          "Lỗi khi đẩy file lên R2: ${putResponse.statusCode} - ${putResponse.body}",
        );
      }
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
}
