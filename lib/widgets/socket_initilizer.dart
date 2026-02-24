import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/providers/socket_provider.dart';

class SocketInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const SocketInitializer({super.key, required this.child});

  @override
  ConsumerState<SocketInitializer> createState() => _SocketInitializerState();
}

class _SocketInitializerState extends ConsumerState<SocketInitializer> {
  @override
  void initState() {
    super.initState();

    ref.read(socketProvider);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
