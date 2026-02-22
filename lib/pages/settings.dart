import 'package:album_viewer_client/api.dart';
import 'package:album_viewer_client/util/base_scaffold.dart';
import 'package:album_viewer_client/util/util.dart';
import 'package:dawn_ui_flutter/prompts/prompts.dart';
import "package:dawn_ui_flutter/card.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Admin Login",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final password = await showInputPrompt(
                      context,
                      Text("Enter Password"),
                      null,
                    );

                    if (password == null) return;

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('password', password);
                    reloadPage();
                  },
                  child: Text("Login"),
                ),
              ],
            ),
          ),
          if (getPassword() != null)
            MyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Session Management",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final duration = await showDurationPrompt(context);

                          ASession result;
                          try {
                            result = await createSession(duration!);
                          } catch (e) {
                            showMessagePrompt(
                              // ignore: use_build_context_synchronously
                              context,
                              const Text("Error"),
                              Text(e.toString()),
                            );
                            return;
                          }

                          final url = "${Uri.base.origin}?smid=${result.id}";

                          showMessagePrompt(
                            // ignore: use_build_context_synchronously
                            context,
                            Text("Session"),
                            Text(url),
                            extraButtons: [
                              TextButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: url));
                                },
                                child: const Text("Copy"),
                              ),
                            ],
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Make"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Future<int?> showDurationPrompt(BuildContext context) async {
  final TextEditingController controller = TextEditingController(text: "1");
  String selectedUnit = "day";

  const Map<String, int> unitMultipliers = {
    "hour": 60 * 60 * 1000,
    "day": 24 * 60 * 60 * 1000,
    "week": 7 * 24 * 60 * 60 * 1000,
    "month": 30 * 24 * 60 * 60 * 1000,
    "year": 365 * 24 * 60 * 60 * 1000,
  };

  return await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Enter Duration"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Amount"),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedUnit,
                  isExpanded: true,
                  items:
                      unitMultipliers.keys
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedUnit = value;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final int amount = int.tryParse(controller.text) ?? 0;
              final int result = amount * unitMultipliers[selectedUnit]!;
              Navigator.pop(context, result);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
