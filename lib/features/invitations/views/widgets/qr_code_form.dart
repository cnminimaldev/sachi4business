// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// import 'dart:typed_data';

// import '../../../../core/theme/app_theme.dart';
// import '../../../../core/network/upload_service.dart';
// import '../../models/invitation.dart';

// class QRCodeForm extends StatefulWidget {
//   final SectionData section;
//   final VoidCallback onUpdate;

//   const QRCodeForm({super.key, required this.section, required this.onUpdate});

//   @override
//   State<QRCodeForm> createState() => _QRCodeFormState();
// }

// class _QRCodeFormState extends State<QRCodeForm> {
//   late TextEditingController _bankNameController;
//   late TextEditingController _accountNumController;
//   late TextEditingController _accountNameController;

//   @override
//   void initState() {
//     super.initState();
//     // Khởi tạo data cũ nếu có
//     _bankNameController = TextEditingController(
//       text: widget.section.content['bank_name'] ?? '',
//     );
//     _accountNumController = TextEditingController(
//       text: widget.section.content['account_num'] ?? '',
//     );
//     _accountNameController = TextEditingController(
//       text: widget.section.content['account_name'] ?? '',
//     );
//   }

//   @override
//   void dispose() {
//     _bankNameController.dispose();
//     _accountNumController.dispose();
//     _accountNameController.dispose();
//     super.dispose();
//   }

//   // Hàm âm thầm lưu text vào JSON
//   void _syncData() {
//     widget.section.content['bank_name'] = _bankNameController.text.trim();
//     widget.section.content['account_num'] = _accountNumController.text.trim();
//     widget.section.content['account_name'] = _accountNameController.text.trim();
//     widget.onUpdate();
//   }

//   // Hàm upload ảnh QR
//   Future<void> _uploadQRImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 800,
//       imageQuality: 80, // Mã QR cần nét một chút nên để 80
//     );

//     if (image != null) {
//       SmartDialog.showLoading(msg: 'Đang tải mã QR lên hệ thống 🌸...');
//       Uint8List fileBytes = await image.readAsBytes();
//       final publicUrl = await UploadService().uploadImageToR2(
//         fileBytes,
//         image.name,
//       );
//       SmartDialog.dismiss();

//       if (publicUrl != null) {
//         setState(() {
//           widget.section.content['qr_image_url'] = publicUrl;
//         });
//         widget.onUpdate();
//         SmartDialog.showToast('Tải mã QR thành công!');
//       } else {
//         SmartDialog.showToast('Có lỗi xảy ra khi tải ảnh.');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final qrImageUrl = widget.section.content['qr_image_url'] as String?;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 1. Cụm nhập thông tin Text
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _bankNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Tên Ngân hàng (VD: Vietcombank)',
//                 ),
//                 onChanged: (_) => _syncData(),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: TextField(
//                 controller: _accountNumController,
//                 decoration: const InputDecoration(labelText: 'Số tài khoản'),
//                 onChanged: (_) => _syncData(),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _accountNameController,
//           decoration: const InputDecoration(
//             labelText: 'Tên chủ tài khoản (VD: NGUYEN VAN A)',
//           ),
//           onChanged: (_) => _syncData(),
//         ),

//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 24.0),
//           child: Divider(),
//         ),

//         // 2. Cụm Upload ảnh QR
//         const Text(
//           'Hình ảnh Mã QR',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: AppTheme.textMain,
//           ),
//         ),
//         const SizedBox(height: 16),

//         Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             // Khung hiển thị ảnh QR
//             Container(
//               width: 150,
//               height: 150,
//               decoration: BoxDecoration(
//                 color: AppTheme.secondaryPink.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppTheme.secondaryPink),
//                 image: qrImageUrl != null && qrImageUrl.isNotEmpty
//                     ? DecorationImage(
//                         image: NetworkImage(qrImageUrl),
//                         fit: BoxFit.contain,
//                       )
//                     : null,
//               ),
//               child: qrImageUrl == null || qrImageUrl.isEmpty
//                   ? const Center(
//                       child: Text(
//                         'Chưa có ảnh QR',
//                         style: TextStyle(
//                           color: AppTheme.textLight,
//                           fontSize: 12,
//                         ),
//                       ),
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 24),
//             // Nút bấm Upload
//             ElevatedButton.icon(
//               onPressed: _uploadQRImage,
//               icon: const Icon(Icons.qr_code_2),
//               label: Text(
//                 qrImageUrl == null ? 'Tải ảnh QR lên' : 'Đổi ảnh QR khác',
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
