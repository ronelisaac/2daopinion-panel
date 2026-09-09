import 'package:flutter/material.dart';
import '../controllers/intake_classification_controller.dart';
import '../core/localization.dart';

class ClassificationSpecialtyField extends StatelessWidget {
  const ClassificationSpecialtyField({
    super.key,
    required this.controller,
    required this.onChanged,
  });
  final IntakeClassificationController controller;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) =>
          !controller.catalogFailed &&
              !controller.catalogBusy &&
              controller.specialties.any((item) => item.id == value)
          ? null
          : text.doctorSpecialtyInvalid,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: text.doctorSpecialty,
              helperText: text.doctorCatalogHelp,
              helperMaxLines: 5,
              errorText: field.errorText,
              errorMaxLines: 4,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    controller.specialties.any((item) => item.id == field.value)
                    ? field.value
                    : null,
                isExpanded: true,
                items: controller.specialties
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          '${item.input.name} · ${item.input.code}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: controller.busy || controller.catalogBusy
                    ? null
                    : (value) {
                        field.didChange(value);
                        onChanged(value);
                      },
              ),
            ),
          ),
          if (controller.catalogBusy)
            const LinearProgressIndicator()
          else if (controller.catalogFailed)
            Text(text.doctorCatalogError)
          else if (controller.specialties.isEmpty)
            Text(text.doctorCatalogEmpty),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: controller.busy || controller.catalogBusy
                    ? null
                    : () {
                        field.didChange(null);
                        onChanged(null);
                        controller.loadSpecialties();
                      },
                child: Text(text.doctorCatalogRetry),
              ),
              if (controller.cursor != null)
                TextButton(
                  onPressed: controller.busy || controller.catalogBusy
                      ? null
                      : () => controller.loadSpecialties(more: true),
                  child: Text(text.doctorCatalogMore),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
