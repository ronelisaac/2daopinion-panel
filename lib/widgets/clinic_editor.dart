import 'package:flutter/material.dart';
import '../controllers/clinic_controller.dart';
import '../core/localization.dart';
import '../core/clinic_messages.dart';
import '../domain/clinic.dart';

class ClinicEditor extends StatefulWidget {
  const ClinicEditor({super.key, required this.controller, this.previous});
  final ClinicController controller;
  final Clinic? previous;
  @override
  State<ClinicEditor> createState() => _ClinicEditorState();
}

class _ClinicEditorState extends State<ClinicEditor> {
  late final code = TextEditingController(text: widget.previous?.input.code);
  late final name = TextEditingController(text: widget.previous?.input.name);
  late final description = TextEditingController(
    text: widget.previous?.input.description,
  );
  final form = GlobalKey<FormState>();
  late final city = TextEditingController(text: widget.previous?.input.city);
  late final address = TextEditingController(
    text: widget.previous?.input.address,
  );
  late final email = TextEditingController(text: widget.previous?.input.email);
  late final phone = TextEditingController(text: widget.previous?.input.phone);
  @override
  void dispose() {
    code.dispose();
    name.dispose();
    description.dispose();
    city.dispose();
    address.dispose();
    email.dispose();
    phone.dispose();
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
          title: Text(
            widget.previous == null ? text.clinicCreate : text.clinicEdit,
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(text.clinicRequired),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: code,
                      enabled: !controller.busy && widget.previous == null,
                      maxLength: 32,
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: text.clinicCode,
                        helperText: text.clinicCodeHelp,
                        helperMaxLines: 5,
                        errorMaxLines: 4,
                      ),
                      validator: (value) => ClinicInput.validCode(value ?? '')
                          ? null
                          : text.clinicCodeInvalid,
                    ),
                    TextFormField(
                      controller: name,
                      enabled: !controller.busy,
                      maxLength: 100,
                      decoration: InputDecoration(
                        labelText: text.clinicName,
                        errorMaxLines: 4,
                      ),
                      validator: (value) => ClinicInput.validName(value ?? '')
                          ? null
                          : text.clinicNameInvalid,
                    ),
                    TextFormField(
                      controller: city,
                      enabled: !controller.busy,
                      maxLength: 100,
                      decoration: InputDecoration(
                        labelText: text.clinicCity,
                        errorMaxLines: 4,
                      ),
                      validator: (value) => ClinicInput.validCity(value ?? '')
                          ? null
                          : text.clinicCityInvalid,
                    ),
                    TextFormField(
                      controller: address,
                      enabled: !controller.busy,
                      maxLength: 200,
                      minLines: 2,
                      maxLines: 3,
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        labelText: text.clinicAddress,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          ClinicInput.validAddress(value ?? '')
                          ? null
                          : text.clinicAddressInvalid,
                    ),
                    TextFormField(
                      controller: email,
                      enabled: !controller.busy,
                      maxLength: 254,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: text.clinicEmail,
                        errorMaxLines: 4,
                      ),
                      validator: (value) => ClinicInput.validEmail(value ?? '')
                          ? null
                          : text.clinicEmailInvalid,
                    ),
                    TextFormField(
                      controller: phone,
                      enabled: !controller.busy,
                      maxLength: 16,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: text.clinicPhone,
                        helperText: text.clinicPhoneHelp,
                        helperMaxLines: 4,
                        errorMaxLines: 4,
                      ),
                      validator: (value) => ClinicInput.validPhone(value ?? '')
                          ? null
                          : text.clinicPhoneInvalid,
                    ),
                    TextFormField(
                      controller: description,
                      enabled: !controller.busy,
                      maxLength: 500,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: text.clinicDescription,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          ClinicInput.validDescription(value ?? '')
                          ? null
                          : text.clinicDescriptionInvalid,
                    ),
                    if (controller.issue != null)
                      Text(
                        clinicIssueLabel(context, controller.issue!),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (controller.busy)
                      LinearProgressIndicator(
                        semanticsLabel: text.clinicSaving,
                      ),
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
                      if (!form.currentState!.validate()) return;
                      final saved = await controller.save(
                        ClinicInput(
                          code.text,
                          name.text,
                          description.text,
                          city: city.text,
                          address: address.text,
                          email: email.text,
                          phone: phone.text,
                        ),
                        previous: widget.previous,
                      );
                      if (saved && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text(text.clinicSave),
            ),
          ],
        ),
      ),
    );
  }
}
