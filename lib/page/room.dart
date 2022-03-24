import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pclip_mobile/controller/room_controller.dart';
import 'package:pclip_mobile/page/room_setting.dart';
import 'package:pclip_mobile/widget/message_actions_bottomsheet.dart';
import 'package:pclip_mobile/widget/progress_dialog.dart';
import 'package:pclip_mobile/widget/refresh_indicator.dart';
import 'package:pclip_mobile/widget/message.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RoomPage extends StatefulWidget {
  late final RoomController controller;
  RoomPage({
    Key? key,
  }) : super(key: key) {
    controller = RoomController(
      authRepository: Get.find(),
      client: Get.find(),
    );
  }

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      try {
        widget.controller.scrollController.jumpTo(
            widget.controller.scrollController.position.maxScrollExtent);
      } finally {}
    });
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    widget.controller.refreshController.loadFailed();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    widget.controller.sendMessage(_messageController.text);
    _messageController.text = "";
  }

  Future<void> _deleteMessage(String id) async {
    Get.dialog(
      const ProgressDialog(),
      barrierDismissible: false,
    );
    try {
      await widget.controller.deleteMessage(id);
    } finally {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.controller.room.name),
        actions: [
          IconButton(
            onPressed: () =>
                Get.to(() => RoomSettingPage(), arguments: Get.arguments),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Flexible(
              child: GetX<RoomController>(
                init: widget.controller,
                builder: (controller) => SmartRefresher(
                  enablePullDown: false,
                  scrollController: controller.scrollController,
                  enablePullUp: true,
                  enableTwoLevel: false,
                  onLoading: _onRefresh,
                  footer: footerRefreshIndicator(),
                  controller: controller.refreshController,
                  child: GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: ListView.builder(
                      itemCount: controller.messages.value.length,
                      controller: widget.controller.scrollController,
                      itemBuilder: (context, index) {
                        final message = controller.messages.value[index];
                        return Message(
                          message: message.message,
                          isOwner: message.isOwner,
                          onLongPress: () => Get.bottomSheet(
                            MessageActionsBottomSheet(
                              onCopy: () => {},
                              onDelete: () => _deleteMessage(message.id),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 99,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Aa",
                  prefixIcon: IconButton(
                    onPressed: () => {},
                    icon: const Icon(Icons.add_circle_rounded),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
