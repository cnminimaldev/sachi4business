import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../models/invitation.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../../../core/network/upload_service.dart';

// ==========================================
// MOCK DATA: CÁC MẪU THIỆP ĐỊNH NGHĨA SẴN
// (Sau này dữ liệu này sẽ được kéo từ Supabase về)
// ==========================================
class InvitationTemplate {
  final String id;
  final String name;
  final List<String> requiredSections; // Quy định các section có trong mẫu này

  InvitationTemplate(this.id, this.name, this.requiredSections);
}

final List<InvitationTemplate> mockTemplates = [
  InvitationTemplate('tpl_1', 'Mẫu Minimalist (Chỉ Tên & Album Ảnh)', [
    'gallery',
  ]),
  InvitationTemplate('tpl_2', 'Mẫu Cổ điển (Chuyện Tình & Lịch trình)', [
    'our_story',
    'timeline',
  ]),
  InvitationTemplate('tpl_3', 'Mẫu Premium (Đầy đủ Tính năng)', [
    'our_story',
    'timeline',
    'gallery',
  ]),
];

// ==========================================
// MÀN HÌNH CHỈNH SỬA CHÍNH
// ==========================================
class InvitationEditorScreen extends StatefulWidget {
  final Invitation? existingInvitation;

  const InvitationEditorScreen({super.key, this.existingInvitation});

  @override
  State<InvitationEditorScreen> createState() => _InvitationEditorScreenState();
}

class _InvitationEditorScreenState extends State<InvitationEditorScreen> {
  InvitationTemplate? _selectedTemplate;
  List<SectionData> _formSections = [];

