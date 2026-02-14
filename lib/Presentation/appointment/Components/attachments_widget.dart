import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

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
      
      // Check if it's a video or audio file - show in-app player (same as edit ticket screen)
      if (_isVideoFile(fileUrl) || _isAudioFile(fileUrl)) {
        // For network URLs, use network player directly (no download needed)
        // For local files, use file player
        if (context.mounted) {
          if (_isVideoFile(fileUrl)) {
            _showVideoPlayer(context, fullUrl, !isLocalFile);
          } else {
            _showAudioPlayer(context, fullUrl, !isLocalFile);
          }
        }
        return;
      }
      
      // For other file types, use the original behavior
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
  
  // Show video player (same as edit ticket screen)
  void _showVideoPlayer(BuildContext context, String filePath, bool isUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Video Player', style: TextStyle(color: Colors.white)),
            ),
            Flexible(
              child: isUrl ? _VideoPlayerNetworkWidget(url: filePath) : _VideoPlayerFileWidget(filePath: filePath),
            ),
          ],
        ),
      ),
    );
  }

  // Show audio player (same as edit ticket screen)
  void _showAudioPlayer(BuildContext context, String filePath, bool isUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Audio Player', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isUrl ? _AudioPlayerNetworkWidget(url: filePath) : _AudioPlayerFileWidget(filePath: filePath),
            ],
          ),
        ),
      ),
    );
  }
}

// Video Player Widget for local files (same as edit ticket screen)
class _VideoPlayerFileWidget extends StatefulWidget {
  final String filePath;
  const _VideoPlayerFileWidget({required this.filePath});

  @override
  State<_VideoPlayerFileWidget> createState() => _VideoPlayerFileWidgetState();
}

class _VideoPlayerFileWidgetState extends State<_VideoPlayerFileWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;
    
    _controller = VideoPlayerController.file(File(widget.filePath));
    
    try {
      await _controller!.initialize();
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (error) {
      if (mounted && !_isDisposed) {
        debugPrint('VideoPlayer initialization error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null || _isDisposed) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              if (_isDisposed || _controller == null) return;
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    final controller = _controller;
    _controller = null;
    
    if (controller != null) {
      Future.microtask(() async {
        try {
          await Future.delayed(const Duration(milliseconds: 50));
          
          if (controller.value.isInitialized) {
            await controller.pause();
          }
          
          controller.dispose();
        } catch (e) {
          // Silently catch disposal errors
        }
      });
    }
    
    super.dispose();
  }
}

// Video Player Widget for network URLs (same as edit ticket screen)
class _VideoPlayerNetworkWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerNetworkWidget({required this.url});

  @override
  State<_VideoPlayerNetworkWidget> createState() => _VideoPlayerNetworkWidgetState();
}

class _VideoPlayerNetworkWidgetState extends State<_VideoPlayerNetworkWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    
    try {
      await _controller!.initialize();
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (error) {
      if (mounted && !_isDisposed) {
        debugPrint('VideoPlayer initialization error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null || _isDisposed) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              if (_isDisposed || _controller == null) return;
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    final controller = _controller;
    _controller = null;
    
    if (controller != null) {
      Future.microtask(() async {
        try {
          await Future.delayed(const Duration(milliseconds: 50));
          
          if (controller.value.isInitialized) {
            await controller.pause();
          }
          
          controller.dispose();
        } catch (e) {
          // Silently catch disposal errors
        }
      });
    }
    
    super.dispose();
  }
}

// Audio Player Widget for local files (same as edit ticket screen)
class _AudioPlayerFileWidget extends StatefulWidget {
  final String filePath;
  const _AudioPlayerFileWidget({required this.filePath});

  @override
  State<_AudioPlayerFileWidget> createState() => _AudioPlayerFileWidgetState();
}

class _AudioPlayerFileWidgetState extends State<_AudioPlayerFileWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 50),
          onPressed: () async {
            if (_isPlaying) {
              await _audioPlayer.pause();
            } else {
              await _audioPlayer.play(DeviceFileSource(widget.filePath));
            }
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Audio Player Widget for network URLs (same as edit ticket screen)
class _AudioPlayerNetworkWidget extends StatefulWidget {
  final String url;
  const _AudioPlayerNetworkWidget({required this.url});

  @override
  State<_AudioPlayerNetworkWidget> createState() => _AudioPlayerNetworkWidgetState();
}

class _AudioPlayerNetworkWidgetState extends State<_AudioPlayerNetworkWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 50),
          onPressed: () async {
            if (_isPlaying) {
              await _audioPlayer.pause();
            } else {
              await _audioPlayer.play(UrlSource(widget.url));
            }
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
