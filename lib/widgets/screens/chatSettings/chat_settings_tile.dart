import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ChatSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const ChatSettingsTile({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isDestructive
        ? Colors.redAccent
        : (iconColor ?? DefaultColorSheet.primary);
    final effectiveTitleColor = isDestructive
        ? Colors.redAccent
        : DefaultColorSheet.textPrimary(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor ??
                    (isDestructive
                        ? Colors.redAccent.withValues(alpha: 0.12)
                        : effectiveIconColor.withValues(alpha: 0.12)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryText(
                    title,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: effectiveTitleColor,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    PrimaryText(
                      subtitle!,
                      fontSize: 12.5,
                      color: DefaultColorSheet.textSecondary(context),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: DefaultColorSheet.textSecondary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

