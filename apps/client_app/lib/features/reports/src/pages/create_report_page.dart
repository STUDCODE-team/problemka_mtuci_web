import 'package:auto_route/auto_route.dart';
import 'package:client_app/features/reports/src/bloc/reports_bloc.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

@RoutePage()
class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _roomController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReportCategory? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _roomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final room = _roomController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || location.isEmpty || description.isEmpty || _selectedCategory == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    context.read<ReportsBloc>().add(CreateReport(
          title: title,
          description: description,
          location: location,
          room: room.isEmpty ? null : room,
          category: _selectedCategory!.apiValue,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.reportDialogSuccess)),
          );
          context.router.maybePop();
        } else if (state is ReportsError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(strings.reportCreateTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
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
                      label: strings.reportDetailRoom,
                      hint: strings.reportRoomHint,
                      controller: _roomController,
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
                    _DescriptionField(
                      label: strings.reportDialogDescription,
                      hint: strings.reportDialogDescriptionHint,
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 8),
                    PMButton(
                      text: strings.reportDialogSubmit,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? () {} : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _DescriptionField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(label,
            style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: context.colors.secondaryContainer,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            hintStyle: context.texts.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          style: context.texts.bodyLarge?.copyWith(color: context.colors.onSurface),
        ),
      ],
    );
  }
}
