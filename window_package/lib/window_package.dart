library window_package;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WindowApi {
  /* 保存端口号 */
  static Future savePort(int port) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("port", port);
  }

  /* 读取端口号 */
  static Future loadPort() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("port")) {
      return prefs.getInt("port")!;
    }
    return 0;
  }

  static showEditPort(BuildContext context) {
    WindowApi.loadPort().then(
      (port) {
        TextEditingController controller = TextEditingController();
        controller.text = port.toString();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("监听端口号"),
              content: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(
                      "^([1-9]|[1-9]\\d|[1-9]\\d{2}|[1-9]\\d{3}|[1-5]\\d{4}|6[0-4]\\d{3}|65[0-4]\\d{2}|655[0-2]\\d|6553[0-5])\$")),
                  LengthLimitingTextInputFormatter(5),
                ],
                keyboardType: TextInputType.number,
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      port = int.parse(controller.text);
                      controller.dispose();
                      WindowApi.savePort(port);
                      Navigator.maybePop(context);
                    }
                  },
                  child: const Text("确定"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
