import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth/login_controller.dart';
import '../../model/auth/user_model.dart';

class SecuritySettingsScreen extends StatelessWidget {
  final UserModel? user;
  final Color roleColor;

  const SecuritySettingsScreen({
    Key? key,
    required this.user,
    required this.roleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: roleColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Security Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Your Security',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loginController.canUseBiometrics.value
                    ? 'Enhance your account security with these options.'
                    : 'Some features are not available on this device.',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Biometric Authentication
              Obx(
                () => _buildSecurityCard(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face recognition to log in',
                  color: roleColor,
                  isEnabled: loginController.canUseBiometrics.value,
                  trailing: Switch(
                    value: loginController.isBiometricEnabled.value,
                    onChanged: loginController.canUseBiometrics.value
                        ? (value) async {
                            if (value) {
                              _showBiometricConfirmationDialog(loginController);
                            } else {
                              // Disable biometrics
                              await loginController.disableBiometrics();
                              Get.snackbar(
                                'Success',
                                'Biometric authentication disabled.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                              );
                            }
                          }
                        : null,
                    activeColor: roleColor,
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                  ),
                  onTap: loginController.canUseBiometrics.value
                      ? () => _showBiometricConfirmationDialog(loginController)
                      : () => _showDisabledMessage(),
                ),
              ),

              // Screen Lock
              _buildSecurityCard(
                icon: Icons.lock,
                title: 'Screen Lock',
                subtitle: 'Enable PIN or pattern lock after inactivity',
                color: roleColor,
                isEnabled: false,
                trailing: Switch(
                  value: false,
                  onChanged: null,
                  activeColor: roleColor,
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                ),
                onTap: () => _showDisabledMessage(),
              ),

              // Change Password
              _buildSecurityCard(
                icon: Icons.key,
                title: 'Change Password',
                subtitle: 'Update your account password',
                color: roleColor,
                isEnabled: false,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDisabledMessage(),
              ),

              // Security Tips
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: roleColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem(
                      'Use a strong, unique password with a mix of letters, numbers, and symbols.',
                      roleColor,
                    ),
                    _buildTipItem(
                      'Enable biometric authentication for quick and secure access.',
                      roleColor,
                    ),
                    _buildTipItem(
                      'Log out of your account when using shared devices.',
                      roleColor,
                    ),
                    _buildTipItem(
                      'Regularly review your account activity for any suspicious behavior.',
                      roleColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isEnabled,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isEnabled ? onTap : () => _showDisabledMessage(),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: isEnabled ? color : Colors.grey),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isEnabled
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF94A3B8),
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isEnabled
                    ? const Color(0xFF64748B)
                    : const Color(0xFFB0BEC5),
              ),
            ),
            trailing: trailing,
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: color.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisabledMessage() {
    Get.snackbar(
      'Info',
      'This feature is currently disabled and will be available in a future update.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showBiometricConfirmationDialog(LoginController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Enable Biometric Authentication'),
        content: const Text(
          'Are you sure you want to enable biometric authentication?\n\nThis will allow you to log in using your fingerprint or face recognition.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              bool success = await controller.enableBiometrics();
              if (success) {
                // Store current user credentials after enabling biometrics
                if (controller.user.value != null) {
                  await controller.storeUserCredentials();
                }
              }
            },
            child: Text(
              'Enable',
              style: TextStyle(color: roleColor ?? Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
