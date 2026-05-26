// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../models/invitation.dart';
// import '../models/template_config.dart';
// import 'package:flutter/material.dart';
// import 'dart:typed_data';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

// import '../models/invitation.dart';
// import '../models/template_config.dart';
// import '../../../core/network/upload_service.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/invitation/invitation_bloc.dart';
// import '../blocs/invitation/invitation_event.dart';
// import '../blocs/invitation/invitation_state.dart';

// class InvitationEditorScreen extends StatefulWidget {
//   final Invitation? existingInvitation;

//   const InvitationEditorScreen({super.key, this.existingInvitation});

//   @override
//   State<InvitationEditorScreen> createState() => _InvitationEditorScreenState();
// }

// class _InvitationEditorScreenState extends State<InvitationEditorScreen> {
//   late Invitation _invitation;
//   late TemplateConfig _selectedConfig;

//   late final TextEditingController _titleController;
//   late final TextEditingController _brideController;
//   late final TextEditingController _groomController;

//   @override
//   void initState() {
//     super.initState();
//     // 1. Khởi tạo dữ liệu: Dùng data cũ nếu đang sửa, hoặc tạo mới hoàn toàn
//     _invitation =
//         widget.existingInvitation ??
//         Invitation(
//           id: '',
//           title: 'Thiệp cưới mới',
//           templateId: availableTemplates.first.id,
//           brideName: '',
//           groomName: '',
//           status: 'draft',
//           eventDate: DateTime.now().add(const Duration(days: 30)),
//           uploadedImages: [],
//           dynamicData: {},
//         );

//     // 2. Tìm cấu hình Template dựa trên templateId
//     _selectedConfig = availableTemplates.firstWhere(
//       (t) => t.id == _invitation.templateId,
//       orElse: () => availableTemplates.first,
//     );

//     _titleController = TextEditingController(text: _invitation.title);
//     _brideController = TextEditingController(text: _invitation.brideName);
//     _groomController = TextEditingController(text: _invitation.groomName);
//   }

//   @override
//   void dispose() {
//     // THÊM: Hủy controller để tránh rò rỉ bộ nhớ
//     _titleController.dispose();
//     _brideController.dispose();
//     _groomController.dispose();
//     super.dispose();
//   }

//   // Hàm xử lý khi Dropdown thay đổi
//   void _onTemplateChanged(String? newTemplateId) {
//     if (newTemplateId == null) return;

//     setState(() {
//       _selectedConfig = availableTemplates.firstWhere(
//         (t) => t.id == newTemplateId,
//       );

//       // Cập nhật templateId vào biến _invitation
//       _invitation = Invitation(
//         id: _invitation.id,
//         templateId: newTemplateId,
//         brideName: _invitation.brideName,
//         groomName: _invitation.groomName,
//         status: _invitation.status,
//         eventDate: _invitation.eventDate,
//         uploadedImages: _invitation.uploadedImages,
//         coverImageIndex: _invitation.coverImageIndex,
//         dynamicData: _invitation.dynamicData,
//       );
//     });
//   }

//   // ==========================================
//   // HÀM TIỆN ÍCH: Cập nhật dữ liệu động (dynamicData)
//   // ==========================================
//   void _updateDynamicData(String key, dynamic value) {
//     setState(() {
//       // Bóc tách Map cũ, đè dữ liệu mới vào, và lưu lại vào State
//       final newData = Map<String, dynamic>.from(_invitation.dynamicData);
//       newData[key] = value;
//       _invitation = _invitation.copyWith(dynamicData: newData);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 1. Bọc BlocProvider ở ngoài cùng để cấp phát InvitationBloc cho màn hình này
//     return BlocProvider(
//       create: (context) => InvitationBloc(),
//       // 2. Dùng Builder để tạo ra một 'context' mới mẻ, đã nhận diện được BLoC bên trên
//       child: Builder(
//         builder: (context) {
//           // 3. Bây giờ BlocListener và context.read đã có thể hoạt động bình thường
//           return BlocListener<InvitationBloc, InvitationState>(
//             listener: (context, state) {
//               if (state is InvitationLoading) {
//                 SmartDialog.showLoading(
//                   msg: 'Đang lưu dữ liệu lên hệ thống 🌸...',
//                 );
//               } else {
//                 SmartDialog.dismiss();
//               }

