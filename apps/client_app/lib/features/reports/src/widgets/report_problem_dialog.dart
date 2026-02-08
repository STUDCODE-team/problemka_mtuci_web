import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class ReportProblemDialog extends StatefulWidget {
  const ReportProblemDialog({super.key});

  @override
  State<ReportProblemDialog> createState() => _ReportProblemDialogState();
}

class _ReportProblemDialogState extends State<ReportProblemDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).reportDialogSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    return AlertDialog(
      title: Text(strings.reportDialogTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              PMInput(
                label: strings.reportDialogTopic,
                hint: strings.reportDialogTopicHint,
                controller: _titleController,
              ),
              PMInput(
                label: strings.reportDialogLocation,
                hint: strings.reportDialogLocationHint,
                controller: _locationController,
              ),
              PMInput(
                label: strings.reportDialogCategory,
                hint: strings.reportDialogCategoryHint,
                controller: _categoryController,
              ),
              PMInput(
                label: strings.reportDialogDescription,
                hint: strings.reportDialogDescriptionHint,
                controller: _descriptionController,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        PMButton(
          text: strings.reportDialogSubmit,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? () {} : _submit,
        ),
      ],
    );
  }
}
