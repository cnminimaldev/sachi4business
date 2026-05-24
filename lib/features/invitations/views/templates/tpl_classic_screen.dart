// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../../../core/theme/app_theme.dart';
// import '../../models/invitation.dart';
// import '../../models/guest.dart'; // Đã cập nhật đúng đường dẫn import

// class TplClassicScreen extends StatefulWidget {
//   final Invitation invitation;
//   final Guest? guest;

//   const TplClassicScreen({super.key, required this.invitation, this.guest});

//   @override
//   State<TplClassicScreen> createState() => _TplClassicScreenState();
// }

// class _TplClassicScreenState extends State<TplClassicScreen> {
//   // Biến trạng thái phục vụ cho Form RSVP
//   String? _selectedRsvp;
//   int _paxCount = 1;
//   bool _isSubmitted = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.guest != null) {
//       _selectedRsvp = widget.guest!.rsvpStatus != 'pending'
//           ? widget.guest!.rsvpStatus
//           : null;
//       _paxCount = widget.guest!.paxCount;
//     }
//   }

//   // Hàm xử lý hoán đổi từ khóa xưng hô cá nhân hóa
//   String _localizeText(String text) {
//     if (widget.guest == null) {
//       return text
//           .replaceAll('{{danh_xung}}', 'Quý khách')
//           .replaceAll('{{ten_khach}}', '')
//           .replaceAll('{{hau_to}}', '')
//           .replaceAll('  ', ' ')
//           .trim();
//     }

//     return text
//         .replaceAll('{{danh_xung}}', widget.guest!.guestTitle)
//         .replaceAll('{{ten_khach}}', widget.guest!.guestName)
//         .replaceAll('{{hau_to}}', widget.guest!.guestSuffix ?? '')
//         .replaceAll('  ', ' ')
//         .trim();
//   }

//   // Hàm gửi phản hồi RSVP lên Supabase
//   Future<void> _submitRsvp() async {
//     if (widget.guest == null || _selectedRsvp == null) return;

//     SmartDialog.showLoading(msg: 'Đang gửi phản hồi của bạn 🌸...');
//     try {
//       await Supabase.instance.client
//           .from('guests')
//           .update({
//             'rsvp_status': _selectedRsvp,
//             'pax_count': _selectedRsvp == 'attending' ? _paxCount : 0,
//           })
//           .eq('id', widget.guest!.id);

//       SmartDialog.dismiss();
//       setState(() => _isSubmitted = true);
//       SmartDialog.showToast('Cảm ơn bạn đã phản hồi! 🎉');
//     } catch (e) {
//       SmartDialog.dismiss();
//       SmartDialog.showToast('Gặp lỗi khi gửi phản hồi: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         // Ảnh bìa - Đã sửa lỗi gọi biến qua widget.invitation
//         SliverAppBar(
//           expandedHeight: MediaQuery.of(context).size.height * 0.65,
//           backgroundColor: AppTheme.backgroundCream,
//           automaticallyImplyLeading: false,
//           pinned: false,
//           flexibleSpace: FlexibleSpaceBar(
//             background: Image.network(
//               widget.invitation.coverUrl,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),

//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
//             child: Column(
//               children: [
//                 const Text(
//                   'SAVE THE DATE',
//                   style: TextStyle(
//                     fontSize: 13,
//                     letterSpacing: 4,
//                     color: AppTheme.textLight,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 Text(
//                   _localizeText(
//                     'TRÂN TRỌNG KÍNH MỜI {{danh_xung}} {{ten_khach}} {{hau_to}}',
//                   ),
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     letterSpacing: 1,
//                     color: AppTheme.deepPink,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 16),
//                 // Đã sửa lỗi gọi biến qua widget.invitation
//                 Text(
//                   '${widget.invitation.brideName} & ${widget.invitation.groomName}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 38,
//                     fontWeight: FontWeight.w300,
//                     color: AppTheme.deepPink,
//                     height: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: AppTheme.primaryPink.withOpacity(0.3),
//                     ),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   // Đã sửa lỗi gọi biến qua widget.invitation
//                   child: Text(
//                     DateFormat(
//                       'EEEE, dd/MM/yyyy',
//                     ).format(widget.invitation.eventDate),
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: AppTheme.textMain,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 56),

