import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:window_package/window_package.dart';
import 'package:window_tool/model/window.dart';

class HomeController extends GetxController with StateMixin {
  int port = 0;

  RawDatagramSocket? socket;

  RxList<Windows> data = RxList.empty();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  @override
  void onClose() {
    super.onClose();
    socket?.close();
  }

  void init() async {
    port = await WindowApi.loadPort();
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    if (socket != null) {
      socket!.broadcastEnabled = true;
      socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.write) {
          sendBroadcast();
        }
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket!.receive();
          if (datagram != null) {
            String name = const Utf8Decoder().convert(datagram.data);
            if (!data.any(
                (element) => element.ip!.address == datagram.address.address)) {
              Windows windows = Windows()
                ..name = name
                ..ip = datagram.address;
              data.add(windows);
              change(null, status: RxStatus.success());
            }
          }
        }
      });
      change(null, status: RxStatus.success());
    }
  }

  /* 发送广播 - 在线 */
  void sendBroadcast() {
    if (socket != null && port != 0) {
      socket!.send([0], InternetAddress("255.255.255.255"), port);
    }
  }

  /* 开启电脑 */
  void sendOpen(InternetAddress ip) async {
    var socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 19898);
    socket.send([1], InternetAddress(ip.address), port);
  }

  /* 关闭电脑 */
  void sendShutDown(InternetAddress ip) async {
    var socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 19898);
    socket.send([2], InternetAddress(ip.address), port);
  }

  /* 选择一个IP */
  void choseIP(int index) {
    showModalBottomSheet(
      context: Get.context!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data[index].ip!.address,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              GridView(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                children: [
                  ElevatedButton(
                    onPressed: () {
                      sendOpen(data[index].ip!);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/images/send.svg",
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("开机"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      sendShutDown(data[index].ip!);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/images/close.svg",
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("关机"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      socket?.send(
                          const Utf8Encoder()
                              .convert("测试${Random().nextDouble()}"),
                          InternetAddress(data[index].ip!.address),
                          port);
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text("测试"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
