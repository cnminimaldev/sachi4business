import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/invitation.dart';
import '../models/template_config.dart';
import '../../../core/network/upload_service.dart';
import '../blocs/invitation/invitation_bloc.dart';
import '../blocs/invitation/invitation_event.dart';
import '../blocs/invitation/invitation_state.dart';

// Import Panel Live Preview vừa tạo
import 'widgets/live_preview_panel.dart';

class InvitationEditorScreen extends StatefulWidget {
  final Invitation? existingInvitation;

  const InvitationEditorScreen({super.key, this.existingInvitation});

  @override
  State<InvitationEditorScreen> createState() => _InvitationEditorScreenState();
}

class _InvitationEditorScreenState extends State<InvitationEditorScreen> {
  late Invitation _invitation;
  late TemplateConfig _selectedConfig;

  late final TextEditingController _titleController;
  late final TextEditingController _brideController;
  late final TextEditingController _groomController;

  @override
  void initState() {
    super.initState();
    _invitation =
        widget.existingInvitation ??
        Invitation(
          id: '',
          title: 'Thiệp cưới mới',
          templateId: availableTemplates.first.id,
          brideName: '',
          groomName: '',
          status: 'draft',
          eventDate: DateTime.now().add(const Duration(days: 30)),
          uploadedImages: [],
          dynamicData: {},
        );

    _selectedConfig = availableTemplates.firstWhere(
      (t) => t.id == _invitation.templateId,
      orElse: () => availableTemplates.first,
    );

    _titleController = TextEditingController(text: _invitation.title);
    _brideController = TextEditingController(text: _invitation.brideName);
    _groomController = TextEditingController(text: _invitation.groomName);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brideController.dispose();
    _groomController.dispose();
    super.dispose();
  }

  void _onTemplateChanged(String? newTemplateId) {
    if (newTemplateId == null) return;
    setState(() {
      _selectedConfig = availableTemplates.firstWhere(
        (t) => t.id == newTemplateId,
      );
      _invitation = _invitation.copyWith(templateId: newTemplateId);
    });
  }

