import 'package:flutter/material.dart';
import '../controllers/panel_staff_controller.dart';
import '../core/localization.dart';
import '../core/staff_messages.dart';
import '../domain/panel_access.dart';
import '../domain/panel_staff.dart';

class StaffEditor extends StatefulWidget {
  const StaffEditor({super.key, required this.controller, this.user});
  final PanelStaffController controller;
  final PanelStaff? user;
  @override
  State<StaffEditor> createState() => _StaffEditorState();
}

class _StaffEditorState extends State<StaffEditor> {
  late final name = TextEditingController(text: widget.user?.name);
  late final email = TextEditingController(text: widget.user?.email);
  late final scopes = widget.user == null
      ? <String, Set<PanelRole>>{widget.controller.country: {}}
      : widget.user!.memberships.map(
          (country, roles) => MapEntry(country, {...roles}),
        );
  final form = GlobalKey<FormState>();
  bool invalidRoles = false;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => PopScope(
        canPop: !widget.controller.busy,
        child: AlertDialog(
          title: Text(widget.user == null ? text.staffCreate : text.staffEdit),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.user == null
                          ? text.staffInviteHint
                          : text.staffEditHint,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: name,
                      enabled: !widget.controller.busy,
                      maxLength: 100,
                      decoration: InputDecoration(labelText: text.staffName),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? text.staffInvalid
                          : null,
                    ),
                    TextFormField(
                      controller: email,
                      enabled: widget.user == null && !widget.controller.busy,
                      maxLength: 254,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: text.email),
                      validator: (value) =>
                          value == null ||
                              !RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(value.trim())
                          ? text.staffInvalid
                          : null,
                    ),
                    for (final country
                        in widget.controller.allowedCountries) ...[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          country == 'CL'
                              ? text.chile
                              : country == 'AR'
                              ? text.argentina
                              : country,
                        ),
                        value: scopes.containsKey(country),
                        onChanged:
                            widget.controller.busy ||
                                country == widget.controller.country
                            ? null
                            : (selected) => setState(() {
                                if (selected) {
                                  scopes[country] = {};
                                } else {
                                  scopes.remove(country);
                                }
                              }),
                      ),
                      if (scopes.containsKey(country))
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final role in PanelRole.values)
                              FilterChip(
                                label: Text(roleLabel(context, role)),
                                selected: scopes[country]!.contains(role),
                                onSelected: widget.controller.busy
                                    ? null
                                    : (selected) => setState(() {
                                        if (selected) {
                                          scopes[country]!.add(role);
                                        } else {
                                          scopes[country]!.remove(role);
                                        }
                                      }),
                              ),
                          ],
                        ),
                    ],
                    if (invalidRoles)
                      Text(
                        text.staffSelectRole,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (widget.controller.issue != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          staffMessage(context, widget.controller.issue!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    if (widget.controller.busy) const LinearProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: widget.controller.busy
                  ? null
                  : () => Navigator.pop(context, false),
              child: Text(text.cancel),
            ),
            TextButton(
              onPressed: widget.controller.busy
                  ? null
                  : () async {
                      setState(
                        () => invalidRoles =
                            scopes.isEmpty ||
                            scopes.values.any((roles) => roles.isEmpty),
                      );
                      if (!form.currentState!.validate() || invalidRoles) {
                        return;
                      }
                      final saved = await widget.controller.save(
                        user: widget.user,
                        name: name.text,
                        email: email.text,
                        memberships: scopes,
                      );
                      if (saved && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text(
                widget.user == null ? text.staffCreateSend : text.staffSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
