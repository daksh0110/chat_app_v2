import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/network/api_constant.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/providers/token_provider.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/primary_textfield_area.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';

class SupportTicketSheet extends ConsumerStatefulWidget {
  const SupportTicketSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SupportTicketSheet(),
    );
  }

  @override
  ConsumerState<SupportTicketSheet> createState() => _SupportTicketSheetState();
}

class _SupportTicketSheetState extends ConsumerState<SupportTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userPreferenceTableProvider).value;
      if (user != null) {
        ref.read(userPreferenceTableProvider.notifier).getUser().first.then((userData) {
          if (userData != null && mounted) {
            if (_nameController.text.isEmpty && userData.name.isNotEmpty) {
              _nameController.text = userData.name;
            }
            if (_emailController.text.isEmpty && userData.email.isNotEmpty) {
              _emailController.text = userData.email;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final token = await ref.read(tokenProvider.future);
      final apiClient = ApiClient();
      final response = await apiClient.post(
        "${ApiConstants.baseUrl}/support",
        {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
        },
        token: token,
      );

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        Navigator.pop(context);
        ToastHelper.show(
          context: context,
          message: 'Support request submitted! We will get back to you shortly.',
          type: ToastificationType.success,
        );
      } else {
        ToastHelper.show(
          context: context,
          message: response?['message'] ?? 'Failed to submit request',
          type: ToastificationType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(
          context: context,
          message: 'Error submitting support query. Please try again.',
          type: ToastificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + keyboardPadding),
      decoration: BoxDecoration(
        color: DefaultColorSheet.surfaceBg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DefaultColorSheet.divider(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DefaultColorSheet.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.lifeBuoy,
                      color: DefaultColorSheet.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help & Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: DefaultColorSheet.textPrimary(context),
                          ),
                        ),
                        Text(
                          'Report an issue, bug, or send feedback',
                          style: TextStyle(
                            fontSize: 12,
                            color: DefaultColorSheet.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: DefaultColorSheet.iconColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                label: 'Your Name',
                controller: _nameController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PrimaryTextField(
                label: 'Your Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PrimaryTextField(
                label: 'Subject',
                controller: _subjectController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Message',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DefaultColorSheet.primary,
                ),
              ),
              const SizedBox(height: 8),
              PrimaryTextAreaField(
                labelText: 'Describe the issue or feedback',
                hintText: 'Provide details about what went wrong...',
                controller: _messageController,
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: _submitting ? 'Submitting...' : 'Submit Support Request',
                onPressed: _submitting ? () {} : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

