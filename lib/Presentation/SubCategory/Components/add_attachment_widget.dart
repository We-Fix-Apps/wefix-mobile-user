import 'dart:async'; // Import this for the Timer
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/upload_files_list.dart';
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
  List<Map<String, String?>> uploadedFiles = [];
  bool loading = false;

  // Timer variables
  Timer? _timer;
  int _seconds = 0;

  Future<void> _requestPermissionsOnce() async {
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
      });

      // noteController.clear();
    }
  }

  // Pick from camera
  Future<void> pickFromCamera() async {
    final status = await Permission.camera.request();

    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(AppText(context).takeAPictureFromCamera),
              onTap: () async {
                final picked =
                    await _imagePicker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() {
                    imagePath = picked.path;
                    uploadedFiles.add({
                      "file": null,
                      "audio": null,
                      "image": picked.path,
                    });
                    // noteController.clear();
                  });
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(AppText(context).recordVideo),
              onTap: () async {
                final picked =
                    await _imagePicker.pickVideo(source: ImageSource.camera);
                if (picked != null) {
                  setState(() {
                    imagePath = picked.path;
                    uploadedFiles.add({
                      "file": null,
                      "audio": null,
                      "image": picked.path,
                    });
                    noteController.clear();
                  });
                }
                // Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future uploadFile({List? files}) async {
    AppProvider appProvider = Provider.of(context, listen: false);
    setState(() {
      appProvider.saveDesc(noteController.text);
    });

    await UpladeFiles.upladeImagesWithPaths(
            token: '${appProvider.userModel?.token}', filePaths: extractedPaths)
        .then((value) {
      log(value.toString());
      if (value != null) {
        Navigator.push(context, rightToLeft(const AppoitmentDetailsScreen()))
            .then((value) {
          setState(() {
            loading = false;
          });
        });
        appProvider.desc.text.toString();
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
    final path =
        "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

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

        uploadedFiles.add({
          "file": null,
          "audio": path,
          "image": null,
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
      log(" uploadded fillle : ${uploadedFiles.toString()}");
      extractFilePaths(uploadedFiles);

      log("Extracted paths: $extractedPaths");
    }
  }

  List<Map<String, String?>> extractedFiles = [];
  List<String> extractedPaths = [];
  List<String> extractFilePaths(List<Map<String, String?>> uploadedFiles) {
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

    log(extractedPaths.toString());

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
      "description":
          AppText(navigatorKey.currentState!.context).youcanuploadfile,
      "image": "assets/image/file.png"
    },
    {
      "title":
          AppText(navigatorKey.currentState!.context).takeAPictureFromCamera,
      "description":
          AppText(navigatorKey.currentState!.context).youcantakepicture,
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
    Permission.camera.request();
    _requestPermissionsOnce();

    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomeTutorialCoachMark.createTutorial(keyButton, content);
        Future.delayed(const Duration(seconds: 1), () {
          Map showTour =
              json.decode(CacheHelper.getData(key: CacheHelper.showTour));
          CustomeTutorialCoachMark.showTutorial(context,
              isShow: showTour["addAttachment"] ?? true);
          setState(() {
            showTour["addAttachment"] = false;
          });
          CacheHelper.saveData(
              key: CacheHelper.showTour, value: json.encode(showTour));
          log(showTour.toString());
        });
      });
    } catch (e) {
      log(e.toString());
    }

    super.initState();
  }

  @override
  void dispose() {
    noteController.clear();
    _timer?.cancel();
    super.dispose();
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
                    : (audioPath != null
                        ? AppText(context).audioRecorded
                        : AppText(context).recordVoice),
                color: isRecording ? Colors.red : Colors.green,
                onTap: isRecording ? stopRecording : startRecording,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              key: keyButton[3],
              child: WidgetTextField(
                AppText(context).describeyourproblem,
                maxLines: 4,
                controller: noteController,
              ),
            ),
            const SizedBox(height: 20),
            uploadedFiles.isEmpty
                ? const SizedBox()
                : Text(AppText(context).attachments,
                    style: TextStyle(
                        fontSize: AppSize(context).smallText1,
                        fontWeight: FontWeight.bold)),
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
                    leading: file["file"]?.endsWith("mp4") ?? false
                        ? SvgPicture.asset("assets/icon/vid.svg", width: 40)
                        : file["audio"] != null
                            ? SvgPicture.asset("assets/icon/mp4.svg", width: 40)
                            : file["image"] != null
                                ? file["image"]?.endsWith("mp4") ?? false
                                    ? SvgPicture.asset("assets/icon/vid.svg",
                                        width: 40)
                                    : SvgPicture.asset("assets/icon/imge.svg",
                                        width: 40)
                                : ((file["image"]?.endsWith("png") ?? false) ||
                                        (file["image"]?.endsWith("jpg") ??
                                            false))
                                    ? SvgPicture.asset("assets/icon/imge.svg",
                                        width: 40)
                                    : ((file["file"]?.endsWith("png") ??
                                                false) ||
                                            (file["file"]?.endsWith("jpg") ??
                                                false))
                                        ? SvgPicture.asset(
                                            "assets/icon/imge.svg",
                                            width: 40)
                                        : SvgPicture.asset(
                                            "assets/icon/file.svg",
                                            width: 40),
                    title: Text(
                      file["filename"] ??
                          file["audio"]?.split('/').last ??
                          file["image"]?.split('/').last ??
                          "",
                      maxLines: 1,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                              file["audio"] != null
                                  ? Icons.play_arrow
                                  : Icons.remove_red_eye,
                              color: AppColors(context).primaryColor),
                          onPressed: () {
                            final file = uploadedFiles[index];
                            // ignore: prefer_if_null_operators
                            final path = file["file"] != null
                                ? file["file"]
                                : file["audio"] ?? file["image"];

                            if (path != null) {
                              if (file["file"] != null) {
                                OpenFile.open(path);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Preview'),
                                    content: file["image"] != null
                                        ? (file["image"]!.endsWith("mp4")
                                            ? VideoPlayerWidget(filePath: path)
                                            : Image.file(File(path)))
                                        : file["audio"] != null
                                            ? AudioPlayerWidget(filePath: path)
                                            : Text(AppText(context,
                                                    isFunction: true)
                                                .previewnotavailableforthisfiletype),
                                    actions: [
                                      TextButton(
                                        child: const Text('Close'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                        ),
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
    final result = await OpenFile.open(filePath);
    print("File open result: ${result.message}");
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
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16)
        ],
      ),
    ),
  );
}

// Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String filePath;
  const VideoPlayerWidget({Key? key, required this.filePath}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const CircularProgressIndicator();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
