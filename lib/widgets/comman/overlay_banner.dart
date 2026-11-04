import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/providers/server_connection_provider.dart';
import 'package:my_app/providers/socket_provider.dart';

class OverLayBanner extends ConsumerStatefulWidget {
  const OverLayBanner({super.key, required this.enabled});

  final bool enabled;

  @override
  ConsumerState<OverLayBanner> createState() => _OverLayBannerState();
}

class _OverLayBannerState extends ConsumerState<OverLayBanner> {
  bool _shouldShow = false;
  Timer? _hideTimer;

  @override
  void didUpdateWidget(covariant OverLayBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled == widget.enabled) return;

    _hideTimer?.cancel();
    final socketInitialized = ref.read(socketProvider).isInitialized;
    final isConnected = ref.read(serverConnectedProvider).isConnected;
    _shouldShow = widget.enabled && socketInitialized && !isConnected;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverState = ref.watch(serverConnectedProvider);

    ref.listen<ServerConnectionState>(serverConnectedProvider, (
      previous,
      next,
    ) {
      if (!widget.enabled || !ref.read(socketProvider).isInitialized) return;

      if (next.isConnected) {
        if (previous == null || !previous.isConnected) {
          _hideTimer?.cancel();
          setState(() {
            _shouldShow = true;
          });
          _hideTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _shouldShow = false;
              });
            }
          });
        }
      } else {
        _hideTimer?.cancel();
        setState(() {
          _shouldShow = true;
        });
      }
    });

    final isError = !serverState.isConnected;
    final shouldShow =
        widget.enabled && ref.read(socketProvider).isInitialized && _shouldShow;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      top: shouldShow ? 8 : -120,
      left: 12,
      right: 12,
      child: SafeArea(
        child: IgnorePointer(
          ignoring: !shouldShow,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: shouldShow ? 1.0 : 0.0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isError
                        ? const [
                            DefaultColorSheet.red100,
                            DefaultColorSheet.error,
                          ]
                        : const [
                            DefaultColorSheet.green500,
                            DefaultColorSheet.primary,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isError
                                  ? DefaultColorSheet.error
                                  : DefaultColorSheet.primary)
                              .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: isError
                          ? const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        serverState.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
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
