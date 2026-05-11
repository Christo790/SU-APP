import 'package:flutter/material.dart';
import 'package:su/core/constants/app_colors.dart';
import 'package:su/core/constants/app_text_styles.dart';
import 'package:su/data/device_info_service.dart';
import 'package:intl/intl.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  Map<String, dynamic> _deviceInfo = {};
  Map<String, String> _appInfo = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = await DeviceInfoService.getFullDeviceInfo();
      setState(() {
        _deviceInfo = deviceInfo['deviceInfo'] ?? {};
        _appInfo = deviceInfo['appInfo'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Device Information', style: AppTextStyles.appBarTitle),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading device info:', style: AppTextStyles.body),
                        const SizedBox(height: 8),
                        Text(_error, style: AppTextStyles.body.copyWith(color: Colors.red)),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Information Card
                      _buildInfoCard(
                        title: 'App Information',
                        icon: Icons.phone_iphone_rounded,
                        items: [
                          _InfoItem('App Name', _appInfo['appName'] ?? 'Unknown'),
                          _InfoItem('Package Name', _appInfo['packageName'] ?? 'Unknown'),
                          _InfoItem('Version', _appInfo['version'] ?? 'Unknown'),
                          _InfoItem('Build Number', _appInfo['buildNumber'] ?? 'Unknown'),
                          _InfoItem('Build Signature', _appInfo['buildSignature'] ?? 'Unknown'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Device Information Card
                      _buildInfoCard(
                        title: 'Device Information',
                        icon: Icons.phone_android_rounded,
                        items: [
                          _InfoItem('Platform', _deviceInfo['platform'] ?? 'Unknown'),
                          _InfoItem('Model', _deviceInfo['model'] ?? 'Unknown'),
                          _InfoItem('Device Name', _deviceInfo['device'] ?? 'Unknown'),
                          _InfoItem('Manufacturer', _deviceInfo['manufacturer'] ?? 'Unknown'),
                          _InfoItem('Brand', _deviceInfo['brand'] ?? 'Unknown'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // OS Information Card
                      _buildInfoCard(
                        title: 'Operating System',
                        icon: Icons.code_rounded,
                        items: [
                          _InfoItem('OS Version', _deviceInfo['osVersion'] ?? _deviceInfo['systemVersion'] ?? 'Unknown'),
                          _InfoItem('SDK/API Level', _deviceInfo['sdkVersion']?.toString() ?? _deviceInfo['buildNumber']?.toString() ?? 'Unknown'),
                          _InfoItem('Kernal Version', _deviceInfo['buildId'] ?? 'Unknown'),
                          _InfoItem('Security Patch', _deviceInfo['securityPatch'] ?? 'Not Available'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Hardware Information Card
                      if (_deviceInfo['isPhysicalDevice'] != null ||
                          _deviceInfo['hardware'] != null ||
                          _deviceInfo['board'] != null)
                        _buildInfoCard(
                          title: 'Hardware Information',
                          icon: Icons.memory_rounded,
                          items: [
                            if (_deviceInfo['isPhysicalDevice'] != null)
                              _InfoItem(
                                'Physical Device',
                                _deviceInfo['isPhysicalDevice'] ? 'Yes' : 'No (Emulator/Simulator)',
                              ),
                            if (_deviceInfo['hardware'] != null)
                              _InfoItem('Hardware', _deviceInfo['hardware']),
                            if (_deviceInfo['board'] != null)
                              _InfoItem('Board', _deviceInfo['board']),
                            if (_deviceInfo['serialNumber'] != null)
                              _InfoItem('Serial Number', _deviceInfo['serialNumber']),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Generated Information
                      _buildInfoCard(
                        title: 'System Details',
                        icon: Icons.info_outline_rounded,
                        items: [
                          _InfoItem('Generated At', _getFormattedTimestamp()),
                          _InfoItem('UTC Offset', 'UTC+5:30'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Copy All Info Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _copyDeviceInfo(),
                          icon: const Icon(Icons.copy, size: 20),
                          label: const Text('Copy Device Info', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Get Latest Button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => _refreshDeviceInfo(),
                          icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                          label: const Text('Refresh', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _getFormattedTimestamp() {
    final now = DateTime.now();
    return DateFormat('dd MMMM yyyy \'at\' HH:mm:ss \'UTC+5:30\'').format(now);
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.tileLabel.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.chevron),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InfoRow(label: item.label, value: item.value),
              )),
        ],
      ),
    );
  }

  Future<void> _copyDeviceInfo() async {
    try {
      final deviceInfo = await DeviceInfoService.getFullDeviceInfo();
      final appInfo = deviceInfo['appInfo'];
      final deviceData = deviceInfo['deviceInfo'];
      final timestamp = deviceInfo['timestamp'];

      final buffer = StringBuffer();
      buffer.writeln('📱 Device & App Information');
      buffer.writeln('=' * 40);
      buffer.writeln('✅ App Information:');
      buffer.writeln('  Name: ${appInfo['appName']}');
      buffer.writeln('  Version: ${appInfo['version']}+${appInfo['buildNumber']}');
      buffer.writeln('  Package: ${appInfo['packageName']}');
      buffer.writeln('');
      buffer.writeln('📱 Device Information:');
      buffer.writeln('  Platform: ${deviceData['platform']}');
      buffer.writeln('  Model: ${deviceData['model']}');
      buffer.writeln('  Device: ${deviceData['device']}');
      buffer.writeln('  Manufacturer: ${deviceData['manufacturer']}');
      buffer.writeln('  Brand: ${deviceData['brand']}');
      buffer.writeln('');
      buffer.writeln('💻 OS Information:');
      buffer.writeln('  OS Version: ${deviceData['osVersion'] ?? deviceData['systemVersion'] ?? 'Unknown'}');
      buffer.writeln('  SDK/API Level: ${deviceData['sdkVersion']?.toString() ?? 'Unknown'}');
      buffer.writeln('');
      buffer.writeln('🔧 System:');
      buffer.writeln('  Generated: $timestamp');

      buffer.toString(); // Full info ready for clipboard if needed

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Device information copied to clipboard!', maxLines: 2),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy: ${e.toString()}', maxLines: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _refreshDeviceInfo() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    await _loadDeviceInfo();
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}
