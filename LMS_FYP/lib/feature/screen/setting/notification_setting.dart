import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller for managing notification preferences
class NotificationPreferencesController extends GetxController {
  // General notification toggle
  var isNotificationsEnabled = true.obs;

  // Notification type preferences based on your NotificationStatus enum
  var systemNotifications = true.obs;
  var promotionNotifications = true.obs;
  var messageNotifications = true.obs;
  var alertNotifications = true.obs;
  var testNotifications = true.obs;

  // Delivery preferences
  var pushNotifications = true.obs;
  var emailNotifications = false.obs;
  var smsNotifications = false.obs;

  // Sound and vibration preferences
  var notificationSound = true.obs;
  var vibration = true.obs;

  // Time preferences
  var quietHoursEnabled = false.obs;
  var quietStartTime = TimeOfDay(hour: 22, minute: 0).obs;
  var quietEndTime = TimeOfDay(hour: 8, minute: 0).obs;

  // Summary preferences
  var dailySummary = false.obs;
  var weeklySummary = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  void loadPreferences() {
    // Load preferences from SharedPreferences or API
    // This is where you would load saved preferences
    print('Loading notification preferences...');
  }

  void savePreferences() {
    // Save preferences to SharedPreferences or API
    print('Saving notification preferences...');
    Get.snackbar(
      'Success',
      'Notification preferences saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void resetToDefaults() {
    isNotificationsEnabled.value = true;
    systemNotifications.value = true;
    promotionNotifications.value = true;
    messageNotifications.value = true;
    alertNotifications.value = true;
    testNotifications.value = true;
    pushNotifications.value = true;
    emailNotifications.value = false;
    smsNotifications.value = false;
    notificationSound.value = true;
    vibration.value = true;
    quietHoursEnabled.value = false;
    dailySummary.value = false;
    weeklySummary.value = false;
  }
}

class NotificationPreferencesScreen extends StatelessWidget {
  final NotificationPreferencesController controller = Get.put(
    NotificationPreferencesController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Notifications'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              _showResetDialog(context);
            },
            child: Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Master Toggle
              _buildSectionCard(
                title: 'General Settings',
                children: [_buildMasterToggle()],
              ),

              SizedBox(height: 16),

              // Notification Types
              _buildSectionCard(
                title: 'Notification Types',
                children: [
                  _buildNotificationTypeToggle(
                    'System Notifications',
                    'App updates, maintenance alerts',
                    Icons.settings,
                    controller.systemNotifications,
                    Colors.blue,
                  ),
                  _buildNotificationTypeToggle(
                    'Promotion Notifications',
                    'Special offers, new courses',
                    Icons.local_offer,
                    controller.promotionNotifications,
                    Colors.orange,
                  ),
                  _buildNotificationTypeToggle(
                    'Message Notifications',
                    'Direct messages, replies',
                    Icons.message,
                    controller.messageNotifications,
                    Colors.green,
                  ),
                  _buildNotificationTypeToggle(
                    'Alert Notifications',
                    'Important alerts, deadlines',
                    Icons.warning,
                    controller.alertNotifications,
                    Colors.red,
                  ),
                  _buildNotificationTypeToggle(
                    'Test Notifications',
                    'Quiz reminders, test results',
                    Icons.quiz,
                    controller.testNotifications,
                    Colors.purple,
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Delivery Methods
              _buildSectionCard(
                title: 'Delivery Methods',
                children: [
                  _buildDeliveryToggle(
                    'Push Notifications',
                    'Receive notifications on your device',
                    Icons.notifications,
                    controller.pushNotifications,
                  ),
                  _buildDeliveryToggle(
                    'Email Notifications',
                    'Receive notifications via email',
                    Icons.email,
                    controller.emailNotifications,
                  ),
                  _buildDeliveryToggle(
                    'SMS Notifications',
                    'Receive notifications via SMS',
                    Icons.sms,
                    controller.smsNotifications,
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Sound & Vibration
              _buildSectionCard(
                title: 'Sound & Vibration',
                children: [
                  _buildSoundToggle(
                    'Notification Sound',
                    'Play sound for notifications',
                    Icons.volume_up,
                    controller.notificationSound,
                  ),
                  _buildSoundToggle(
                    'Vibration',
                    'Vibrate for notifications',
                    Icons.vibration,
                    controller.vibration,
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Quiet Hours
              _buildSectionCard(
                title: 'Quiet Hours',
                children: [
                  _buildQuietHoursToggle(),
                  if (controller.quietHoursEnabled.value) ...[
                    SizedBox(height: 12),
                    _buildTimeSelector(
                      'Start Time',
                      controller.quietStartTime.value,
                      (time) => controller.quietStartTime.value = time,
                    ),
                    SizedBox(height: 8),
                    _buildTimeSelector(
                      'End Time',
                      controller.quietEndTime.value,
                      (time) => controller.quietEndTime.value = time,
                    ),
                  ],
                ],
              ),

              SizedBox(height: 16),

              // Summary Options
              _buildSectionCard(
                title: 'Summary Notifications',
                children: [
                  _buildSummaryToggle(
                    'Daily Summary',
                    'Get a daily summary of activities',
                    Icons.today,
                    controller.dailySummary,
                  ),
                  _buildSummaryToggle(
                    'Weekly Summary',
                    'Get a weekly summary of activities',
                    Icons.date_range,
                    controller.weeklySummary,
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Save Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.savePreferences();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Preferences',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: controller.isNotificationsEnabled.value
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              controller.isNotificationsEnabled.value
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: controller.isNotificationsEnabled.value
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Master switch for all notifications',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.isNotificationsEnabled.value,
            onChanged: (value) {
              controller.isNotificationsEnabled.value = value;
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeToggle(
    String title,
    String subtitle,
    IconData icon,
    RxBool value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value.value && controller.isNotificationsEnabled.value,
            onChanged: controller.isNotificationsEnabled.value
                ? (newValue) => value.value = newValue
                : null,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryToggle(
    String title,
    String subtitle,
    IconData icon,
    RxBool value,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value.value && controller.isNotificationsEnabled.value,
            onChanged: controller.isNotificationsEnabled.value
                ? (newValue) => value.value = newValue
                : null,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSoundToggle(
    String title,
    String subtitle,
    IconData icon,
    RxBool value,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value.value && controller.isNotificationsEnabled.value,
            onChanged: controller.isNotificationsEnabled.value
                ? (newValue) => value.value = newValue
                : null,
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursToggle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.nightlight_round, color: Colors.indigo),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Quiet Hours',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Silence notifications during specified hours',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value:
                controller.quietHoursEnabled.value &&
                controller.isNotificationsEnabled.value,
            onChanged: controller.isNotificationsEnabled.value
                ? (value) => controller.quietHoursEnabled.value = value
                : null,
            activeColor: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: Get.context!,
          initialTime: time,
        );
        if (picked != null) {
          onTimeChanged(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.grey[600]),
            SizedBox(width: 12),
            Text(
              '$label: ${time.format(Get.context!)}',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryToggle(
    String title,
    String subtitle,
    IconData icon,
    RxBool value,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.teal),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value.value && controller.isNotificationsEnabled.value,
            onChanged: controller.isNotificationsEnabled.value
                ? (newValue) => value.value = newValue
                : null,
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Reset Preferences'),
        content: Text(
          'Are you sure you want to reset all notification preferences to default values?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetToDefaults();
              Get.snackbar(
                'Reset Complete',
                'All notification preferences have been reset to defaults',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
