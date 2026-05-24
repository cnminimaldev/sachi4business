// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/theme/app_theme.dart';
// import '../../models/invitation.dart';

// class TplMinimalistScreen extends StatelessWidget {
//   final Invitation invitation;

//   const TplMinimalistScreen({super.key, required this.invitation});

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         // Ảnh bìa chiếm phần lớn không gian phía trên mẫu thiết kế
//         SliverAppBar(
//           expandedHeight: MediaQuery.of(context).size.height * 0.6,
//           backgroundColor: AppTheme.backgroundCream,
//           automaticallyImplyLeading: false,
//           pinned: false,
//           flexibleSpace: FlexibleSpaceBar(
//             background: Image.network(
//               invitation.coverUrl,
//               fit: BoxFit.cover,
//               errorBuilder: (c, e, s) =>
//                   Container(color: AppTheme.secondaryPink.withOpacity(0.2)),
//             ),
//           ),
//         ),

//         // Nội dung chi tiết được căn chỉnh mềm mại theo phong cách tối giản
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//             child: Column(
//               children: [
//                 const Text(
//                   'TRÂN TRỌNG KÍNH MỜI',
//                   style: TextStyle(
//                     fontSize: 12,
//                     letterSpacing: 2.5,
//                     color: AppTheme.textLight,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   '${invitation.brideName} & ${invitation.groomName}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.w300,
//                     color: AppTheme.deepPink,
//                     height: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   DateFormat('EEEE, dd/MM/yyyy').format(invitation.eventDate),
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: AppTheme.textMain,
//                   ),
//                 ),
//                 const SizedBox(height: 48),

//                 // Vòng lặp tự động bóc tách dữ liệu JSON để vẽ UI may đo tương ứng
//                 ...invitation.sections.where((s) => s.isActive).map((section) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 48.0),
//                     child: _buildSectionContent(section),
//                   );
//                 }),

//                 // Lời cảm ơn chân thành cuối trang
//                 const Padding(
//                   padding: EdgeInsets.only(top: 24, bottom: 48),
//                   child: Text(
//                     'Sự hiện diện của bạn\nlà niềm vinh hạnh cho gia đình chúng tôi.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontStyle: FontStyle.italic,
//                       color: AppTheme.textLight,
//                       height: 1.5,
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

//   // Khối render giao diện độc lập cho từng loại Section của mẫu Minimalist
//   Widget _buildSectionContent(SectionData section) {
//     switch (section.type) {
//       case 'our_story':
//         final text = section.content['text'] ?? '';
//         if (text.isEmpty) return const SizedBox.shrink();

//         return Column(
//           children: [
//             _buildSectionTitle(section.title),
//             Text(
//               text,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 15,
//                 height: 1.7,
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
//             ...items.map((item) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 20.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 70,
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
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item['title'] ?? '',
//                             style: const TextStyle(
//                               fontSize: 17,
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
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
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
//               separatorBuilder: (c, i) => const SizedBox(height: 12),
//               itemBuilder: (context, index) {
//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     images[index].toString(),
//                     fit: BoxFit.cover,
//                   ),
//                 );
//               },
//             ),
//           ],
//         );

//       default:
//         return const SizedBox.shrink();
//     }
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
//               fontSize: 18,
//               letterSpacing: 2,
//               fontWeight: FontWeight.w600,
//               color: AppTheme.deepPink,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             width: 30,
//             height: 1.5,
//             color: AppTheme.primaryPink.withOpacity(0.4),
//           ),
//         ],
//       ),
//     );
//   }
// }
