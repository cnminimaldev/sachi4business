import 'package:flutter/material.dart';
import '../../models/invitation.dart';

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
