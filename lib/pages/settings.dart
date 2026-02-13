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
                          ASession result;
                          try {
                            result = await createSession();
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
