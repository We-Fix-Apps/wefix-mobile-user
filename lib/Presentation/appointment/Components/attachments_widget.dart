import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

class AttachmentsWidget extends StatelessWidget {
  final String? image;
  final String? url;

  const AttachmentsWidget({super.key, this.image, this.url});

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
                  : SvgPicture.asset("assets/icon/imge.svg", width: 40),
          title: Text("$image"),
          trailing: IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () {
              _launchInAppWithBrowserOptions(url ?? "https://www.google.com");
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchInAppWithBrowserOptions(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${url}';
    }
  }
}
