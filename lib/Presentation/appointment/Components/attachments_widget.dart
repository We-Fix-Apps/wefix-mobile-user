import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Business/end_points.dart';

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
    
    // If path already starts with /WeFixFiles, use it directly (correct path for ticket attachments)
    if (filePath.startsWith('/WeFixFiles')) {
      return '$baseUrl$filePath';
    }
    
    // If path starts with WeFixFiles (without leading slash), add it
    if (filePath.startsWith('WeFixFiles')) {
      return '$baseUrl/$filePath';
    }
    
    // Legacy support: If path already starts with /uploads, convert to WeFixFiles
    if (filePath.startsWith('/uploads')) {
      // Extract filename and assume it's in WeFixFiles/Contracts/ (legacy location)
      final filename = filePath.replaceFirst('/uploads/', '');
      return '$baseUrl/WeFixFiles/Contracts/$filename';
    }
    
    // Legacy support: If path starts with uploads (without leading slash)
    if (filePath.startsWith('uploads')) {
      final filename = filePath.replaceFirst('uploads/', '');
      return '$baseUrl/WeFixFiles/Contracts/$filename';
    }
    
    // Legacy support: If path contains 'app/uploads', extract just the filename
    if (filePath.contains('app/uploads') || filePath.contains('/uploads/')) {
      final filename = filePath.split('/').last;
      return '$baseUrl/WeFixFiles/Contracts/$filename';
    }
    
    // Otherwise, assume it's a filename and use WeFixFiles/Contracts/ (legacy location)
    final filename = filePath.split('/').last;
    return '$baseUrl/WeFixFiles/Contracts/$filename';
  }

  /// Helper function to determine if a file is a video
  bool _isVideoFile(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.mp4') ||
        lowerPath.endsWith('.mov') ||
        lowerPath.endsWith('.avi') ||
        lowerPath.endsWith('.mkv') ||
        lowerPath.endsWith('.m4v') ||
        lowerPath.endsWith('.webm');
  }

  /// Helper function to determine if a file is an image
  bool _isImageFile(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.bmp') ||
        lowerPath.endsWith('.webp');
  }

  /// Helper function to determine if a file is an audio file
  bool _isAudioFile(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.m4a') ||
        lowerPath.endsWith('.mp3') ||
        lowerPath.endsWith('.wav') ||
        lowerPath.endsWith('.aac') ||
        lowerPath.endsWith('.ogg');
  }

  /// Helper function to get the appropriate icon for a file
  Widget _getFileIcon(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) {
      return SvgPicture.asset("assets/icon/file.svg", width: 40);
    }
    
    // Check audio files first
    if (_isAudioFile(fileUrl)) {
      return SvgPicture.asset("assets/icon/mp4.svg", width: 40);
    }
    
    // Check video files
    if (_isVideoFile(fileUrl)) {
      return SvgPicture.asset("assets/icon/vid.svg", width: 40);
    }
    
    // Check PDF files
    if (fileUrl.toLowerCase().endsWith('.pdf')) {
      return SvgPicture.asset("assets/icon/pdf.svg", width: 40);
    }
    
    // Check image files
    if (_isImageFile(fileUrl)) {
      return SvgPicture.asset("assets/icon/imge.svg", width: 40);
    }
    
    // Default to file icon for other types
    return SvgPicture.asset("assets/icon/file.svg", width: 40);
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
          leading: _getFileIcon(url),
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
      
      // Check if it's a local file path (not starting with http/https)
      final isLocalFile = !fullUrl.startsWith('http://') && !fullUrl.startsWith('https://');
      
      if (isLocalFile) {
        // For local files, open directly with system default app
        final result = await OpenFile.open(fullUrl);
        if (result.type != ResultType.done) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open file: ${result.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // For remote URLs (http/https), download first then open with native apps
        await _downloadAndOpenFile(context, fullUrl);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadAndOpenFile(BuildContext context, String url) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
                ),
                SizedBox(width: 16),
                Text('Downloading file...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Download the file
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to download file: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get temporary directory
      final tempDir = Directory.systemTemp;
      
      // Extract file name from URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.isNotEmpty 
          ? pathSegments.last 
          : 'file_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create temporary file path
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      
      // Write downloaded bytes to file
      await file.writeAsBytes(response.bodyBytes);
      
      // Hide loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Open the downloaded file with native apps (gallery, PDF reader, video player, etc.)
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error downloading/opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
      }
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