  void _updateDynamicData(String key, dynamic value) {
    setState(() {
      final newData = Map<String, dynamic>.from(_invitation.dynamicData);
      newData[key] = value;
      _invitation = _invitation.copyWith(dynamicData: newData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvitationBloc(),
      child: Builder(
        builder: (context) {
          return BlocListener<InvitationBloc, InvitationState>(
            listener: (context, state) {
              if (state is InvitationLoading) {
                SmartDialog.showLoading(msg: 'Đang lưu dữ liệu 🌸...');
              } else {
                SmartDialog.dismiss();
              }

              if (state is InvitationOperationSuccess) {
                SmartDialog.showToast(state.message);
                context.pop();
              } else if (state is InvitationError) {
                SmartDialog.showToast(state.message);
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFFDFBF7),
              appBar: AppBar(
                title: Text(
                  widget.existingInvitation == null
                      ? 'Tạo thiệp mới'
                      : 'Chỉnh sửa thiệp',
                ),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2C2C2C),
                elevation: 0,
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      if (_brideController.text.trim().isEmpty ||
                          _groomController.text.trim().isEmpty) {
                        SmartDialog.showToast('Vui lòng nhập tên Dâu Rể!');
                        return;
                      }

                      final finalInvitation = _invitation.copyWith(
                        title: _titleController.text.trim(),
                        brideName: _brideController.text.trim(),
                        groomName: _groomController.text.trim(),
                      );

                      context.read<InvitationBloc>().add(
                        SaveInvitation(finalInvitation),
                      );
                    },
                    icon: const Icon(
                      Icons.save_outlined,
                      color: Color(0xFFE26D6D),
                    ),
                    label: const Text(
                      'Lưu thay đổi',
                      style: TextStyle(color: Color(0xFFE26D6D)),
                    ),
                  ),
                ],
              ),

              // TÍCH HỢP SPLIT-VIEW
              body: LayoutBuilder(
                builder: (context, constraints) {
                  // Màn hình rộng (PC/Tablet) -> Split-View
                  if (constraints.maxWidth > 1024) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nửa trái: Form nhập liệu
                        Expanded(flex: 5, child: _buildFormContent()),
                        // Vách ngăn
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Colors.black12,
                        ),
                        // Nửa phải: Live Preview
                        Expanded(
                          flex: 5,
                          child: LivePreviewPanel(invitation: _invitation),
                        ),
                      ],
                    );
                  }

                  // Màn hình nhỏ (Mobile) -> Chỉ hiển thị Form
                  return _buildFormContent();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // KHỐI GOM TOÀN BỘ FORM NHẬP LIỆU
  // ==========================================
  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTemplateSelector(),
          const SizedBox(height: 32),
          const Divider(color: Colors.black12),
          const SizedBox(height: 24),
          _buildBasicInfoForm(),
          const SizedBox(height: 32),
          _buildMediaPool(),
          const SizedBox(height: 32),
          _buildDynamicForms(), // Luồng Smart Form tự động bật/tắt
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==========================================
  // CÁC WIDGET THÀNH PHẦN (Giữ nguyên logic cũ)
  // ==========================================
  Widget _buildTemplateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Chọn mẫu giao diện (Template)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedConfig.id,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFE26D6D),
              ),
              items: availableTemplates.map((template) {
                return DropdownMenuItem(
                  value: template.id,
                  child: Text(
                    template.name,
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: _onTemplateChanged,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Form nhập liệu bên dưới sẽ tự động thay đổi theo mẫu bạn chọn.',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildBasicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Thông tin cơ bản',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _titleController,
          label: 'Tiêu đề quản lý',
          icon: Icons.label_outline,
          onChanged: (val) => _invitation = _invitation.copyWith(title: val),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _brideController,
                label: 'Tên Cô Dâu',
                icon: Icons.female,
                onChanged: (val) =>
                    _invitation = _invitation.copyWith(brideName: val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _groomController,
                label: 'Tên Chú Rể',
                icon: Icons.male,
                onChanged: (val) =>
                    _invitation = _invitation.copyWith(groomName: val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _invitation.eventDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFE26D6D),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(
                () => _invitation = _invitation.copyWith(eventDate: pickedDate),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFFE26D6D),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ngày tổ chức: ${_invitation.eventDate.day}/${_invitation.eventDate.month}/${_invitation.eventDate.year}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE26D6D)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildMediaPool() {
    final images = _invitation.uploadedImages;
    final bool canUploadMore = images.length < 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '3. Thư viện Ảnh (Media Pool)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            Text(
              '${images.length}/10 ảnh',
              style: TextStyle(
                fontSize: 13,
                color: canUploadMore ? Colors.grey[600] : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...images.asMap().entries.map(
              (entry) => _buildImageThumbnail(entry.value, entry.key),
            ),
            if (canUploadMore)
              InkWell(
                onTap: _uploadMultipleImages,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE26D6D).withOpacity(0.5),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Color(0xFFE26D6D),
                      ),
                      Text(
                        'Thêm ảnh',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE26D6D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(String url, int index) {
    bool isCover = _invitation.coverImageIndex == index;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () {
            setState(
              () => _invitation = _invitation.copyWith(coverImageIndex: index),
            );
            SmartDialog.showToast('🌸 Đã đặt làm ảnh bìa!');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCover
                    ? const Color(0xFFE26D6D)
                    : Colors.grey.withOpacity(0.2),
                width: isCover ? 2.5 : 1,
              ),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (isCover)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE26D6D).withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: const Text(
                'ẢNH BÌA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: -6,
          right: -6,
          child: IconButton(
            icon: const Icon(Icons.cancel, color: Colors.black54, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              final imageUrlToDelete = _invitation.uploadedImages[index];
              setState(() {
                final newImages = List<String>.from(_invitation.uploadedImages)
                  ..removeAt(index);
                int? newCoverIndex = _invitation.coverImageIndex;
                if (newCoverIndex == index)
                  newCoverIndex = newImages.isNotEmpty ? 0 : null;
                else if (newCoverIndex != null && newCoverIndex > index)
                  newCoverIndex--;

                _invitation = _invitation.copyWith(
                  uploadedImages: newImages,
                  coverImageIndex: newCoverIndex,
                );
              });
              UploadService().deleteFromR2(imageUrlToDelete);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _uploadMultipleImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage(
      maxWidth: 1200,
      imageQuality: 75,
    );

    if (selectedImages.isNotEmpty) {
      if (_invitation.uploadedImages.length + selectedImages.length > 10) {
        SmartDialog.showToast('Chỉ được tải lên tối đa 10 ảnh.');
        return;
      }
      SmartDialog.showLoading(msg: 'Đang tải lên...');
      try {
        final uploadTasks = selectedImages.map((img) async {
          final bytes = await img.readAsBytes();
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${img.name}';
          return await UploadService().uploadImageToR2(bytes, fileName);
        }).toList();

        final uploadedUrls = await Future.wait(uploadTasks);
        final validUrls = uploadedUrls.whereType<String>().toList();

        if (validUrls.isNotEmpty) {
          setState(() {
            final newImages = List<String>.from(_invitation.uploadedImages)
              ..addAll(validUrls);
            _invitation = _invitation.copyWith(
              uploadedImages: newImages,
              coverImageIndex: _invitation.coverImageIndex ?? 0,
            );
          });
          SmartDialog.showToast('Tải thành công ${validUrls.length} ảnh! 🎉');
        }
      } finally {
        SmartDialog.dismiss();
      }
    }
  }

  Widget _buildDynamicForms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Nội dung chi tiết',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedConfig.hasParentsInfo) ...[
          _buildParentsInfoForm(),
          const SizedBox(height: 24),
        ],
        if (_selectedConfig.requiredOurStoryCount > 0) ...[
          _buildOurStoryForm(),
          const SizedBox(height: 24),
        ],
        if (_selectedConfig.hasTimeline) ...[
          _buildTimelineForm(),
          const SizedBox(height: 24),
        ],
        if (_selectedConfig.hasQrCode) ...[_buildQrCodeForm()],
      ],
    );
  }

  Widget _buildParentsInfoForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đại diện Nhà Gái (Gia đình Cô Dâu)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _invitation.dynamicData['bride_father'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Họ tên Thân phụ',
                    filled: true,
                    fillColor: Color(0xFFFDFBF7),
                  ),
                  onChanged: (val) => _updateDynamicData('bride_father', val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _invitation.dynamicData['bride_mother'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Họ tên Thân mẫu',
                    filled: true,
                    fillColor: Color(0xFFFDFBF7),
                  ),
                  onChanged: (val) => _updateDynamicData('bride_mother', val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Đại diện Nhà Trai (Gia đình Chú Rể)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _invitation.dynamicData['groom_father'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Họ tên Thân phụ',
                    filled: true,
                    fillColor: Color(0xFFFDFBF7),
                  ),
                  onChanged: (val) => _updateDynamicData('groom_father', val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _invitation.dynamicData['groom_mother'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Họ tên Thân mẫu',
                    filled: true,
                    fillColor: Color(0xFFFDFBF7),
                  ),
                  onChanged: (val) => _updateDynamicData('groom_mother', val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOurStoryForm() {
    final int requiredCount = _selectedConfig.requiredOurStoryCount;
    List<dynamic> stories = List.from(
      _invitation.dynamicData['our_stories'] ?? [],
    );

    if (stories.length != requiredCount) {
      if (stories.length < requiredCount) {
        while (stories.length < requiredCount) {
          stories.add({
            'title': '',
            'date': '',
            'description': '',
            'image_url': '',
          });
        }
      } else {
        stories = stories.sublist(0, requiredCount);
      }
      _invitation.dynamicData['our_stories'] = stories;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chuyện tình mình (Yêu cầu $requiredCount cột mốc)',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...stories.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> story = Map<String, dynamic>.from(entry.value);

            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFFDFBF7),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: story['title'],
                            decoration: const InputDecoration(
                              labelText: 'Tiêu đề',
                            ),
                            onChanged: (val) {
                              stories[index]['title'] = val;
                              _updateDynamicData('our_stories', stories);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: story['date'],
                            decoration: const InputDecoration(
                              labelText: 'Thời gian',
                            ),
                            onChanged: (val) {
                              stories[index]['date'] = val;
                              _updateDynamicData('our_stories', stories);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: story['description'],
                      decoration: const InputDecoration(labelText: 'Nội dung'),
                      onChanged: (val) {
                        stories[index]['description'] = val;
                        _updateDynamicData('our_stories', stories);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineForm() {
    final List<dynamic> timeline = _invitation.dynamicData['timeline'] ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chương trình tiệc',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...timeline.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: item['time'],
                      onChanged: (val) {
                        item['time'] = val;
                        _updateDynamicData('timeline', timeline);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: item['event'],
                      onChanged: (val) {
                        item['event'] = val;
                        _updateDynamicData('timeline', timeline);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => setState(() {
                      timeline.removeAt(index);
                      _updateDynamicData('timeline', timeline);
                    }),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() {
              timeline.add({'time': '', 'event': ''});
              _updateDynamicData('timeline', timeline);
            }),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Thêm sự kiện'),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeForm() {
    final qrCodeUrl = _invitation.dynamicData['qr_code_url'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                maxWidth: 800,
              );
              if (image != null) {
                SmartDialog.showLoading();
                final newUrl = await UploadService().uploadImageToR2(
                  await image.readAsBytes(),
                  'qr_${DateTime.now().millisecondsSinceEpoch}.png',
                );
                SmartDialog.dismiss();
                if (newUrl != null) {
                  if (qrCodeUrl != null)
                    UploadService().deleteFromR2(qrCodeUrl);
                  _updateDynamicData('qr_code_url', newUrl);
                }
              }
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                image: qrCodeUrl != null
                    ? DecorationImage(
                        image: NetworkImage(qrCodeUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: qrCodeUrl == null
                  ? const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _invitation.dynamicData['bank_name'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Tên Ngân hàng / Ví',
                  ),
                  onChanged: (val) => _updateDynamicData('bank_name', val),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _invitation.dynamicData['bank_account'] ?? '',
                  decoration: const InputDecoration(labelText: 'Số tài khoản'),
                  onChanged: (val) => _updateDynamicData('bank_account', val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
