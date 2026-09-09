import 'package:flutter/material.dart';
import '../controllers/doctor_controller.dart';
import '../core/doctor_messages.dart';
import '../core/localization.dart';
import '../domain/doctor_record.dart';

class DoctorReviewEditor extends StatefulWidget {
  const DoctorReviewEditor({
    super.key,
    required this.controller,
    required this.record,
  });
  final DoctorController controller;
  final DoctorRecord record;
  @override
  State<DoctorReviewEditor> createState() => _DoctorReviewEditorState();
}

class _DoctorReviewEditorState extends State<DoctorReviewEditor> {
  final evidence = TextEditingController();
  final note = TextEditingController();
  final form = GlobalKey<FormState>();
  late DoctorStatus decision = DoctorStatus.values.firstWhere(
    widget.record.permits,
  );
  bool identity = false;
  bool title = false;
  bool specialty = false;
  bool checksError = false;
  @override
  void dispose() {
    evidence.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => PopScope(
        canPop: !controller.busy,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: Text(text.doctorReview),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.record.input.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(text.doctorReviewIntro),
                    if (!widget.record.input.linked)
                      Text(text.doctorLegacySpecialty),
                    const SizedBox(height: 12),
                    Text(text.doctorSource),
                    SelectableText(text.doctorSourceUrl),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DoctorStatus>(
                      initialValue: decision,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: text.doctorDecision,
                      ),
                      items: DoctorStatus.values
                          .where(widget.record.permits)
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                doctorStatusLabel(context, status),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: controller.busy
                          ? null
                          : (value) => setState(() => decision = value!),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(text.doctorIdentityCheck),
                      value: identity,
                      onChanged: controller.busy
                          ? null
                          : (value) => setState(() => identity = value!),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(text.doctorTitleCheck),
                      value: title,
                      onChanged: controller.busy
                          ? null
                          : (value) => setState(() => title = value!),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(text.doctorSpecialtyCheck),
                      value: specialty,
                      onChanged: controller.busy
                          ? null
                          : (value) => setState(() => specialty = value!),
                    ),
                    if (checksError)
                      Text(
                        text.doctorChecksRequired,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    TextFormField(
                      controller: evidence,
                      enabled: !controller.busy,
                      maxLength: 200,
                      decoration: InputDecoration(
                        labelText: text.doctorEvidence,
                        helperText: text.doctorEvidenceHelp,
                        helperMaxLines: 5,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          (value?.trim().length ?? 0) >= 3 &&
                              value!.trim().length <= 200
                          ? null
                          : text.doctorEvidenceInvalid,
                    ),
                    TextFormField(
                      controller: note,
                      enabled: !controller.busy,
                      maxLength: 2000,
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: text.doctorReviewNote,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          (value?.trim().length ?? 0) >= 10 &&
                              value!.trim().length <= 2000
                          ? null
                          : text.doctorNoteInvalid,
                    ),
                    if (controller.issue != null)
                      Text(
                        doctorIssueLabel(context, controller.issue!),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (controller.busy) const LinearProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: controller.busy
                  ? null
                  : () => Navigator.pop(context, false),
              child: Text(text.cancel),
            ),
            FilledButton(
              onPressed: controller.busy
                  ? null
                  : () async {
                      setState(
                        () => checksError =
                            decision == DoctorStatus.verified &&
                            !(identity && title && specialty),
                      );
                      if (!form.currentState!.validate() || checksError) return;
                      final saved = await controller.review(
                        widget.record,
                        DoctorReview(
                          status: decision,
                          evidence: evidence.text,
                          note: note.text,
                          identityChecked: identity,
                          titleChecked: title,
                          specialtyChecked: specialty,
                        ),
                      );
                      if (saved && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text(text.doctorSaveReview),
            ),
          ],
        ),
      ),
    );
  }
}
