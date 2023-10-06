import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:window_package/window_package.dart';
import 'package:window_tool/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          "Local Network",
          style: TextStyle(
            fontFamily: "ITC",
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.sendBroadcast();
            },
            icon: SvgPicture.asset(
              "assets/images/search.svg",
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              WindowApi.showEditPort(context);
            },
            icon: SvgPicture.asset(
              "assets/images/setting.svg",
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: controller.obx(
        (state) => ListView.builder(
          itemCount: controller.data.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                controller.choseIP(index);
              },
              title: Row(
                children: [
                  Text(
                    controller.data[index].name!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    "(${controller.data[index].ip!.address})",
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
              trailing: Text(
                controller.data[index].ip!.type.name,
                style: const TextStyle(fontSize: 16),
              ),
            );
          },
        ),
        onLoading: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
