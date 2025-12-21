import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Presentation/Profile/Components/web_view_screen.dart' show WebviewScreen;

class AttachmentsWidget extends StatelessWidget {
  final String? image;
  final String? url;

  const AttachmentsWidget({super.key, this.image, this.url});

  /// Build full URL from relative path
  String _buildFullUrl(String filePath) {
    if (filePath.isEmpty) return '';
    
    // If already a full URL, return as is
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }
    
    // Build full URL using MMS base URL
    // MMS base URL: https://wefix-backend-mms.ngrok.app/api/v1/
    // Remove /api/v1/ to get base URL
    String baseUrl = EndPoints.mmsBaseUrl.replaceAll('/api/v1/', '').replaceAll(RegExp(r'/$'), '');
    
    // If path already starts with /uploads, use it directly
    if (filePath.startsWith('/uploads')) {
      return '$baseUrl$filePath';
    }
    
    // If path starts with uploads (without leading slash), add it
    if (filePath.startsWith('uploads')) {
      return '$baseUrl/$filePath';
    }
    
    // If path contains 'app/uploads', extract just the filename and use /uploads
    if (filePath.contains('app/uploads') || filePath.contains('/uploads/')) {
      final filename = filePath.split('/').last;
      return '$baseUrl/uploads/$filename';
    }
    
    // Otherwise, assume it's a filename and add /uploads prefix
    final filename = filePath.split('/').last;
    return '$baseUrl/uploads/$filename';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: url!.endsWith("mp4")
              ? SvgPicture.asset("assets/icon/vid.svg", width: 40)
              : url!.endsWith("m4a")
                  ? SvgPicture.asset("assets/icon/mp4.svg", width: 40)
                  : url!.endsWith("pdf")
                      ? SvgPicture.asset("assets/icon/pdf.svg", width: 40)
                      : SvgPicture.asset("assets/icon/imge.svg", width: 40),
          title: Text("$image"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // View button
              IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: () {
                  _openAttachment(context, url ?? "");
                },
              ),
              // Share button (WhatsApp)
              IconButton(
                icon: const Icon(Icons.share),
            onPressed: () {
                  _shareViaWhatsApp(url ?? "");
            },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAttachment(BuildContext context, String fileUrl) async {
    if (fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid file URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Build full URL from relative path if needed
      final fullUrl = _buildFullUrl(fileUrl);
      
      // Check if URL is a web URL (http/https)
      if (fullUrl.startsWith('http://') || fullUrl.startsWith('https://')) {
        // Open in WebView for better viewing experience
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebviewScreen(url: fullUrl),
          ),
        );
      } else {
        // For local file paths or other schemes, try to launch with external app
        final uri = Uri.parse(fullUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open file: $fullUrl'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareViaWhatsApp(String fileUrl) async {
    try {
      // Build full URL from relative path if needed
      final fullUrl = _buildFullUrl(fileUrl);
      
      // Try to share via WhatsApp
      // If URL is a full URL, share it directly
      if (fullUrl.startsWith('http://') || fullUrl.startsWith('https://')) {
        // Share the URL via WhatsApp
        final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(fullUrl)}';
        final uri = Uri.parse(whatsappUrl);
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Fallback to general share using url_launcher
          await _shareUrl(fullUrl);
        }
      } else {
        // If it's a local file path, try to share URL
        await _shareUrl(fullUrl);
      }
    } catch (e) {
      // Fallback: try to share URL using url_launcher
      try {
        await _shareUrl(_buildFullUrl(fileUrl));
      } catch (e2) {
        // Last resort: show error message
        debugPrint('Error sharing file: $e2');
      }
    }
  }

  /// Share URL using url_launcher as fallback when share_plus is not available
  Future<void> _shareUrl(String url) async {
    try {
      // Try share_plus first
      await Share.share(url);
    } catch (e) {
      // If share_plus fails, try to open WhatsApp directly with URL
      try {
        final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(url)}';
        final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
          // Last fallback: open in browser
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      } catch (e2) {
        debugPrint('Error sharing URL: $e2');
      }
    }
  }
}
