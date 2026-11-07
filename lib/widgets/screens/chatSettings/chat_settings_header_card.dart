import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ChatSettingsHeaderCard extends StatelessWidget {
  final String name;
  final String? profilePicUrl;
  final bool isGroupChat;
  final bool isMuted;
  final bool isPinned;
  final VoidCallback? onMuteToggle;
  final VoidCallback? onPinToggle;

  const ChatSettingsHeaderCard({
    super.key,
    required this.name,
    this.profilePicUrl,
    this.isGroupChat = false,
    this.isMuted = false,
    this.isPinned = false,
    this.onMuteToggle,
    this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isPicValid =
        profilePicUrl != null && File(profilePicUrl!).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: DefaultColorSheet.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DefaultColorSheet.divider(context),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          ClipOval(
            child: isPicValid
                ? Image.file(
                    File(profilePicUrl!),
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: Color(0xFF075E54),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: PrimaryText(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          PrimaryText(
            name,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: DefaultColorSheet.textPrimary(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          PrimaryText(
            isGroupChat ? 'Group Conversation' : 'Direct Conversation',
            fontSize: 13,
            color: DefaultColorSheet.textSecondary(context),
          ),
          const SizedBox(height: 18),

          // Quick Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickButton(
                context: context,
                icon: isMuted ? Icons.volume_off : Icons.volume_up,
                label: isMuted ? 'Unmute' : 'Mute',
                isActive: isMuted,
                onTap: onMuteToggle,
              ),
              const SizedBox(width: 24),
              _buildQuickButton(
                context: context,
                icon: LucideIcons.pin,
                label: isPinned ? 'Unpin' : 'Pin',
                isActive: isPinned,
                onTap: onPinToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    final activeColor = DefaultColorSheet.primary;
    final inactiveColor = DefaultColorSheet.textSecondary(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withValues(alpha: 0.15)
                    : (DefaultColorSheet.isDark(context)
                        ? DefaultColorSheet.darkSurface
                        : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 6),
            PrimaryText(
              label,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? activeColor : inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}

