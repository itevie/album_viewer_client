import 'package:album_viewer_client/api.dart';
import 'package:album_viewer_client/util/base_scaffold.dart';
import "package:dawn_ui_flutter/card.dart";
import 'package:album_viewer_client/pages/image_viewer.dart';
import 'package:album_viewer_client/util/util.dart';
import 'package:dawn_ui_flutter/prompts/prompts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final Map<String, IconData> tagIconMap = {
  'trams': Icons.tram,
  "buses": Icons.directions_bus,
  "bus": Icons.directions_bus,
  "bus type": Icons.directions_bus,
  "bus size": Icons.directions_bus,
  "macro": Icons.camera,
  "trains": Icons.train,
  "random": Icons.question_mark,
  "gay vehicles": Icons.flag,
  "ducks": Icons.pets,
  "wallpapers": Icons.wallpaper,
};

class TagViewer extends StatelessWidget {
  final String? baseSubTag;

  const TagViewer({super.key, this.baseSubTag});

  @override
  Widget build(BuildContext context) {
    List<String> subsCompleted = [];

    return BaseScaffold(
      fab:
          getPassword() != null
              ? FloatingActionButton(
                onPressed: () async {
                  final value = await showInputPrompt(
                    context,
                    Text("Enter Tag Name"),
                    null,
                  );

                  if (value == null) return;

                  try {
                    await createTag(value);
                    reloadPage();
                  } catch (e) {
                    showMessagePrompt(
                      // ignore: use_build_context_synchronously
                      context,
                      Text("Error"),
                      Text(e.toString()),
                    );
                  }
                },
                child: Icon(Icons.add),
              )
              : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0), // optional padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyCard(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder(
                        future: fetchStats(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else if (!snapshot.hasData) {
                            return Text("Loading stats...");
                          } else {
                            return Text(
                              "Stats: Photo Count: ${snapshot.data!.photoCount}, Tag Count: ${snapshot.data!.tagCount}, Album Size: ${prettyBytes(snapshot.data!.albumSize)}",
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Random Image"),
                      const SizedBox(height: 8),
                      FutureBuilder(
                        future: getRandom(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          } else {
                            return Material(
                              borderRadius: BorderRadius.circular(12),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  navigate(
                                    context,
                                    ImageViewer(photo: snapshot.data!),
                                  );
                                },
                                child: Image.network(
                                  width: 200,
                                  "${snapshot.data!.link}${getSmid()}&size=480",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future: fetchTags(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  return Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      if (baseSubTag != null)
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: MyCard(
                            onTap: () {
                              context.go("/");
                            },
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chevron_left, size: 48),
                                  const Text(
                                    "Back",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ...(snapshot.data ?? []).map((el) {
                        final sub = el.name.contains(";");

                        String base = sub ? el.name.split(";")[0] : el.name;
                        String? subTag = sub ? el.name.split(";")[1] : null;
                        IconData? icon;

                        if (baseSubTag == null) {
                          if (sub && subsCompleted.contains(base)) {
                            return null;
                          }

                          subsCompleted.add(base);
                          icon = tagIconMap[base.toLowerCase()];
                        } else {
                          if (base != baseSubTag) return null;
                          icon = tagIconMap[base.toLowerCase()];
                          base = subTag!;
                        }

                        return SizedBox(
                          width: 250,
                          height: 250,
                          child: MyCard(
                            onTap: () {
                              if (baseSubTag != null) {
                                context.go("/tags/${el.name}");
                              } else {
                                context.go(
                                  !sub ? "/tags/${el.name}" : "/subtags/$base",
                                );
                              }
                            },
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (icon != null) ...[
                                    Icon(icon, size: 48),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        niceFormat(base),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (sub && baseSubTag == null) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).whereType<SizedBox>(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

String prettyBytes(int bytes) {
  const units = ["B", "KB", "MB", "GB", "TB"];
  double size = bytes.toDouble();
  int unit = 0;

  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }

  return "${size.toStringAsFixed(2)} ${units[unit]}";
}