//                 // Vòng lặp Render các Section - Đã sửa lỗi sang widget.invitation
//                 ...widget.invitation.sections.where((s) => s.isActive).map((
//                   section,
//                 ) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 56.0),
//                     child: _buildSectionContent(context, section),
//                   );
//                 }),

//                 // Khối khảo sát RSVP nếu có khách mời xác định
//                 if (widget.guest != null) ...[
//                   _buildRsvpFormBlock(),
//                   const SizedBox(height: 56),
//                 ],

//                 // Lời cảm ơn cuối trang
//                 const Padding(
//                   padding: EdgeInsets.only(top: 24, bottom: 48),
//                   child: Text(
//                     'Sự hiện diện của bạn\nlà niềm vinh hạnh lớn cho chúng tôi.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontStyle: FontStyle.italic,
//                       color: AppTheme.textLight,
//                       height: 1.6,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionContent(BuildContext context, SectionData section) {
//     switch (section.type) {
//       case 'our_story':
//         final text = section.content['text'] ?? '';
//         if (text.isEmpty) return const SizedBox.shrink();
//         return Column(
//           children: [
//             _buildSectionTitle(section.title),
//             Text(
//               _localizeText(text),
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 15,
//                 height: 1.8,
//                 color: AppTheme.textMain,
//               ),
//             ),
//           ],
//         );

//       case 'timeline':
//         final items = section.content['items'] as List<dynamic>? ?? [];
//         if (items.isEmpty) return const SizedBox.shrink();
//         return Column(
//           children: [
//             _buildSectionTitle(section.title),
//             ...items.map(
//               (item) => Padding(
//                 padding: const EdgeInsets.only(bottom: 24.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 65,
//                       child: Text(
//                         item['time'] ?? '',
//                         textAlign: TextAlign.right,
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                           color: AppTheme.primaryPink,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item['title'] ?? '',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: AppTheme.textMain,
//                             ),
//                           ),
//                           if ((item['desc'] ?? '').toString().isNotEmpty) ...[
//                             const SizedBox(height: 6),
//                             Text(
//                               item['desc'],
//                               style: const TextStyle(
//                                 color: AppTheme.textLight,
//                                 height: 1.4,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );

//       case 'gallery':
//         final images = section.content['images'] as List<dynamic>? ?? [];
//         if (images.isEmpty) return const SizedBox.shrink();
//         return Column(
//           children: [
//             _buildSectionTitle(section.title),
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: images.length,
//               separatorBuilder: (c, i) => const SizedBox(height: 16),
//               itemBuilder: (context, index) {
//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.network(
//                     images[index].toString(),
//                     fit: BoxFit.cover,
//                   ),
//                 );
//               },
//             ),
//           ],
//         );

//       case 'qr_code':
//         final bankName = section.content['bank_name'] ?? '';
//         final accountNum = section.content['account_num'] ?? '';
//         final accountName = section.content['account_name'] ?? '';
//         final qrImageUrl = section.content['qr_image_url'] as String?;