//               if (state is InvitationOperationSuccess) {
//                 SmartDialog.showToast(state.message);
//                 // Lưu xong thì tự động đóng màn hình Editor
//                 context.pop();
//               } else if (state is InvitationError) {
//                 SmartDialog.showToast(state.message);
//               }
//             },
//             child: Scaffold(
//               backgroundColor: const Color(0xFFFDFBF7),
//               appBar: AppBar(
//                 title: Text(
//                   widget.existingInvitation == null
//                       ? 'Tạo thiệp mới'
//                       : 'Chỉnh sửa thiệp',
//                 ),
//                 backgroundColor: Colors.white,
//                 foregroundColor: const Color(0xFF2C2C2C),
//                 elevation: 0,
//                 actions: [
//                   TextButton.icon(
//                     onPressed: () {
//                       // KÍCH HOẠT LƯU THIỆP
//                       if (_brideController.text.trim().isEmpty ||
//                           _groomController.text.trim().isEmpty) {
//                         SmartDialog.showToast(
//                           'Vui lòng nhập đủ tên Cô Dâu và Chú Rể!',
//                         );
//                         return;
//                       }

//                       final finalInvitation = _invitation.copyWith(
//                         title: _titleController.text.trim(),
//                         brideName: _brideController.text.trim(),
//                         groomName: _groomController.text.trim(),
//                       );

//                       context.read<InvitationBloc>().add(
//                         SaveInvitation(finalInvitation),
//                       );
//                     },
//                     icon: const Icon(
//                       Icons.save_outlined,
//                       color: Color(0xFFE26D6D),
//                     ),
//                     label: const Text(
//                       'Lưu thay đổi',
//                       style: TextStyle(color: Color(0xFFE26D6D)),
//                     ),
//                   ),
//                 ],
//               ),
//               body: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildTemplateSelector(),
//                     const SizedBox(height: 32),
//                     const Divider(color: Colors.black12),
//                     const SizedBox(height: 24),
//                     _buildBasicInfoForm(),
//                     const SizedBox(height: 32),
//                     _buildMediaPool(),
//                     const SizedBox(height: 32),
//                     _buildDynamicForms(),
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ==========================================
//   // WIDGET: THÔNG TIN CƠ BẢN
//   // ==========================================
//   Widget _buildBasicInfoForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           '2. Thông tin cơ bản',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C2C2C),
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildTextField(
//           controller: _titleController,
//           label: 'Tiêu đề quản lý (VD: Thiệp chính thức - Nhà Gái)',
//           icon: Icons.label_outline,
//           onChanged: (val) => _invitation = _invitation.copyWith(title: val),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller: _brideController,
//                 label: 'Tên Cô Dâu',
//                 icon: Icons.female,
//                 onChanged: (val) =>
//                     _invitation = _invitation.copyWith(brideName: val),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildTextField(
//                 controller: _groomController,
//                 label: 'Tên Chú Rể',
//                 icon: Icons.male,
//                 onChanged: (val) =>
//                     _invitation = _invitation.copyWith(groomName: val),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),

//         // Nút chọn ngày giờ
//         InkWell(
//           onTap: () async {
//             final pickedDate = await showDatePicker(
//               context: context,
//               initialDate: _invitation.eventDate,
//               firstDate: DateTime.now(),
//               lastDate: DateTime(2030),
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme: const ColorScheme.light(
//                       primary: Color(0xFFE26D6D),
//                     ),
//                   ),
//                   child: child!,
//                 );
//               },
//             );
//             if (pickedDate != null) {
//               setState(() {
//                 _invitation = _invitation.copyWith(eventDate: pickedDate);
//               });
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.withOpacity(0.2)),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.calendar_today_rounded,
//                   color: Color(0xFFE26D6D),
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Ngày tổ chức: ${_invitation.eventDate.day}/${_invitation.eventDate.month}/${_invitation.eventDate.year}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: Color(0xFF2C2C2C),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Hàm tiện ích vẽ TextField
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required Function(String) onChanged,
//   }) {
//     return TextField(
//       controller: controller,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFFE26D6D)),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
//         ),
//       ),
//     );
//   }

//   // ==========================================
//   // WIDGET: HỒ CHỨA ẢNH (MEDIA POOL)
//   // ==========================================
//   Widget _buildMediaPool() {
//     final images = _invitation.uploadedImages;
//     final bool canUploadMore = images.length < 10;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               '3. Thư viện Ảnh (Media Pool)',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF2C2C2C),
//               ),
//             ),
//             Text(
//               '${images.length}/10 ảnh',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: canUploadMore ? Colors.grey[600] : Colors.red,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Tải lên các ảnh bạn muốn sử dụng (Ảnh bìa, Album...).',
//           style: TextStyle(fontSize: 13, color: Colors.grey[500]),
//         ),
//         const SizedBox(height: 16),

//         Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: [
//             // Hiển thị danh sách ảnh đã tải lên
//             ...images.asMap().entries.map((entry) {
//               int index = entry.key;
//               String url = entry.value;
//               return _buildImageThumbnail(url, index);
//             }),

//             // Nút Thêm ảnh (chỉ hiện khi chưa đủ 10 ảnh)
//             if (canUploadMore)
//               InkWell(
//                 onTap: _uploadMultipleImages,
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFFE26D6D).withOpacity(0.5),
//                       style: BorderStyle.solid,
//                     ),
//                   ),
//                   child: const Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.add_photo_alternate_outlined,
//                         color: Color(0xFFE26D6D),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'Thêm ảnh',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFFE26D6D),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }

