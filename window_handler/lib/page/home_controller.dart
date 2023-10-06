import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:window_handler/main.dart';
import 'package:window_package/window_package.dart';

class HomeController extends GetxController {
  var port = 0.obs;
  var state = RxString("");

  WindowsDeviceInfo? windowsDeviceInfo;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    windowsDeviceInfo = await deviceInfo.windowsInfo;
    port.value = await WindowApi.loadPort();
    if (port.value != 0) {
      runService();
    }
  }

  /* 启动服务 */
  void runService() async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, port.value).then(
      (RawDatagramSocket udpSocket) {
        udpSocket.forEach((RawSocketEvent event) async {
          if (event == RawSocketEvent.write) {
            state.value = "服务已启动";
          }
          if (event == RawSocketEvent.read) {
            Datagram? dg = udpSocket.receive();
            if (dg != null) {
              //dg.data.forEach((x) => print(x));
              if (dg.data.first == 0) {
                //广播消息，回发自己的计算机信息
                List<int> data = const Utf8Encoder()
                    .convert(windowsDeviceInfo?.computerName ?? "");
                udpSocket.send(data, dg.address, dg.port);
              } else if (dg.data.first == 1) {
                //关机
                state.value = "已收到开机指令";
              } else if (dg.data.first == 2) {
                //关机
                state.value = "已收到关机指令";
                platform.invokeMethod("CloseWindows");
              } else {
                state.value = "已收到指令:${const Utf8Decoder().convert(dg.data)}";
              }
            }
          }
        });
      },
    );
  }
}