//         return Column(
//           children: [
//             _buildSectionTitle(section.title),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: AppTheme.surfaceWhite,
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: AppTheme.secondaryPink.withOpacity(0.3),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   if (qrImageUrl != null && qrImageUrl.isNotEmpty) ...[
//                     Container(
//                       width: 180,
//                       height: 180,
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.03),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(qrImageUrl, fit: BoxFit.contain),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                   Text(
//                     bankName.toString().toUpperCase(),
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: AppTheme.textLight,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     accountNum,
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: AppTheme.deepPink,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Chủ TK: ${accountName.toString().toUpperCase()}',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: AppTheme.textMain,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextButton.icon(
//                     style: TextButton.styleFrom(
//                       backgroundColor: AppTheme.backgroundCream,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 10,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     onPressed: () {
//                       Clipboard.setData(ClipboardData(text: accountNum));
//                       SmartDialog.showToast('Đã sao chép số tài khoản! 📋');
//                     },
//                     icon: const Icon(
//                       Icons.copy,
//                       size: 16,
//                       color: AppTheme.deepPink,
//                     ),
//                     label: const Text(
//                       'Sao chép số tài khoản',
//                       style: TextStyle(
//                         color: AppTheme.deepPink,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );

//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildRsvpFormBlock() {
//     return Column(
//       children: [
//         _buildSectionTitle('Xác nhận tham dự'),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: AppTheme.surfaceWhite,
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(color: AppTheme.primaryPink.withOpacity(0.2)),
//           ),
//           child: _isSubmitted
//               ? const Column(
//                   children: [
//                     Icon(
//                       Icons.check_circle_outline,
//                       color: Colors.green,
//                       size: 48,
//                     ),
//                     SizedBox(height: 12),
//                     Text(
//                       'Phản hồi thành công!',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.textMain,
//                       ),
//                     ),
//                     SizedBox(height: 6),
//                     Text(
//                       'Sachi xin trân trọng cảm ơn bạn rất nhiều 🌸',
//                       style: TextStyle(fontSize: 13, color: AppTheme.textLight),
//                     ),
//                   ],
//                 )
//               : Column(
//                   children: [
//                     Text(
//                       _localizeText(
//                         'Chào {{danh_xung}} {{ten_khach}}, {{danh_xung}} sẽ đến chung vui cùng tụi em chứ ạ?',
//                       ),
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: AppTheme.textMain,
//                         height: 1.5,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             style: OutlinedButton.styleFrom(
//                               backgroundColor: _selectedRsvp == 'attending'
//                                   ? AppTheme.primaryPink.withOpacity(0.1)
//                                   : Colors.transparent,
//                               side: BorderSide(
//                                 color: _selectedRsvp == 'attending'
//                                     ? AppTheme.primaryPink
//                                     : Colors.grey.shade300,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             onPressed: () =>
//                                 setState(() => _selectedRsvp = 'attending'),
//                             child: Text(
//                               'Sẽ tham dự 🥂',
//                               style: TextStyle(
//                                 color: _selectedRsvp == 'attending'
//                                     ? AppTheme.deepPink
//                                     : AppTheme.textMain,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: OutlinedButton(
//                             style: OutlinedButton.styleFrom(
//                               backgroundColor: _selectedRsvp == 'declined'
//                                   ? Colors.red.shade50
//                                   : Colors.transparent,
//                               side: BorderSide(
//                                 color: _selectedRsvp == 'declined'
//                                     ? Colors.redAccent
//                                     : Colors.grey.shade300,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                             ),
//                             onPressed: () =>
//                                 setState(() => _selectedRsvp = 'declined'),
//                             child: Text(
//                               'Rất tiếc không thể đến',
//                               style: TextStyle(
//                                 color: _selectedRsvp == 'declined'
//                                     ? Colors.redAccent
//                                     : AppTheme.textMain,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (_selectedRsvp == 'attending') ...[
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Số người đi cùng:',
//                             style: TextStyle(
//                               color: AppTheme.textMain,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.remove_circle_outline,
//                               color: AppTheme.primaryPink,
//                             ),
//                             onPressed: _paxCount > 1
//                                 ? () => setState(() => _paxCount--)
//                                 : null,
//                           ),
//                           Text(
//                             '$_paxCount',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.deepPink,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.add_circle_outline,
//                               color: AppTheme.primaryPink,
//                             ),
//                             onPressed: () => setState(() => _paxCount++),
//                           ),
//                         ],
//                       ),
//                     ],
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.deepPink,
//                         minimumSize: const Size(double.infinity, 46),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         elevation: 0,
//                       ),
//                       onPressed: _selectedRsvp != null ? _submitRsvp : null,
//                       child: const Text(
//                         'Gửi phản hồi cho cô dâu & chú rể',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 24.0),
//       child: Column(
//         children: [
//           Text(
//             title.toUpperCase(),
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 16,
//               letterSpacing: 2,
//               fontWeight: FontWeight.w600,
//               color: AppTheme.deepPink,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             width: 24,
//             height: 1.5,
//             color: AppTheme.primaryPink.withOpacity(0.4),
//           ),
//         ],
//       ),
//     );
//   }
// }
