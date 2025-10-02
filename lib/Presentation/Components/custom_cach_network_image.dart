import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class WidgetCachNetworkImage extends StatefulWidget {
  final String image;
  final BoxFit? boxFit;
  final double? height;
  final double? redios;
  final double? width;

  const WidgetCachNetworkImage({
    Key? key,
    required this.image,
    this.boxFit,
    this.height,
    this.width,
    this.redios,
  }) : super(key: key);

  @override
  State<WidgetCachNetworkImage> createState() => _WidgetCachNetworkImageState();
}

class _WidgetCachNetworkImageState extends State<WidgetCachNetworkImage> {
  bool _canShow = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkImageSize(widget.image.replaceAll(' ', ''));
  }

  Future<void> _checkImageSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentLength = response.headers['content-length'];
        if (contentLength != null) {
          final sizeInBytes = int.tryParse(contentLength) ?? 0;
          final sizeInKb = sizeInBytes / 1024;
          if (sizeInKb <= 200) {
            _canShow = true;
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking image size: $e");
    } finally {
      if (mounted) {
        setState(() => _checked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!_canShow) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: AppColors.lightGreyColor,
        child: Center(
            child: Text(
          "Image Too large > 200KB",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSize(context).smallText5),
        )),
      );
    }

    return CachedNetworkImage(
      height: widget.height,
      width: widget.width,
      imageUrl: widget.image.replaceAll(' ', ''),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: widget.boxFit ?? BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(widget.redios ?? 0),
        ),
      ),
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors(context).primaryColor),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.lightGreyColor,
      ),
    );
  }
}
