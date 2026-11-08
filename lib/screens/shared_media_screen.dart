import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/modal/screens/userProfile/shared_media_arguments.dart';
import 'package:my_app/modal/shared_media_item_model.dart';
import 'package:my_app/providers/shared_media_provider.dart';
import 'package:my_app/widgets/screens/message/media_viewer_screen.dart';

class SharedMediaScreen extends ConsumerStatefulWidget {
  final SharedMediaArguments? arguments;

  const SharedMediaScreen({super.key, this.arguments});

  @override
  ConsumerState<SharedMediaScreen> createState() => _SharedMediaScreenState();
}

class _SharedMediaScreenState extends ConsumerState<SharedMediaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  SharedMediaArguments _getArguments(BuildContext context) {
    if (widget.arguments != null) {
      return widget.arguments!;
    }
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is SharedMediaArguments) {
      return routeArgs;
    }
    return const SharedMediaArguments(
      chatId: '',
      title: 'Shared Media',
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = _getArguments(context);
    final mediaAsync = ref.watch(sharedMediaProvider(args.chatId));

    return Scaffold(
      backgroundColor: DefaultColorSheet.scaffoldBg(context),
      appBar: AppBar(
        backgroundColor: DefaultColorSheet.appBarBg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: DefaultColorSheet.appBarIcon(context),
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          args.title.isNotEmpty ? args.title : 'Shared Media',
          style: TextStyle(
            color: DefaultColorSheet.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: DefaultColorSheet.primary,
          indicatorWeight: 3,
          labelColor: DefaultColorSheet.primary,
          unselectedLabelColor: DefaultColorSheet.textSecondary(context),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'Media'),
            Tab(text: 'Docs'),
            Tab(text: 'Audio'),
          ],
        ),
      ),
      body: mediaAsync.when(
        data: (items) {
          final visualMedia =
              items.where((i) => i.isImage || i.isVideo).toList();
          final docMedia = items.where((i) => i.isFile).toList();
          final audioMedia = items.where((i) => i.isAudio).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildVisualMediaGrid(visualMedia),
              _buildDocList(docMedia),
              _buildAudioList(audioMedia),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: DefaultColorSheet.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Failed to load media',
            style: TextStyle(color: DefaultColorSheet.textSecondary(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualMediaGrid(List<SharedMediaItemModel> items) {
    if (items.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.image,
        message: 'No images or videos shared yet',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final fileExists =
            item.location != null && File(item.location!).existsSync();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MediaViewerScreen(
                  media: item.toMediaTableData(),
                  senderName: item.senderName,
                  sentAt: item.createdAt.millisecondsSinceEpoch,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (fileExists)
                  Image.file(
                    File(item.location!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: DefaultColorSheet.inputFieldBg(context),
                      child: const Center(
                        child: Icon(
                          LucideIcons.imageOff,
                          color: DefaultColorSheet.grey400,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    color: DefaultColorSheet.inputFieldBg(context),
                    child: const Center(
                      child: Icon(
                        LucideIcons.image,
                        color: DefaultColorSheet.grey400,
                      ),
                    ),
                  ),
                if (item.isVideo)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocList(List<SharedMediaItemModel> items) {
    if (items.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.fileText,
        message: 'No documents shared yet',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        color: DefaultColorSheet.dividerColor(context),
        height: 1,
        indent: 68,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final dateStr = DateFormat('d MMM yyyy').format(item.createdAt);

        return ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DefaultColorSheet.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.fileText,
                color: DefaultColorSheet.primary,
                size: 22,
              ),
            ),
          ),
          title: Text(
            item.name.isNotEmpty ? item.name : 'Document',
            style: TextStyle(
              color: DefaultColorSheet.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${item.senderName} • $dateStr',
            style: TextStyle(
              color: DefaultColorSheet.textSecondary(context),
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioList(List<SharedMediaItemModel> items) {
    if (items.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.mic,
        message: 'No audio shared yet',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        color: DefaultColorSheet.dividerColor(context),
        height: 1,
        indent: 68,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final dateStr =
            DateFormat('d MMM yyyy, hh:mm a').format(item.createdAt);

        return ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DefaultColorSheet.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.mic,
                color: DefaultColorSheet.primary,
                size: 22,
              ),
            ),
          ),
          title: Text(
            item.name.isNotEmpty ? item.name : 'Voice message / Audio',
            style: TextStyle(
              color: DefaultColorSheet.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${item.senderName} • $dateStr',
            style: TextStyle(
              color: DefaultColorSheet.textSecondary(context),
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DefaultColorSheet.inputFieldBg(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: DefaultColorSheet.iconSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DefaultColorSheet.textSecondary(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

