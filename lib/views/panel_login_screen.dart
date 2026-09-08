import 'package:flutter/material.dart';
import '../controllers/panel_login_controller.dart';
import '../core/localization.dart';
import '../core/panel_session_scope.dart';
import '../domain/panel_access.dart';
import '../widgets/responsive_content.dart';

class PanelLoginScreen extends StatefulWidget {
  const PanelLoginScreen({super.key, required this.createController});
  final PanelLoginController Function() createController;
  @override
  State<PanelLoginScreen> createState() => _PanelLoginScreenState();
}

class _PanelLoginScreenState extends State<PanelLoginScreen> {
  late final controller = widget.createController();
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    password.clear();
    password.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final session = PanelSessionScope.of(context);
    bool isBusy() => controller.busy || session.loading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ResponsiveContent(
            maxWidth: 480,
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 96,
                    semanticLabel: text.appTitle,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    text.loginTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(text.internalAccounts),
                  const SizedBox(height: 16),
                  if (session.loading) const LinearProgressIndicator(),
                  if (session.issue != null)
                    Text(accessMessage(context, session.issue!)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: email,
                    enabled: !isBusy(),
                    maxLength: 254,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: text.email),
                  ),
                  TextField(
                    controller: password,
                    enabled: !isBusy(),
                    maxLength: 128,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(labelText: text.password),
                  ),
                  if (controller.issue != null)
                    Text(
                      controller.issue == PanelAccessIssue.invalid
                          ? text.invalidLogin
                          : accessMessage(context, controller.issue!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isBusy()
                        ? null
                        : () async {
                            final principal = await controller.signIn(
                              email.text,
                              password.text,
                            );
                            if (mounted) {
                              password.clear();
                              if (principal != null) {
                                session.acceptAuthenticated(principal);
                              }
                            }
                          },
                    child: Text(text.signIn),
                  ),
                  if (controller.resetSent) Text(text.resetSent),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isBusy()
                        ? null
                        : () => controller.resetPassword(email.text),
                    child: Text(text.forgotPassword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
