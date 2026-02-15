import 'dart:async'; // Import this for the Timer
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/upload_files_list.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/tour_widget.dart';
import 'package:wefix/Presentation/appointment/Screens/appointment_details_screen.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:wefix/main.dart';

import '../../../Data/Helper/cache_helper.dart';

final TextEditingController noteController = TextEditingController();

class UploadOptionsScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  const UploadOptionsScreen({super.key, this.data});

  @override
  State<UploadOptionsScreen> createState() => _UploadOptionsScreenState();
}

class _UploadOptionsScreenState extends State<UploadOptionsScreen> {
  PlatformFile? selectedFile;
  bool isRecording = false;
  final record = Record();
  String? audioPath;
  String? imagePath;
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> uploadedFiles = [];
  bool loading = false;

  // Timer variables
  Timer? _timer;
  int _seconds = 0;

  // Permissions are now requested on app launch, so this is just a safety check
  Future<void> _requestPermissionsOnce() async {
    // Check and request if needed (should already be granted from app launch)
    await [
      Permission.microphone,
      Permission.storage,
      Permission.camera,
    ].request();
  }

  // Pick file
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() => selectedFile = result.files.first);

      uploadedFiles.add({
        "file": result.files.first.path,
        "filename": result.files.first.name,
        "audio": null,
        "image": null,
        "isNew": true, // Mark as new file
      });

      // noteController.clear();
    }
  }

  // Pick from camera - acts like SquaredImageUploader with support for both photo and video
  Future<void> pickFromCamera() async {
    if (!mounted) return;

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    var isArabic = languageProvider.lang == 'ar';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(AppText(context).takeAPictureFromCamera),
                onTap: () async {
                  Navigator.pop(context);
                  if (!mounted) return;

                  // For iOS, add small delay to ensure modal is fully closed
                  if (Platform.isIOS) {
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (!mounted) return;
                  }

                  // Capture images like SquaredImageUploader
                  await _captureImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: Text(AppText(context).recordVideo),
                onTap: () async {
                  Navigator.pop(context);
                  if (!mounted) return;

                  // For iOS, add small delay to ensure modal is fully closed
                  if (Platform.isIOS) {
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (!mounted) return;
                  }

                  // Capture video
                  await _captureVideoFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Capture image from camera - single photo capture (no continuous loop)
  Future<void> _captureImageFromCamera() async {
    // For iOS, add small delay to ensure any modal is fully closed
    if (Platform.isIOS) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
    }

    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final File imageFile = File(image.path);

      // Compress image like SquaredImageUploader
      final compressedData = await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 70,
      );

      File tempFile;
      if (compressedData != null) {
        final tempDir = await getTemporaryDirectory();
        tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_temp_img.jpg');
        await tempFile.writeAsBytes(compressedData);
      } else {
        tempFile = imageFile; // Use the original if compression is null
      }

      if (mounted) {
        setState(() {
          imagePath = tempFile.path;
          final fileName = tempFile.path.split('/').last;
          uploadedFiles.add({
            "file": null,
            "audio": null,
            "image": tempFile.path,
            "filename": fileName,
            "isNew": true, // Mark as new file
          });
        });
      }
    }
  }

  // Capture video from camera
  Future<void> _captureVideoFromCamera() async {
    if (!mounted) return;

    // For iOS, add small delay to ensure any modal is fully closed
    if (Platform.isIOS) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
    }

    final XFile? video = await _imagePicker.pickVideo(source: ImageSource.camera);
    if (video != null && mounted) {
      setState(() {
        imagePath = video.path;
        final fileName = video.path.split('/').last;
        uploadedFiles.add({
          "file": null,
          "audio": null,
          "image": video.path,
          "filename": fileName,
          "isNew": true, // Mark as new file
        });
      });
    }
  }

  Future uploadFile({List? files}) async {
    AppProvider appProvider = Provider.of(context, listen: false);
    setState(() {
      appProvider.saveDesc(noteController.text);
    });

    // Check if this is being used from ticket creation (has 'fromTicketCreation' flag)
    final isFromTicketCreation = widget.data?['fromTicketCreation'] == true;
    
    if (isFromTicketCreation) {
      // For ticket creation, just return the uploaded files without navigating
      setState(() {
        loading = false;
      });
      Navigator.pop(context, {
        'uploadedFiles': uploadedFiles,
        'note': noteController.text,
      });
      return;
    }

    // Original flow for appointment creation
    await UpladeFiles.upladeImagesWithPaths(
            token: '${appProvider.userModel?.token}', filePaths: extractedPaths)
        .then((value) {
      if (value != null) {
        Navigator.push(context, rightToLeft(const AppoitmentDetailsScreen()))
            .then((value) {
          setState(() {
            loading = false;
          });
        });
        setState(() {
          appProvider.clearAttachments();
          appProvider.saveAttachments(value);
        });
      } else {
        appProvider.clearAttachments();
        Navigator.push(context, rightToLeft(const AppoitmentDetailsScreen()))
            .then((value) {
          setState(() {
            appProvider.clearAttachments();
            loading = false;
          });
        });
      }
    });
  }

  Future<void> startRecording() async {
    final micStatus = await Permission.microphone.status;
    final storageStatus = await Permission.storage.status;

    if (!micStatus.isGranted || !storageStatus.isGranted) {
      await _requestPermissionsOnce();
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

    await record.start(path: path);
    setState(() {
      isRecording = true;
      audioPath = path;
      _seconds = 0; // Reset the timer
    });

    // Start the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  Future<void> stopRecording() async {
    final path = await record.stop();
    if (path != null) {
      setState(() {
        isRecording = false;
        audioPath = path;
        final fileName = path.split('/').last;
        uploadedFiles.add({
          "file": null,
          "audio": path,
          "image": null,
          "filename": fileName,
          "isNew": true, // Mark as new file
        });
      });

      // Stop the timer
      _timer?.cancel();
    }
  }

  Future handleSubmit() async {
    setState(() {
      loading = true;
    });
    if (selectedFile != null ||
        audioPath != null ||
        imagePath != null ||
        noteController.text.isNotEmpty) {
      setState(() {
        selectedFile = null;
        audioPath = null;
        imagePath = null;
        // noteController.clear();
      });

      // uploadedFiles.add({
      //   "file": selectedFile?.path,
      //   "audio": audioPath,
      //   "image": imagePath,
      // });
      extractFilePaths(uploadedFiles);
    }
  }

  List<Map<String, String?>> extractedFiles = [];
  List<String> extractedPaths = [];
  List<String> extractFilePaths(List<Map<String, dynamic>> uploadedFiles) {
    // Loop through the uploadedFiles list and add valid paths

    extractedPaths.clear();
    for (var file in uploadedFiles) {
      if (file["image"] != null && file["image"]!.isNotEmpty) {
        extractedPaths.add(file["image"]!); // Add image path if it exists
      }
      if (file["file"] != null && file["file"]!.isNotEmpty) {
        extractedPaths.add(file["file"]!); // Add video file path if it exists
      }
      if (file["audio"] != null && file["audio"]!.isNotEmpty) {
        extractedPaths.add(file["audio"]!); // Add audio path if it exists
      }
    }

    return extractedPaths;
  }

  final List<GlobalKey<State<StatefulWidget>>> keyButton = [
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
  ];

  List<Map> content = [
    {
      "title": AppText(navigatorKey.currentState!.context).uploadFilefromDevice,
      "description": AppText(navigatorKey.currentState!.context).youcanuploadfile,
      "image": "assets/image/file.png"
    },
    {
      "title": AppText(navigatorKey.currentState!.context).takeAPictureFromCamera,
      "description": AppText(navigatorKey.currentState!.context).youcantakepicture,
      "image": "assets/image/camera.png",
    },
    {
      "title": AppText(navigatorKey.currentState!.context).recordVoice,
      "description": AppText(navigatorKey.currentState!.context).youcanrecord,
      "image": "assets/image/mic.png",
    },
    {
      "title": AppText(navigatorKey.currentState!.context).describeyourproblem,
      "description": AppText(navigatorKey.currentState!.context).youcandescripe,
      "image": "assets/image/search.png",
    },
    {
      "title": AppText(navigatorKey.currentState!.context).continuesss,
      "description": AppText(navigatorKey.currentState!.context).afteraddingAll,
      "image": "assets/image/cont.png",
      "isTop": true
    },
  ];
  @override
  void initState() {
    // Initialize uploadedFiles from data if provided (for ticket creation)
    if (widget.data != null && widget.data!['uploadedFiles'] != null) {
      // Mark existing files from ticket as not new
      uploadedFiles = (widget.data!['uploadedFiles'] as List).map((file) {
        final fileMap = Map<String, dynamic>.from(file as Map);
        fileMap["isNew"] = false; // Mark existing files from ticket as not new
        return fileMap;
      }).toList();
    }

    _requestPermissionsOnce();
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomeTutorialCoachMark.createTutorial(keyButton, content);
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          try {
            final tourData = CacheHelper.getData(key: CacheHelper.showTour);
            Map showTour;
            if (tourData == null || tourData is! String) {
              showTour = {};
            } else {
              showTour = json.decode(tourData);
            }
            if (mounted) {
              CustomeTutorialCoachMark.showTutorial(context, isShow: showTour["addAttachment"] ?? true);
              setState(() {
                showTour["addAttachment"] = false;
              });
              CacheHelper.saveData(key: CacheHelper.showTour, value: json.encode(showTour));
            }
          } catch (e) {}
        });
      });
    } catch (e) {}

    super.initState();
  }

  @override
  void dispose() {
    noteController.clear();
    _timer?.cancel();
    super.dispose();
  }

  // Helper function to determine if a file is an audio file
  bool _isAudioFile(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.m4a') ||
        lowerPath.endsWith('.mp3') ||
        lowerPath.endsWith('.wav') ||
        lowerPath.endsWith('.aac') ||
        lowerPath.endsWith('.ogg');
  }
  
  // Helper function to determine if a file is a video
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

  // Helper function to determine if a file is an image
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

  // Helper function to build preview content based on file type
  Widget _buildPreviewContent(Map<String, dynamic> file, String path) {
    final isUrl = path.startsWith('http://') || path.startsWith('https://');
    
    // Check if it's a video file (regardless of which field it's stored in)
    // Note: Video files are now handled by _showVideoPlayer method
    if (_isVideoFile(path)) {
      return const Center(child: Text('Video preview'));
    }
    
    // Check if it's an audio file (regardless of which field it's stored in)
    if (_isAudioFile(path) || file["audio"] != null) {
      return AudioPlayerWidget(filePath: path);
    }
    
    // Check if it's an image
    if (file["image"] != null || _isImageFile(path)) {
      if (isUrl) {
        return CachedNetworkImage(
          imageUrl: path,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.contain,
        );
      } else {
        return Image.file(File(path));
      }
    }
    
    // Fallback for other file types
    return Text(AppText(context, isFunction: true).previewnotavailableforthisfiletype);
  }
  
  /// Open file preview - downloads remote files before showing player (same as working implementation)
  Future<void> _openFilePreview(BuildContext context, Map<String, dynamic> file, String path) async {
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid file path'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Check if it's a local file path (not starting with http/https)
      final isLocalFile = !path.startsWith('http://') && !path.startsWith('https://');
      
      // Check if it's a video or audio file - show in-app player (same as edit ticket screen)
      if (_isVideoFile(path)) {
        // Use the same video player as edit ticket screen
        _showVideoPlayer(path, !isLocalFile);
        return;
      }
      
      if (_isAudioFile(path) || file["audio"] != null) {
        // Use the same audio player as edit ticket screen
        _showAudioPlayer(path, !isLocalFile);
        return;
      }
      
      // For images, show in preview dialog
      if (_isImageFile(path) || file["image"] != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppText(context, isFunction: true).preview),
            content: SizedBox(
              width: double.maxFinite,
              child: _buildPreviewContent(file, path),
            ),
            actions: [
              TextButton(
                child: Text(AppText(context, isFunction: true).close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
      
      // For other file types, open with system default app
      if (isLocalFile) {
        final result = await OpenFile.open(path);
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // For remote URLs, download first then open
        await _downloadAndOpenFile(context, path);
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
  
  // Show video player (same as edit ticket screen)
  void _showVideoPlayer(String filePath, bool isUrl) {
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
  void _showAudioPlayer(String filePath, bool isUrl) {
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
  
  /// Download and open file with system default app
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

      // Open the downloaded file with native apps
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
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

  // Helper function to get filename from file map
  String _getFileName(Map<String, dynamic> file, int index) {
    // Try filename field first
    if (file["filename"] != null && file["filename"]!.isNotEmpty) {
      return file["filename"]!;
    }
    
    // Try to extract from paths
    final filePath = file["file"] ?? file["image"] ?? file["audio"];
    if (filePath != null && filePath.isNotEmpty) {
      final parts = filePath.split('/');
      if (parts.isNotEmpty) {
        final fileName = parts.last;
        if (fileName.isNotEmpty) {
          return fileName;
        }
      }
    }
    
    // Fallback to generic name based on type
    if (file["audio"] != null) {
      return "${AppText(context, isFunction: true).audio} ${index + 1}";
    } else if (file["image"] != null) {
      final path = file["image"]!.toLowerCase();
      if (path.contains('.mp4') || path.contains('.mov') || path.contains('.avi')) {
        return "${AppText(context, isFunction: true).video} ${index + 1}";
      }
      return "${AppText(context, isFunction: true).image} ${index + 1}";
    } else if (file["file"] != null) {
      return "${AppText(context, isFunction: true).file} ${index + 1}";
    }
    
    return "${AppText(context, isFunction: true).file} ${index + 1}";
  }

  // Helper function to get the appropriate icon for a file
  Widget _getFileIcon(Map<String, dynamic> file) {
    // Check audio files first
    if (file["audio"] != null) {
      return SvgPicture.asset("assets/icon/mp4.svg", width: 40);
    }

    // Check video files
    final filePath = file["file"] ?? file["image"];
    if (_isVideoFile(filePath)) {
      return SvgPicture.asset("assets/icon/vid.svg", width: 40);
    }

    // Check image files
    if (_isImageFile(filePath)) {
      return SvgPicture.asset("assets/icon/imge.svg", width: 40);
    }

    // Default to file icon for other types
    return SvgPicture.asset("assets/icon/file.svg", width: 40);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          key: keyButton[4],
          child: CustomBotton(
              title: AppText(context).continuesss,
              loading: loading,
              onTap: () async {
                await handleSubmit().then((value) {
                  uploadFile(files: extractedPaths);
                });
              }),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppText(context).addAttachment),
        actions: const [
          LanguageButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              key: keyButton[0],
              child: _optionTile(
                icon: Icons.attach_file,
                label: AppText(context).uploadFilefromDevice,
                color: Colors.blue,
                onTap: pickFile,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              key: keyButton[1],
              child: _optionTile(
                icon: Icons.camera_alt,
                label: AppText(context).takeAPictureFromCamera,
                color: Colors.orange,
                onTap: () {
                  pickFromCamera().then((value) {});
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              key: keyButton[2],
              child: _optionTile(
                icon: isRecording ? Icons.stop : Icons.mic,
                label: isRecording
                    ? "${AppText(context).stopRecording} (${AppText(context).time}: ${_seconds}s)"
                    : (audioPath != null ? AppText(context).audioRecorded : AppText(context).recordVoice),
                color: isRecording ? Colors.red : Colors.green,
                onTap: isRecording ? stopRecording : startRecording,
              ),
            ),
            const SizedBox(height: 20),
            // Hide "describe your problem" field for company users (roleId: 18, 20, 26)
            Builder(
              builder: (context) {
                final appProvider = Provider.of<AppProvider>(context, listen: false);
                final roleId = appProvider.userModel?.customer.roleId;
                int? roleIdInt;

                if (roleId != null) {
                  if (roleId is int) {
                    roleIdInt = roleId;
                  } else if (roleId is String) {
                    roleIdInt = int.tryParse(roleId);
                  } else {
                    roleIdInt = int.tryParse(roleId.toString());
                  }
                }

                // Company roles: 18 (Company Admin), 20 (Team Leader), 26 (Super User)
                final isCompany = roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 26;

                if (isCompany) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    Container(
                      key: keyButton[3],
                      child: WidgetTextField(
                        AppText(context).describeyourproblem,
                        maxLines: 4,
                        controller: noteController,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
            uploadedFiles.isEmpty ? const SizedBox() : Text(AppText(context).attachments, style: TextStyle(fontSize: AppSize(context).smallText1, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uploadedFiles.length,
              itemBuilder: (context, index) {
                final file = uploadedFiles[index];
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.greyColor1),
                    ),
                    leading: InkWell(
                      onTap: () async {
                        final file = uploadedFiles[index];
                        // Get the file path from any possible field
                        final path = file["file"] ?? file["audio"] ?? file["image"];

                        if (path != null && path.isNotEmpty) {
                          await _openFilePreview(context, file, path);
                        }
                      },
                      child: _getFileIcon(file),
                    ),
                    title: InkWell(
                      onTap: () async {
                        final file = uploadedFiles[index];
                        // Get the file path from any possible field
                        final path = file["file"] ?? file["audio"] ?? file["image"];

                        if (path != null && path.isNotEmpty) {
                          await _openFilePreview(context, file, path);
                        }
                      },
                      child: Text(
                        _getFileName(file, index),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(file["audio"] != null ? Icons.play_arrow : Icons.remove_red_eye, color: AppColors(context).primaryColor),
                          onPressed: () async {
                            final file = uploadedFiles[index];
                            // Get the file path from any possible field
                            final path = file["file"] ?? file["audio"] ?? file["image"];

                            if (path != null && path.isNotEmpty) {
                              await _openFilePreview(context, file, path);
                            }
                          },
                        ),
                        // Only show delete button for new files
                        if (file["isNew"] == true)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                uploadedFiles.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void openMyFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}

Widget _optionTile({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16)
        ],
      ),
    ),
  );
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

    // Store reference and clear immediately
    final controller = _controller;
    _controller = null;

    // Dispose asynchronously to avoid blocking
    if (controller != null) {
      Future.microtask(() async {
        try {
          // Wait a bit for any pending operations
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

class AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  const AudioPlayerWidget({Key? key, required this.filePath}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () async {
            if (isPlaying) {
              await _audioPlayer.pause();
            } else {
              // Use the AudioSource type instead of a plain string for the file path
              await _audioPlayer.play(DeviceFileSource(widget.filePath));
            }
            setState(() {
              isPlaying = !isPlaying;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
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
    
    // Store reference and clear immediately
    final controller = _controller;
    _controller = null;
    
    // Dispose asynchronously to avoid blocking
    if (controller != null) {
      Future.microtask(() async {
        try {
          // Wait a bit for any pending operations
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
