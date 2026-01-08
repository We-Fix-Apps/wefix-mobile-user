import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefix/Data/services/version_check_service.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/l10n/app_localizations.dart';

class VersionCheckScreen extends StatelessWidget {
  const VersionCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon or Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.system_update,
                    size: 60,
                    color: AppColors(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  localizations.updateRequired,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  localizations.updateRequiredDescription,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _openStore(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      localizations.updateNow,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Later Button (optional - you can remove this if you want to force update)
                TextButton(
                  onPressed: () {
                    // Allow user to continue (optional)
                    // Remove this if you want to force update
                  },
                  child: Text(
                    localizations.later,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final storeUrl = VersionCheckService.getStoreUrl();
    if (storeUrl.isNotEmpty) {
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.couldNotOpenStore),
            ),
          );
        }
      }
    }
  }
}
