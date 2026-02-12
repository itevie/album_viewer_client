import 'package:album_viewer_client/api.dart';
import 'package:album_viewer_client/confirm_prompt.dart';
import 'package:album_viewer_client/image_viewer.dart';
import 'package:album_viewer_client/message_prompt.dart';
import 'package:album_viewer_client/popup_menu.dart';
import 'package:album_viewer_client/selector_prompt.dart';
import 'package:album_viewer_client/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImageGrid extends StatefulWidget {
  final List<Photo> photos;
  final int? view;

  const ImageGrid({super.key, required this.photos, this.view});

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  final Set<int> selectedIds = {};
  bool selectionMode = false;

  void toggle(List<int> ids) {
    if (getPassword() == null) return;

    setState(() {
      for (final id in ids) {
        if (selectedIds.contains(id)) {
          selectedIds.remove(id);
        } else {
          selectedIds.add(id);
        }

        if (selectedIds.isEmpty) {
          selectionMode = false;
        }
      }
    });
  }

  Map<String, List<Photo>> makePhotoGroups() {
    Map<String, List<Photo>> photos = {};

    for (final photo in widget.photos.reversed) {
      final formatted = formatPretty(photo.addedAt);

      if (!photos.containsKey(formatted)) {
        photos[formatted] = [photo];
      } else {
        photos[formatted]!.add(photo);
      }
    }

    return photos;
  }

  void manageTag(Set<int> photoIds, int op) async {
    try {
      final tags = await fetchTags();
      final tag = await showSelectPrompt(
        // ignore: use_build_context_synchronously
        context,
        const Text("Select Tag"),
        Map.fromEntries(tags.map((x) => MapEntry(x.id, x.name))),
      );
      if (tag == null) return;
      await manageImageTags(photoIds.toList(), tag, op);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showMessagePrompt(context, Text("Error"), Text(e.toString()));
    }

    setState(() {
      selectedIds.clear();
      selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.view != null &&
          widget.photos.any((x) => x.id == widget.view)) {
        navigate(
          context,
          ImageViewer(
            photo: widget.photos.firstWhere((x) => x.id == widget.view),
          ),
        );
      }
    });

    final groups = makePhotoGroups().entries.toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final tileWidth = 200;
    final crossAxisCount = (screenWidth / tileWidth).floor().clamp(2, 6);

    Widget scrollView = CustomScrollView(
      slivers: [
        for (final group in groups) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Row(
                children: [
                  Text(
                    group.key,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Divider()),
                  const SizedBox(width: 4),
                  if (getPassword() != null)
                    PopupMenu(
                      items: [
                        (
                          callback: () {
                            manageTag(group.value.map((x) => x.id).toSet(), 0);
                          },
                          icon: Icons.sell,
                          name: "Add Tag",
                        ),
                        (
                          callback: () {
                            setState(() {
                              selectionMode = true;
                            });
                            toggle(group.value.map((x) => x.id).toList());
                          },
                          icon: Icons.select_all,
                          name: "Select All",
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final photo = group.value[index];
                final isSelected = selectedIds.contains(photo.id);

                return buildPhotoTile(
                  photo: photo,
                  isSelected: isSelected,
                  onTap: () {
                    if (selectionMode) {
                      toggle([photo.id]);
                    } else {
                      navigate(context, ImageViewer(photo: photo));
                    }
                  },
                  onLongPress: () {
                    setState(() => selectionMode = true);
                    toggle([photo.id]);
                  },
                );
              }, childCount: group.value.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 4 / 3,
              ),
            ),
          ),
        ],
      ],
    );

    if (selectedIds.isEmpty) return scrollView;

    return Column(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                manageTag(selectedIds, 0);
              },
              icon: const Icon(Icons.sell),
              label: const Text("Add Tag"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                manageTag(selectedIds, 1);
              },
              icon: const Icon(Icons.sell_outlined),
              label: const Text("Remove Tag"),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () async {
                bool result = await showConfirmPrompt(
                  context,
                  Text("Confirm"),
                  Text(
                    "Are you sure you want to delete ${selectedIds.length} photos?",
                  ),
                );

                if (!result) return;

                try {
                  await deletePhotos(selectedIds.toList());
                  reloadPage();
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  showMessagePrompt(context, Text("Error"), Text(e.toString()));
                }
              },
              icon: const Icon(Icons.delete),
              label: const Text("Delete"),
            ),
            Text("Selected: ${selectedIds.length}"),
          ],
        ),
        Expanded(child: scrollView),
      ],
    );
  }
}

Widget buildPhotoTile({
  required Photo photo,
  required bool isSelected,
  required VoidCallback onTap,
  required VoidCallback onLongPress,
}) {
  return Material(
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            "${photo.link}${getSmid()}&size=480",
            fit: BoxFit.cover,
          ),
          if (isSelected) Container(color: Colors.black38),
          if (isSelected)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.check_circle, color: Colors.white),
            ),
        ],
      ),
    ),
  );
}

String ordinal(int day) {
  if (day >= 11 && day <= 13) return '${day}th';

  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

String formatPretty(DateTime date) {
  final weekday = DateFormat('EEEE').format(date);
  final month = DateFormat('MMMM').format(date);

  return '$weekday, ${ordinal(date.day)} $month, ${date.year}';
}
