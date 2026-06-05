import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/providers/server_connection_provider.dart';

class ServerConnectionBanner extends ConsumerStatefulWidget {
  const ServerConnectionBanner({super.key});

  @override
  ConsumerState<ServerConnectionBanner> createState() =>
      _ServerConnectionBannerState();
}

class _ServerConnectionBannerState
    extends ConsumerState<ServerConnectionBanner> {
  bool _shouldShow = false;

  @override
  void initState() {
    super.initState();
    final isConnected = ref.read(serverConnectedProvider).isConnected;
    _shouldShow = !isConnected;
  }

  @override
  Widget build(BuildContext context) {
    final serverState = ref.watch(serverConnectedProvider);

    ref.listen<ServerConnectionState>(serverConnectedProvider, (
      previous,
      next,
    ) {
      if (next.isConnected) {
        if (previous == null || !previous.isConnected) {
          setState(() {
            _shouldShow = true;
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _shouldShow = false;
              });
            }
          });
        }
      } else {
        setState(() {
          _shouldShow = true;
        });
      }
    });

    final isError = !serverState.isConnected;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      top: _shouldShow ? 8 : -120,
      left: 12,
      right: 12,
      child: SafeArea(
        child: IgnorePointer(
          ignoring: !_shouldShow,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _shouldShow ? 1.0 : 0.0,
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