  final TextEditingController _brideController = TextEditingController();
  final TextEditingController _groomController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    // NẾU LÀ CHẾ ĐỘ SỬA (CÓ DỮ LIỆU CŨ)
    if (widget.existingInvitation != null) {
      _brideController.text = widget.existingInvitation!.brideName;
      _groomController.text = widget.existingInvitation!.groomName;
      _selectedDate = widget.existingInvitation!.eventDate;

      // BÊ NGUYÊN DANH SÁCH SECTION CŨ VÀO FORM
      _formSections = widget.existingInvitation!.sections;

      // (Tùy chọn) Chọn lại đúng template mẫu.
      // Do chúng ta đang dùng mặc định, bạn có thể tạm thời lấy mẫu đầu tiên
      _selectedTemplate = mockTemplates.firstWhere(
        (template) => template.id == widget.existingInvitation!.templateId,
        orElse: () => mockTemplates
            .first, // Nếu không tìm thấy (lỗi logic) thì dự phòng lấy mẫu đầu tiên
      );
    }
    // NẾU LÀ TẠO MỚI (Tự sinh form mặc định)
    else {
      _selectedTemplate = mockTemplates.first;
      _generateSmartForm();
    }
  }

  @override
  void dispose() {
    // Nhớ hủy controller khi thoát màn hình để giải phóng RAM
    _brideController.dispose();
    _groomController.dispose();
    super.dispose();
  }

  // ---> HÀM LƯU DỮ LIỆU LÊN SUPABASE <---
  Future<void> _saveInvitation() async {
    // 1. Kiểm tra Validate cơ bản
    if (_brideController.text.trim().isEmpty ||
        _groomController.text.trim().isEmpty ||
        _selectedDate == null) {
      SmartDialog.showToast('Vui lòng nhập đủ tên Dâu Rể và Ngày cưới!');
      return;
    }

    SmartDialog.showLoading(msg: 'Đang lưu thiệp lên hệ thống 🌸...');

    try {
      // 2. Chuyển đổi danh sách SectionData thành mảng JSON để nạp vào cột JSONB
      final List<Map<String, dynamic>> sectionsJson = _formSections.map((
        section,
      ) {
        return {
          'id': section.id,
          'type': section.type,
          'title': section.title,
          'isActive': section.isActive,
          'content': section
              .content, // Toàn bộ link ảnh R2 hay text Our Story nằm hết ở đây
        };
      }).toList();

      // 3. Chuẩn bị cục dữ liệu (Payload) chuẩn khớp với tên cột trong database
      final payload = {
        'template_id': _selectedTemplate?.id ?? mockTemplates.first.id,
        'bride_name': _brideController.text.trim(),
        'groom_name': _groomController.text.trim(),
        'event_date': _selectedDate!
            .toIso8601String(), // Convert ngày sang chuẩn quốc tế
        'status': 'draft', // Mặc định lưu nháp
        'sections': sectionsJson,
      };

      // 4. Gọi API của Supabase
      if (widget.existingInvitation == null) {
        // Chế độ TẠO MỚI
        await Supabase.instance.client.from('invitations').insert(payload);
      } else {
        // Chế độ CẬP NHẬT
        await Supabase.instance.client
            .from('invitations')
            .update(payload)
            .eq('id', widget.existingInvitation!.id);
      }

      SmartDialog.dismiss();
      SmartDialog.showToast('Lưu thiệp thành công! 🎉');

      // 5. Quay trở về màn hình danh sách
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('Lỗi khi lưu: $e');
      print('Save Error: $e');
    }
  }

  // Hàm "Thông minh": Tự động sinh ra các Form dựa trên Template được chọn
  void _generateSmartForm() {
    if (_selectedTemplate == null) return;

    _formSections = _selectedTemplate!.requiredSections.map((type) {
      return SectionData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        title: _getDefaultTitleForType(type),
        isActive: true,
        content:
            {}, // ---> BỔ SUNG DÒNG NÀY: Khởi tạo một Map trống hoàn toàn mới
      );
    }).toList();
  }

  String _getDefaultTitleForType(String type) {
    switch (type) {
      case 'our_story':
        return 'Chuyện tình mình';
      case 'timeline':
        return 'Chương trình tiệc cưới';
      case 'gallery':
        return 'Album khoảnh khắc';
      default:
        return 'Tiêu đề';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundCream,
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceWhite,
          elevation: 0,
          leading: const BackButton(color: AppTheme.textMain),
          title: Text(
            widget.existingInvitation == null
                ? 'Tạo Thiệp Mới'
                : 'Chỉnh sửa Thiệp',
            style: const TextStyle(
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppTheme.deepPink,
            unselectedLabelColor: AppTheme.textLight,
            indicatorColor: AppTheme.deepPink,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'Thông tin cơ bản'),
              Tab(icon: Icon(Icons.edit_document), text: 'Nội dung Thiệp'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _saveInvitation,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text('Lưu thay đổi'),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildBasicInfoTab(),
            _buildSmartFormTab(), // Thay thế bằng Tab "Thông minh"
          ],
        ),
      ),
    );
  }

  // ========================================================
  // WIDGET: TAB 1 - THÔNG TIN CƠ BẢN (CÓ CHỌN TEMPLATE)
  // ========================================================
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ), // Rút gọn chiều rộng cho đẹp mắt
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn Mẫu Giao Diện',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepPink,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DROPDOWN CHỌN MẪU THIỆP
                  DropdownButtonFormField<InvitationTemplate>(
                    value: _selectedTemplate,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.style_outlined,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                    items: mockTemplates
                        .map(
                          (tpl) => DropdownMenuItem(
                            value: tpl,
                            child: Text(tpl.name),
                          ),
                        )
                        .toList(),
                    onChanged: (newTemplate) {
                      setState(() {
                        _selectedTemplate = newTemplate;
                        _generateSmartForm(); // Cập nhật lại form nội dung ngay lập tức
                      });
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Divider(),
                  ),

                  const Text(
                    'Thông tin Dâu Rể & Sự kiện',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepPink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Gắn Controller Cô Dâu
                      Expanded(
                        child: TextField(
                          controller: _brideController,
                          decoration: const InputDecoration(
                            labelText: 'Tên Cô dâu',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Gắn Controller Chú Rể
                      Expanded(
                        child: TextField(
                          controller: _groomController,
                          decoration: const InputDecoration(
                            labelText: 'Tên Chú rể',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Chỗ này chuyển từ TextField thành InkWell để làm nút Chọn Ngày
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate:
                            DateTime.now(), // Không cho chọn ngày trong quá khứ
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày diễn ra sự kiện',
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryPink,
                        ),
                      ),
                      // Hiển thị ngày đã chọn hoặc text mặc định
                      child: Text(
                        _selectedDate == null
                            ? 'Chưa chọn ngày'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================
  // WIDGET: TAB 2 - FORM TỰ ĐỘNG (DỰA THEO TEMPLATE)
  // ========================================================
  Widget _buildSmartFormTab() {
    if (_formSections.isEmpty) {
      return const Center(
        child: Text('Mẫu này không yêu cầu thêm nội dung chi tiết.'),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: _formSections.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            return _buildDynamicFormForSection(_formSections[index]);
          },
        ),
      ),
    );
  }

  Widget _buildDynamicFormForSection(SectionData section) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.secondaryPink.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconForType(section.type), color: AppTheme.deepPink),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: section.title),
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề hiển thị',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepPink,
                    ),
                    onChanged: (val) => section.title = val,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Render UI nhập liệu tương ứng
            if (section.type == 'our_story')
              OurStoryForm(
                section: section,
                onUpdate: () =>
                    setState(() {}), // Hàm callback cập nhật UI cha khi gõ
              )
            else if (section.type == 'timeline')
              TimelineForm(
                section: section,
                onUpdate: () => setState(() {}), // Hàm callback cập nhật UI cha
              )
            else if (section.type == 'gallery')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        imageQuality: 70,
                      );

                      if (image != null) {
                        SmartDialog.showLoading(
                          msg: 'Đang nén và tải ảnh lên Sachi 🌸...',
                        );

                        Uint8List fileBytes = await image.readAsBytes();
                        final publicUrl = await UploadService().uploadImageToR2(
                          fileBytes,
                          image.name,
                        );

                        SmartDialog.dismiss();

                        if (publicUrl != null) {
                          // ---> CẬP NHẬT TRẠNG THÁI UI Ở ĐÂY <---
                          setState(() {
                            // Khởi tạo danh sách ảnh nếu chưa có
                            section.content['images'] ??= <String>[];
                            // Thêm link ảnh mới vào danh sách
                            (section.content['images'] as List).add(publicUrl);
                          });
                          SmartDialog.showToast('Tải ảnh thành công!');
                        } else {
                          SmartDialog.showToast('Có lỗi xảy ra khi tải ảnh.');
                        }
                      }
                    },
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Thêm ảnh vào Album'),
                  ),
                  const SizedBox(height: 16),

                  // ---> KHU VỰC HIỂN THỊ ẢNH <---
                  Builder(
                    builder: (context) {
                      final List<dynamic>? images = section.content['images'];

                      // Nếu có ảnh -> Hiển thị dạng Lưới (Grid) thu nhỏ
                      if (images != null && images.isNotEmpty) {
                        return Wrap(
                          spacing: 12, // Khoảng cách ngang
                          runSpacing: 12, // Khoảng cách dọc
                          children: images.map((url) {
                            return Stack(
                              children: [
                                // Hiển thị Thumbnail ảnh
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.secondaryPink,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover, // Cắt ảnh vuông vắn
                                    ),
                                  ),
                                ),
                                // Nút Xóa ảnh (Dấu X góc trên bên phải)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: AppTheme.deepPink,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        images.remove(url);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      }

                      // Nếu chưa có ảnh -> Hiển thị hộp xám mặc định
                      return Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.secondaryPink,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Ảnh bạn tải lên sẽ hiển thị ở đây',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'our_story':
        return Icons.favorite_outline;
      case 'timeline':
        return Icons.timeline;
      case 'gallery':
        return Icons.photo_library_outlined;
      default:
        return Icons.widgets_outlined;
    }
  }
}

class OurStoryForm extends StatefulWidget {
  final SectionData section;
  final VoidCallback onUpdate;

  const OurStoryForm({
    super.key,
    required this.section,
    required this.onUpdate,
  });

  @override
  State<OurStoryForm> createState() => _OurStoryFormState();
}

class _OurStoryFormState extends State<OurStoryForm> {
  late TextEditingController _storyController;

  @override
  void initState() {
    super.initState();
    // Đọc dữ liệu cũ từ JSON content ra nếu có
    _storyController = TextEditingController(
      text: widget.section.content['text'] ?? '',
    );
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _storyController,
      maxLines: 5,
      decoration: const InputDecoration(
        hintText:
            'Nhập câu chuyện tình yêu của hai người, hành trình từ lúc gặp nhau đến khi chung đôi...',
        alignLabelWithHint: true,
      ),
      onChanged: (value) {
        // Cập nhật trực tiếp vào Map content của section
        widget.section.content['text'] = value.trim();
        widget.onUpdate(); // Báo cho màn hình chính biết dữ liệu thay đổi
      },
    );
  }
}

class TimelineForm extends StatefulWidget {
  final SectionData section;
  final VoidCallback onUpdate;

  const TimelineForm({
    super.key,
    required this.section,
    required this.onUpdate,
  });

  @override
  State<TimelineForm> createState() => _TimelineFormState();
}

class _TimelineFormState extends State<TimelineForm> {
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách mốc thời gian từ content JSON
    _items = widget.section.content['items'] ?? [];
    widget.section.content['items'] = _items; // Đảm bảo map không bị null
  }

  void _addItem() {
    setState(() {
      _items.add({'time': '', 'title': '', 'desc': ''});
    });
    widget.onUpdate();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Chưa có mốc thời gian nào. Hãy thêm mốc đầu tiên!',
              style: TextStyle(
                color: AppTheme.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Danh sách các mốc thời gian đang có
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = _items[index] as Map<String, dynamic>;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCream.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryPink.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Ô nhập Giờ/Thời gian (Nhỏ bên trái)
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      initialValue: item['time'],
                      decoration: const InputDecoration(
                        labelText: 'Giờ',
                        hintText: '18:00',
                      ),
                      onChanged: (val) {
                        item['time'] = val.trim();
                        widget.onUpdate();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. Ô nhập Tiêu đề & Mô tả (Bên phải)
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: item['title'],
                          decoration: const InputDecoration(
                            labelText: 'Tên sự kiện',
                            hintText: 'Đón khách / Khai tiệc',
                          ),
                          onChanged: (val) {
                            item['title'] = val.trim();
                            widget.onUpdate();
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: item['desc'],
                          decoration: const InputDecoration(
                            labelText: 'Mô tả ngắn (Không bắt buộc)',
                            hintText: 'Chụp ảnh lưu niệm tại Photobooth',
                          ),
                          onChanged: (val) {
                            item['desc'] = val.trim();
                            widget.onUpdate();
                          },
                        ),
                      ],
                    ),
                  ),

                  // 3. Nút xóa mốc thời gian này
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _removeItem(index),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Nút thêm mốc mới
        ElevatedButton.icon(
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryPink.withOpacity(0.2),
            foregroundColor: AppTheme.deepPink,
            elevation: 0,
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Thêm mốc thời gian'),
        ),
      ],
    );
  }
}
