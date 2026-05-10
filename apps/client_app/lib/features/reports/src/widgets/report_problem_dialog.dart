import 'package:client_app/features/reports/src/bloc/reports_bloc.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

class ReportProblemDialog extends StatefulWidget {
  const ReportProblemDialog({super.key});

  @override
  State<ReportProblemDialog> createState() => _ReportProblemDialogState();
}

class _ReportProblemDialogState extends State<ReportProblemDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  ReportCategory? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || location.isEmpty || description.isEmpty || _selectedCategory == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<ReportsBloc>().add(CreateReport(
          title: title,
          description: description,
          location: location,
          category: _selectedCategory!.apiValue,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportCreated) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.reportDialogSuccess)),
          );
        } else if (state is ReportsError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AlertDialog(
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
                DropdownButtonFormField<ReportCategory>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: strings.reportDialogCategory,
                    border: const OutlineInputBorder(),
                  ),
                  hint: Text(strings.reportDialogCategoryHint),
                  items: ReportCategory.values.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.label));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
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
      ),
    );
  }
}
