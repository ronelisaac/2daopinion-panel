import 'package:flutter/material.dart';
import '../controllers/doctor_controller.dart';
import '../core/localization.dart';
import '../domain/specialty.dart';

class DoctorSpecialtyField extends StatelessWidget {
  const DoctorSpecialtyField({
    super.key,
    required this.controller,
    required this.onChanged,
  });
  final DoctorController controller;
  final ValueChanged<Specialty?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return FormField<String>(
      validator: (value) =>
          !controller.catalogFailed &&
              !controller.catalogBusy &&
              controller.specialties.any((item) => item.id == value)
          ? null
          : text.doctorSpecialtyInvalid,
      builder: (field) {
        final selection = controller.specialties
            .where((item) => item.id == field.value)
            .firstOrNull;
        return Column(
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
                  value: selection?.id,
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
                          onChanged(
                            controller.specialties
                                .where((item) => item.id == value)
                                .firstOrNull,
                          );
                        },
                ),
              ),
            ),
            if (controller.catalogBusy) ...[
              const LinearProgressIndicator(),
              Text(text.doctorCatalogLoading),
            ] else if (controller.catalogFailed)
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
                if (controller.specialtyCursor != null)
                  TextButton(
                    onPressed: controller.busy || controller.catalogBusy
                        ? null
                        : () => controller.loadSpecialties(more: true),
                    child: Text(text.doctorCatalogMore),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
