// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';

// import '../../models/invitation.dart';
// import '../../blocs/invitation/invitation_bloc.dart';
// import '../../blocs/invitation/invitation_event.dart';

// class InvitationCard extends StatelessWidget {
//   final Invitation invitation;
//   final bool
//   isGrid; // Nhận biến báo hiệu đang ở chế độ nào để điều chỉnh UI nếu cần

//   const InvitationCard({
//     super.key,
//     required this.invitation,
//     this.isGrid = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final statusConfig = _getStatusConfig(invitation.status);

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Cột Trái: Ảnh bìa
//               Container(
//                 width: isGrid
//                     ? 100
//                     : 120, // Thu nhỏ ảnh một chút nếu ở dạng Grid
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEFEFE9),
//                   image: DecorationImage(
//                     image: NetworkImage(invitation.coverUrl),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),

//               // Cột Phải: Nội dung & Nút bấm
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // --- Tiêu đề & Trạng thái ---
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               invitation.title,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1A1A1A),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: statusConfig.color.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               statusConfig.label,
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w600,
//                                 color: statusConfig.color,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),

//                       // --- Thông tin phụ ---
//                       Text(
//                         'Dâu: ${invitation.brideName} • Rể: ${invitation.groomName}',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today_rounded,
//                             size: 14,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             DateFormat(
//                               'dd/MM/yyyy',
//                             ).format(invitation.eventDate),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),

//                       const Spacer(),

//                       // ---> KHÔI PHỤC: DÀN ICON BUTTONS THAO TÁC NHANH <---
//                       Divider(color: Colors.grey.withOpacity(0.1), height: 1),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.link_rounded),
//                             color: Colors.blueGrey,
//                             tooltip: 'Copy Link',
//                             onPressed: () async {
//                               final link =
//                                   'https://sachi.com/invite/${invitation.id}';
//                               await Clipboard.setData(
//                                 ClipboardData(text: link),
//                               );
//                               if (context.mounted) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Đã copy link thiệp!'),
//                                     duration: Duration(seconds: 2),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.edit_note_rounded),
//                             color: const Color(0xFF4A90E2),
//                             tooltip: 'Chỉnh sửa',
//                             onPressed: () async {
//                               await context.push(
//                                 '/invitations/editor',
//                                 extra: invitation,
//                               );
//                               if (context.mounted) {
//                                 context.read<InvitationBloc>().add(
//                                   LoadInvitations(),
//                                 );
//                               }
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.copy_all_rounded),
//                             color: const Color(0xFF7A8266),
//                             tooltip: 'Nhân bản',
//                             onPressed: () {
//                               _showConfirmDialog(
//                                 context: context,
//                                 title: 'Nhân bản thiệp',
//                                 content:
//                                     'Tạo một bản sao sạch (không kèm hình ảnh) của thiệp này?',
//                                 onConfirm: () => context
//                                     .read<InvitationBloc>()
//                                     .add(CloneInvitation(invitation)),
//                               );
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete_outline_rounded),
//                             color: const Color(0xFFE26D6D),
//                             tooltip: 'Xóa',
//                             onPressed: () {
//                               _showConfirmDialog(
//                                 context: context,
//                                 title: 'Xóa thiệp cưới',
//                                 content:
//                                     'Bạn có chắc chắn muốn xóa thiệp "${invitation.title}" không?',
//                                 isDestructive: true,
//                                 onConfirm: () => context
//                                     .read<InvitationBloc>()
//                                     .add(DeleteInvitation(invitation.id)),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showConfirmDialog({
//     required BuildContext context,
//     required String title,
//     required String content,
//     required VoidCallback onConfirm,
//     bool isDestructive = false,
//   }) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(dialogContext);
//               onConfirm();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: isDestructive
//                   ? Colors.redAccent
//                   : const Color(0xFFE26D6D),
//               foregroundColor: Colors.white,
//               elevation: 0,
//             ),
//             child: const Text('Xác nhận'),
//           ),
//         ],
//       ),
//     );
//   }

//   _StatusConfig _getStatusConfig(String status) {
//     switch (status) {
//       case 'active':
//         return _StatusConfig(Colors.green.shade600, 'Đang chạy');
//       case 'draft':
//         return _StatusConfig(Colors.orange.shade600, 'Bản nháp');
//       default:
//         return _StatusConfig(Colors.grey.shade600, 'Không rõ');
//     }
//   }
// }

// class _StatusConfig {
//   final Color color;
//   final String label;
//   _StatusConfig(this.color, this.label);
// }
