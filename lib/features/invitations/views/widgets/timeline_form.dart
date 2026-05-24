// import 'package:flutter/material.dart';
// import '../../../../core/theme/app_theme.dart';
// import '../../models/invitation.dart';

// class TimelineForm extends StatefulWidget {
//   final SectionData section;
//   final VoidCallback onUpdate;

//   const TimelineForm({
//     super.key,
//     required this.section,
//     required this.onUpdate,
//   });

//   @override
//   State<TimelineForm> createState() => _TimelineFormState();
// }

// class _TimelineControllers {
//   final TextEditingController time;
//   final TextEditingController title;
//   final TextEditingController desc;

//   _TimelineControllers({String t = '', String ti = '', String d = ''})
//     : time = TextEditingController(text: t),
//       title = TextEditingController(text: ti),
//       desc = TextEditingController(text: d);

//   void dispose() {
//     time.dispose();
//     title.dispose();
//     desc.dispose();
//   }
// }

// class _TimelineFormState extends State<TimelineForm> {
//   final List<_TimelineControllers> _controllers = [];

//   @override
//   void initState() {
//     super.initState();
//     final List<dynamic> existingItems = widget.section.content['items'] ?? [];

//     for (var item in existingItems) {
//       _controllers.add(
//         _TimelineControllers(
//           t: item['time'] ?? '',
//           ti: item['title'] ?? '',
//           d: item['desc'] ?? '',
//         ),
//       );
//     }

//     if (widget.section.content['items'] == null) {
//       widget.section.content['items'] = [];
//     }
//   }

//   @override
//   void dispose() {
//     for (var c in _controllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   void _syncDataToSection() {
//     final updatedItems = _controllers.map((c) {
//       return {
//         'time': c.time.text.trim(),
//         'title': c.title.text.trim(),
//         'desc': c.desc.text.trim(),
//       };
//     }).toList();

//     widget.section.content['items'] = updatedItems;
//     widget.onUpdate();
//   }

//   void _addItem() {
//     setState(() {
//       _controllers.add(_TimelineControllers());
//     });
//     _syncDataToSection();
//   }

//   void _removeItem(int index) {
//     setState(() {
//       _controllers[index].dispose();
//       _controllers.removeAt(index);
//     });
//     _syncDataToSection();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (_controllers.isEmpty)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 16.0),
//             child: Text(
//               'Chưa có mốc thời gian nào. Hãy thêm mốc đầu tiên!',
//               style: TextStyle(
//                 color: AppTheme.textLight,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),

//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: _controllers.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 16),
//           itemBuilder: (context, index) {
//             final controllers = _controllers[index];

//             return Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppTheme.backgroundCream.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppTheme.secondaryPink.withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     width: 90,
//                     child: TextField(
//                       controller: controllers.time,
//                       decoration: const InputDecoration(
//                         labelText: 'Giờ',
//                         hintText: '18:00',
//                       ),
//                       onChanged: (_) => _syncDataToSection(),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       children: [
//                         TextField(
//                           controller: controllers.title,
//                           decoration: const InputDecoration(
//                             labelText: 'Tên sự kiện',
//                             hintText: 'Đón khách / Khai tiệc',
//                           ),
//                           onChanged: (_) => _syncDataToSection(),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: controllers.desc,
//                           decoration: const InputDecoration(
//                             labelText: 'Mô tả ngắn (Không bắt buộc)',
//                             hintText: 'Chụp ảnh lưu niệm tại Photobooth',
//                           ),
//                           onChanged: (_) => _syncDataToSection(),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(
//                       Icons.delete_outline,
//                       color: Colors.redAccent,
//                     ),
//                     onPressed: () => _removeItem(index),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton.icon(
//           onPressed: _addItem,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppTheme.secondaryPink.withOpacity(0.2),
//             foregroundColor: AppTheme.deepPink,
//             elevation: 0,
//           ),
//           icon: const Icon(Icons.add, size: 18),
//           label: const Text('Thêm mốc thời gian'),
//         ),
//       ],
//     );
//   }
// }