//   // ==========================================
//   // WIDGET: THUMBNAIL ẢNH TRONG POOL VỚI EVENT CHỌN ẢNH BÌA
//   // ==========================================
//   Widget _buildImageThumbnail(String url, int index) {
//     bool isCover = _invitation.coverImageIndex == index;

//     return Stack(
//       clipBehavior: Clip
//           .none, // Cho phép nút xóa nhô ra ngoài rìa một chút cho thoáng đãng
//       children: [
//         // Khung bấm chọn ảnh bìa
//         InkWell(
//           onTap: () {
//             setState(() {
//               // Cập nhật chỉ số ảnh bìa mới vào Model
//               _invitation = _invitation.copyWith(coverImageIndex: index);
//             });
//             SmartDialog.showToast('🌸 Đã đặt làm ảnh bìa thiệp cưới!');
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: AnimatedContainer(
//             duration: const Duration(
//               milliseconds: 200,
//             ), // Hiệu ứng chuyển đổi viền mượt mà
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               // Nếu là ảnh bìa thì bo viền màu thương hiệu Sachi đậm hơn, ngược lại bo viền xám nhẹ
//               border: Border.all(
//                 color: isCover
//                     ? const Color(0xFFE26D6D)
//                     : Colors.grey.withOpacity(0.2),
//                 width: isCover ? 2.5 : 1,
//               ),
//               image: DecorationImage(
//                 image: NetworkImage(url),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),

//         // Nhãn "ẢNH BÌA" thanh lịch nằm dưới đáy ảnh
//         if (isCover)
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: IgnorePointer(
//               // Tránh cản trở sự kiện tap của InkWell bên dưới
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE26D6D).withOpacity(0.9),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(10),
//                     bottomRight: Radius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'ẢNH BÌA',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 9,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//         // Nút Xóa ảnh (Tách biệt hoàn toàn khỏi sự kiện click chọn ảnh bìa)
//         Positioned(
//           top: -6,
//           right: -6,
//           child: IconButton(
//             icon: const Icon(Icons.cancel, color: Colors.black54, size: 20),
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             onPressed: () {
//               final imageUrlToDelete = _invitation.uploadedImages[index];

//               setState(() {
//                 final newImages = List<String>.from(_invitation.uploadedImages)
//                   ..removeAt(index);
//                 int? newCoverIndex = _invitation.coverImageIndex;

//                 // --- XỬ LÝ LOGIC CHỈ SỐ THÔNG MINH KHI XÓA ---
//                 if (newCoverIndex == index) {
//                   // Nếu xóa đúng bức ảnh đang làm ảnh bìa -> Tự động lấy ảnh đầu tiên làm bìa mới, hoặc null nếu hết ảnh
//                   newCoverIndex = newImages.isNotEmpty ? 0 : null;
//                 } else if (newCoverIndex != null && newCoverIndex > index) {
//                   // Nếu ảnh bị xóa nằm trước ảnh bìa -> Giảm chỉ số đi 1 để duy trì đúng mục tiêu ảnh bìa
//                   newCoverIndex--;
//                 }

//                 _invitation = _invitation.copyWith(
//                   uploadedImages: newImages,
//                   coverImageIndex: newCoverIndex,
//                 );
//               });

//               // Tiến hành xóa file tĩnh mồ côi trên Cloudflare R2
//               UploadService().deleteFromR2(imageUrlToDelete);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // Hàm xử lý Upload ảnh lên R2
//   Future<void> _uploadImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 1200,
//       imageQuality: 75,
//     );

//     if (image != null) {
//       SmartDialog.showLoading(msg: 'Đang tải ảnh lên Sachi...');
//       try {
//         Uint8List fileBytes = await image.readAsBytes();
//         final publicUrl = await UploadService().uploadImageToR2(
//           fileBytes,
//           image.name,
//         );

//         if (publicUrl != null) {
//           setState(() {
//             final newImages = List<String>.from(_invitation.uploadedImages)
//               ..add(publicUrl);
//             _invitation = _invitation.copyWith(
//               uploadedImages: newImages,
//               coverImageIndex:
//                   _invitation.coverImageIndex ??
//                   0, // Mặc định ảnh đầu tiên là ảnh bìa
//             );
//           });
//           SmartDialog.showToast('Tải ảnh thành công!');
//         } else {
//           SmartDialog.showToast('Lỗi tải ảnh lên Cloud.');
//         }
//       } catch (e) {
//         SmartDialog.showToast('Có lỗi xảy ra: $e');
//       } finally {
//         SmartDialog.dismiss();
//       }
//     }
//   }

//   Future<void> _uploadMultipleImages() async {
//     final ImagePicker picker = ImagePicker();
//     // 1. Cho phép người dùng chọn nhiều ảnh
//     final List<XFile> selectedImages = await picker.pickMultiImage(
//       maxWidth: 1200,
//       imageQuality: 75,
//     );

//     if (selectedImages.isNotEmpty) {
//       // 2. Kiểm tra giới hạn 10 ảnh
//       int currentCount = _invitation.uploadedImages.length;
//       if (currentCount + selectedImages.length > 10) {
//         SmartDialog.showToast(
//           'Chỉ được chọn thêm tối đa ${10 - currentCount} ảnh nữa.',
//         );
//         return;
//       }

//       SmartDialog.showLoading(
//         msg: 'Đang tải lên ${selectedImages.length} ảnh...',
//       );
//       try {
//         // 3. Chạy vòng lặp Upload song song (Concurrent)
//         final uploadTasks = selectedImages.map((img) async {
//           final bytes = await img.readAsBytes();
//           // Thêm timestamp vào tên file để tránh trùng lặp
//           final fileName =
//               '${DateTime.now().millisecondsSinceEpoch}_${img.name}';
//           return await UploadService().uploadImageToR2(bytes, fileName);
//         }).toList();

//         // Chờ tất cả các ảnh upload xong
//         final uploadedUrls = await Future.wait(uploadTasks);

//         // 4. Lọc ra các URL không bị lỗi (khác null)
//         final validUrls = uploadedUrls.whereType<String>().toList();

//         if (validUrls.isNotEmpty) {
//           setState(() {
//             final newImages = List<String>.from(_invitation.uploadedImages)
//               ..addAll(validUrls);
//             _invitation = _invitation.copyWith(
//               uploadedImages: newImages,
//               coverImageIndex:
//                   _invitation.coverImageIndex ??
//                   0, // Ảnh đầu tiên tự làm ảnh bìa
//             );
//           });
//           SmartDialog.showToast('Tải thành công ${validUrls.length} ảnh! 🎉');
//         }
//       } catch (e) {
//         SmartDialog.showToast('Có lỗi xảy ra: $e');
//       } finally {
//         SmartDialog.dismiss();
//       }
//     }
//   }

//   Widget _buildTemplateSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           '1. Chọn mẫu giao diện (Template)',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C2C2C),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.withOpacity(0.2)),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: _selectedConfig.id,
//               isExpanded: true,
//               icon: const Icon(
//                 Icons.keyboard_arrow_down_rounded,
//                 color: Color(0xFFE26D6D),
//               ),
//               items: availableTemplates.map((template) {
//                 return DropdownMenuItem(
//                   value: template.id,
//                   child: Text(
//                     template.name,
//                     style: const TextStyle(fontSize: 15),
//                   ),
//                 );
//               }).toList(),
//               onChanged: _onTemplateChanged,
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Form nhập liệu bên dưới sẽ tự động thay đổi theo mẫu bạn chọn.',
//           style: TextStyle(fontSize: 13, color: Colors.grey[500]),
//         ),
//       ],
//     );
//   }

//   // ==========================================
//   // WIDGET: SMART FORM (TỰ ĐỘNG THAY ĐỔI)
//   // ==========================================
//   Widget _buildDynamicForms() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           '4. Nội dung chi tiết (Dựa theo Mẫu thiệp)',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C2C2C),
//           ),
//         ),
//         const SizedBox(height: 16),

//         // 4.1 Form Thông tin Bố Mẹ (Nếu Template yêu cầu)
//         if (_selectedConfig.hasParentsInfo) ...[
//           _buildParentsInfoForm(),
//           const SizedBox(height: 24),
//         ],

//         // 4.2 Form Câu chuyện tình yêu (Nếu số lượng yêu cầu > 0)
//         if (_selectedConfig.requiredOurStoryCount > 0) ...[
//           _buildOurStoryForm(),
//           const SizedBox(height: 24),
//         ],

//         // 4.3 Form Dòng thời gian / Chương trình tiệc (Nếu Template yêu cầu)
//         if (_selectedConfig.hasTimeline) ...[
//           _buildTimelineForm(),
//           const SizedBox(height: 24),
//         ],

//         // 4.4 Form QR Code Nhận quà (Nếu Template yêu cầu)
//         if (_selectedConfig.hasQrCode) ...[
//           _buildQrCodeForm(),
//           const SizedBox(height: 24),
//         ],
//       ],
//     );
//   }

//   // ==========================================
//   // WIDGET: FORM OUR STORY (CHUYỆN TÌNH MÌNH)
//   // ==========================================
//   Widget _buildOurStoryForm() {
//     final int requiredCount = _selectedConfig.requiredOurStoryCount;
//     // Lấy danh sách truyện hiện tại, nếu chưa có thì khởi tạo mảng rỗng
//     List<dynamic> stories = List.from(
//       _invitation.dynamicData['our_stories'] ?? [],
//     );

//     // --- LOGIC THÔNG MINH: Tự động co giãn số lượng Form ---
//     if (stories.length != requiredCount) {
//       if (stories.length < requiredCount) {
//         // Thiếu thì tự động sinh thêm form trống
//         while (stories.length < requiredCount) {
//           stories.add({
//             'title': '',
//             'date': '',
//             'description': '',
//             'image_url': '',
//           });
//         }
//       } else {
//         // Thừa (do vừa đổi sang template cần ít truyện hơn) thì cắt bớt
//         stories = stories.sublist(0, requiredCount);
//       }
//       // Lưu thẳng vào bộ nhớ tạm thời mà không gọi setState để tránh lỗi build
//       _invitation.dynamicData['our_stories'] = stories;
//     }

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.withOpacity(0.15)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.favorite_outline,
//                 color: Color(0xFFE26D6D),
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Chuyện tình mình (Yêu cầu $requiredCount cột mốc)',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                   color: Color(0xFF2C2C2C),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Lặp qua danh sách để vẽ từng Form câu chuyện
//           ...stories.asMap().entries.map((entry) {
//             int index = entry.key;
//             Map<String, dynamic> story = Map<String, dynamic>.from(entry.value);

//             // LOGIC DỌN RÁC: Nếu ảnh đã bị xóa khỏi Media Pool thì gỡ luôn khỏi Story
//             if (story['image_url'] != '' &&
//                 !_invitation.uploadedImages.contains(story['image_url'])) {
//               story['image_url'] = '';
//               stories[index] = story;
//               _invitation.dynamicData['our_stories'] = stories;
//             }

//             return Padding(
//               padding: const EdgeInsets.only(bottom: 24.0),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFDFBF7), // Nền kem nhạt tách biệt
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.withOpacity(0.15)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'CỘT MỐC ${index + 1}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w900,
//                         fontSize: 12,
//                         letterSpacing: 1,
//                         color: Color(0xFFE26D6D),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextFormField(
//                             initialValue: story['title'] ?? '',
//                             decoration: InputDecoration(
//                               labelText: 'Tiêu đề',
//                               hintText: 'VD: Lần đầu gặp gỡ',
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                             onChanged: (val) {
//                               stories[index]['title'] = val;
//                               _updateDynamicData('our_stories', stories);
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextFormField(
//                             initialValue: story['date'] ?? '',
//                             decoration: InputDecoration(
//                               labelText: 'Thời gian',
//                               hintText: 'VD: 14/02/2019',
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                             onChanged: (val) {
//                               stories[index]['date'] = val;
//                               _updateDynamicData('our_stories', stories);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       initialValue: story['description'] ?? '',
//                       maxLines: 3,
//                       decoration: InputDecoration(
//                         labelText: 'Nội dung câu chuyện',
//                         hintText: 'Kể lại kỷ niệm đáng nhớ của hai bạn...',
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       onChanged: (val) {
//                         stories[index]['description'] = val;
//                         _updateDynamicData('our_stories', stories);
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     // --- KHU VỰC CHỌN ẢNH TỪ MEDIA POOL ---
//                     const Text(
//                       'Chọn 1 ảnh minh họa từ Thư viện (Media Pool):',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     if (_invitation.uploadedImages.isEmpty)
//                       const Text(
//                         '⚠️ Vui lòng tải ảnh lên ở mục "3. Thư viện Ảnh" trước.',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 12,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       )
//                     else
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: _invitation.uploadedImages.map((url) {
//                           bool isSelected = story['image_url'] == url;
//                           return InkWell(
//                             onTap: () {
//                               setState(() {
//                                 stories[index]['image_url'] = url;
//                                 _updateDynamicData('our_stories', stories);
//                               });
//                             },
//                             borderRadius: BorderRadius.circular(8),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? const Color(0xFFE26D6D)
//                                       : Colors.transparent,
//                                   width: 3, // Viền hồng đậm khi được chọn
//                                 ),
//                                 image: DecorationImage(
//                                   image: NetworkImage(url),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   // ==========================================
//   // WIDGET: FORM NHẬP THÔNG TIN PHỤ HUYNH (ĐÃ TÁCH TRƯỜNG)
//   // ==========================================
//   Widget _buildParentsInfoForm() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.withOpacity(0.15)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(
//                 Icons.family_restroom_rounded,
//                 color: Color(0xFFE26D6D),
//                 size: 20,
//               ),
//               SizedBox(width: 8),
//               Text(
//                 'Thông tin Gia đình Phụ huynh',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                   color: Color(0xFF2C2C2C),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // --- KHỐI NHÀ GÁI (CÔ DÂU) ---
//           Text(
//             'Đại diện Nhà Gái (Gia đình Cô Dâu)',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   initialValue: _invitation.dynamicData['bride_father'] ?? '',
//                   decoration: InputDecoration(
//                     labelText: 'Họ tên Thân phụ (Bố)',
//                     hintText: 'VD: Lê Văn A',
//                     filled: true,
//                     fillColor: const Color(0xFFFDFBF7),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   onChanged: (val) => _updateDynamicData('bride_father', val),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: TextFormField(
//                   initialValue: _invitation.dynamicData['bride_mother'] ?? '',
//                   decoration: InputDecoration(
//                     labelText: 'Họ tên Thân mẫu (Mẹ)',
//                     hintText: 'VD: Trần Thị B',
//                     filled: true,
//                     fillColor: const Color(0xFFFDFBF7),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   onChanged: (val) => _updateDynamicData('bride_mother', val),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),
//           Divider(color: Colors.grey.withOpacity(0.1), height: 1),
//           const SizedBox(height: 20),

//           // --- KHỐI NHÀ TRAI (CHÚ RỂ) ---
//           Text(
//             'Đại diện Nhà Trai (Gia đình Chú Rể)',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   initialValue: _invitation.dynamicData['groom_father'] ?? '',
//                   decoration: InputDecoration(
//                     labelText: 'Họ tên Thân phụ (Bố)',
//                     hintText: 'VD: Phạm Văn C',
//                     filled: true,
//                     fillColor: const Color(0xFFFDFBF7),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   onChanged: (val) => _updateDynamicData('groom_father', val),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: TextFormField(
//                   initialValue: _invitation.dynamicData['groom_mother'] ?? '',
//                   decoration: InputDecoration(
//                     labelText: 'Họ tên Thân mẫu (Mẹ)',
//                     hintText: 'VD: Nguyễn Thị D',
//                     filled: true,
//                     fillColor: const Color(0xFFFDFBF7),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   onChanged: (val) => _updateDynamicData('groom_mother', val),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Khối Giữ chỗ trực quan (Để Test luồng Smart Form)
//   Widget _buildPlaceholderBlock({
//     required String title,
//     required IconData icon,
//     required String desc,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: color.withOpacity(0.3),
//           style: BorderStyle.solid,
//         ), // Viền đứt nét báo hiệu đang xây dựng
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                     color: color,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   desc,
//                   style: TextStyle(fontSize: 13, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimelineForm() {
//     // Đọc danh sách timeline từ dynamicData, nếu chưa có thì khởi tạo mảng rỗng
//     final List<dynamic> timeline = _invitation.dynamicData['timeline'] ?? [];

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.withOpacity(0.15)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.timeline, color: Color(0xFF4A90E2), size: 20),
//               SizedBox(width: 8),
//               Text(
//                 'Chương trình tiệc (Timeline)',
//                 style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Danh sách các mốc thời gian có thể Thêm/Xóa động
//           ...timeline.asMap().entries.map((entry) {
//             int index = entry.key;
//             Map<String, dynamic> item = entry.value;

//             return Padding(
//               padding: const EdgeInsets.only(bottom: 12.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 1, // Ô nhập Giờ nhỏ hơn
//                     child: TextFormField(
//                       initialValue: item['time'],
//                       decoration: InputDecoration(
//                         hintText: 'VD: 09:00',
//                         filled: true,
//                         fillColor: const Color(0xFFFDFBF7),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       onChanged: (val) {
//                         item['time'] = val;
//                         _updateDynamicData('timeline', timeline);
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     flex: 2, // Ô nhập Nội dung sự kiện lớn hơn
//                     child: TextFormField(
//                       initialValue: item['event'],
//                       decoration: InputDecoration(
//                         hintText: 'VD: Đón khách & Chụp ảnh',
//                         filled: true,
//                         fillColor: const Color(0xFFFDFBF7),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       onChanged: (val) {
//                         item['event'] = val;
//                         _updateDynamicData('timeline', timeline);
//                       },
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(
//                       Icons.remove_circle_outline,
//                       color: Colors.red,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         timeline.removeAt(index);
//                         _updateDynamicData('timeline', timeline);
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             );
//           }),

//           // Nút thêm mốc thời gian mới
//           TextButton.icon(
//             onPressed: () {
//               setState(() {
//                 timeline.add({'time': '', 'event': ''});
//                 _updateDynamicData('timeline', timeline);
//               });
//             },
//             icon: const Icon(
//               Icons.add_circle_outline,
//               color: Color(0xFF4A90E2),
//             ),
//             label: const Text(
//               'Thêm sự kiện',
//               style: TextStyle(color: Color(0xFF4A90E2)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==========================================
//   // WIDGET: FORM QR CODE & TÀI KHOẢN NGÂN HÀNG
//   // ==========================================
//   Widget _buildQrCodeForm() {
//     final qrCodeUrl = _invitation.dynamicData['qr_code_url'];

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.withOpacity(0.15)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.qr_code_2, color: Color(0xFF7A8266), size: 20),
//               SizedBox(width: 8),
//               Text(
//                 'Mã QR Nhận quà',
//                 style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Khung hiển thị và Nút Upload ảnh QR
//               InkWell(
//                 onTap: () async {
//                   final picker = ImagePicker();
//                   final image = await picker.pickImage(
//                     source: ImageSource.gallery,
//                     maxWidth: 800,
//                     imageQuality: 75,
//                   );

//                   if (image != null) {
//                     SmartDialog.showLoading(msg: 'Đang tải mã QR lên R2...');
//                     final bytes = await image.readAsBytes();
//                     final newUrl = await UploadService().uploadImageToR2(
//                       bytes,
//                       'qr_${DateTime.now().millisecondsSinceEpoch}.png',
//                     );
//                     SmartDialog.dismiss();

//                     if (newUrl != null) {
//                       // ---> LOGIC DỌN RÁC Ở ĐÂY <---
//                       final oldUrl = _invitation.dynamicData['qr_code_url'];
//                       if (oldUrl != null && oldUrl.isNotEmpty) {
//                         // Gọi xóa ảnh cũ ngầm bên dưới
//                         UploadService().deleteFromR2(oldUrl);
//                       }

//                       // Cập nhật URL mới vào State
//                       _updateDynamicData('qr_code_url', newUrl);
//                       SmartDialog.showToast('Cập nhật mã QR thành công!');
//                     }
//                   }
//                 },
//                 child: Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFDFBF7),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.withOpacity(0.3)),
//                     image: qrCodeUrl != null
//                         ? DecorationImage(
//                             image: NetworkImage(qrCodeUrl),
//                             fit: BoxFit.cover,
//                           )
//                         : null,
//                   ),
//                   child: qrCodeUrl == null
//                       ? const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.add_photo_alternate_outlined,
//                               color: Colors.grey,
//                               size: 32,
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               'Tải mã QR',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         )
//                       : null,
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // Form thông tin Text đi kèm QR
//               Expanded(
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       initialValue: _invitation.dynamicData['bank_name'] ?? '',
//                       decoration: InputDecoration(
//                         labelText: 'Tên Ngân hàng / Ví',
//                         hintText: 'VD: Vietcombank / Momo',
//                         filled: true,
//                         fillColor: const Color(0xFFFDFBF7),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       onChanged: (val) => _updateDynamicData('bank_name', val),
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       initialValue:
//                           _invitation.dynamicData['bank_account'] ?? '',
//                       decoration: InputDecoration(
//                         labelText: 'Số tài khoản & Tên chủ thẻ',
//                         hintText: 'VD: 0123456789 - NGUYEN VAN A',
//                         filled: true,
//                         fillColor: const Color(0xFFFDFBF7),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       onChanged: (val) =>
//                           _updateDynamicData('bank_account', val),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
