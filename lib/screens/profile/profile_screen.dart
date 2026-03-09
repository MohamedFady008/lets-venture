import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_adventure/screens/profile/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset('assets/settings_back.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Obx(
              () => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _buildProfileImage(),
                      const SizedBox(height: 5),
                      _buildInfoContainer(controller.userEmail),
                      const SizedBox(height: 30),
                      _buildEditableInfoContainer(
                        'name'.tr,
                        controller.userName,
                        () => _showEditDialog(
                          context,
                          'name'.tr,
                          controller.userName,
                          (newName) => controller.updateUserName(newName),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildGameStats(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () => controller.updateUserImage(),
      child: Stack(
        children: [
          Obx(
            () => CircleAvatar(
              radius: 75,
              backgroundColor: Colors.indigo,
              backgroundImage:
                  controller.imageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(controller.imageUrl)
                      : null,
              child:
                  controller.imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 50)
                      : null,
            ),
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.edit, color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String value) {
    return Text(
      value,
      style: const TextStyle(fontSize: 20, color: Colors.grey),
      maxLines: 4,
    );
  }

  Widget _buildEditableInfoContainer(
    String label,
    String value,
    VoidCallback onEdit,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 18, color: Colors.indigo),
            ),
          ),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'edit'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStats() {
    return Obx(() {
      if (controller.isLoadingStats) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.gameStats.isEmpty) {
        return Center(child: Text('No game stats available'.tr));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Games Stats'.tr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ...controller.gameStats.map((game) {
            return Container(
              height: Get.height * 0.15,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/scroll_card.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${game['title']}'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Level: ${game['level']}'),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.blue, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${game['totalStars'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  void _showEditDialog(
    BuildContext context,
    String field,
    String currentValue,
    Function(String) onSave,
  ) {
    final TextEditingController textController = TextEditingController(
      text: currentValue,
    );
    Get.dialog(
      AlertDialog(
        title: Text('${'edit'.tr} $field'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(hintText: 'auth13'.tr),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('auth11'.tr)),
          TextButton(
            onPressed: () {
              onSave(textController.text);
              Get.back();
            },
            child: Text('done'.tr),
          ),
        ],
      ),
    );
  }
}
