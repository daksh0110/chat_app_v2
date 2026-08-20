import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:photo_manager/photo_manager.dart';

/// A small multi-select gallery picker backed by `photo_manager`.
class MediaPickerSheet extends StatefulWidget {
  const MediaPickerSheet({super.key, required this.onSelected});

  final ValueChanged<List<File>> onSelected;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<List<File>> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MediaPickerSheet(onSelected: onSelected),
    );
  }

  @override
  State<MediaPickerSheet> createState() => _MediaPickerSheetState();
}

class _MediaPickerSheetState extends State<MediaPickerSheet> {
  final Set<AssetEntity> _selected = {};
  List<AssetEntity> _assets = [];
  bool _loading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _loading = false;
        });
      }
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.common,
    );
    final assets = albums.isEmpty
        ? <AssetEntity>[]
        : await albums.first.getAssetListPaged(page: 0, size: 120);
    if (mounted) {
      setState(() {
        _assets = assets;
        _loading = false;
      });
    }
  }

  Future<void> _sendSelected() async {
    final files = await Future.wait(_selected.map((asset) => asset.originFile));
    final validFiles = files.whereType<File>().toList();
    if (validFiles.isEmpty || !mounted) return;
    Navigator.of(context).pop();
    widget.onSelected(validFiles);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.sizeOf(context).height * .74,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                  const Expanded(
                    child: Text(
                      'Select media',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _selected.isEmpty ? null : _sendSelected,
                    child: Text(
                      'Add${_selected.isEmpty ? '' : ' (${_selected.length})'}',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_permissionDenied) {
      return Center(
        child: TextButton(
          onPressed: PhotoManager.openSetting,
          child: const Text('Allow photo access in Settings'),
        ),
      );
    }
    if (_assets.isEmpty) {
      return const Center(child: Text('No photos or videos found'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(3),
      itemCount: _assets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final selected = _selected.contains(asset);
        return GestureDetector(
          onTap: () => setState(
            () => selected ? _selected.remove(asset) : _selected.add(asset),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<Uint8List?>(
                future: asset.thumbnailDataWithSize(
                  const ThumbnailSize.square(240),
                ),
                builder: (_, snapshot) => snapshot.hasData
                    ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                    : const ColoredBox(color: Color(0xFFF1F3F2)),
              ),
              if (asset.type == AssetType.video)
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.video,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF1E9A72) : Colors.black38,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
