import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import '../post_frame.dart';
import '../post_header.dart';

class TelegramPost extends StatelessWidget {
  final String postTitle;
  final String postTime;
  final int postViewsCount;
  final Widget postContent;
  final ImageProvider channelImage;
  final TextStyle postTitleTextStyle;
  final TextStyle postTimeTextStyle;

  final VoidCallback onHeaderTap;

  TelegramPost({
    @required this.postTitle,
    @required this.postTime,
    @required this.postContent,
    @required this.postViewsCount,
    this.channelImage,
    this.postTitleTextStyle,
    this.postTimeTextStyle,
    this.onHeaderTap,
  });

  @override
  Widget build(BuildContext context) => buildMain();

  Widget buildMain() => PostFrame(
        maxWidth: Get.mediaQuery.orientation == Orientation.portrait
            ? Get.width
            : Get.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            this._postFrameHeader,
            this.postContent,
            this
                ._postFrameFooter
                .paddingSymmetric(vertical: 5.0, horizontal: 10.0),
          ],
        ),
      );

  Widget get _postFrameHeader => GestureDetector(
        onDoubleTap: onHeaderTap,
        child: PostHeader(
          avatarImage: channelImage,
          postTitleString: postTitle,
          postTimeString: postTime,
          titleTextStyle: postTitleTextStyle,
          postTimeTextStyle: postTimeTextStyle,
        ),
      );

  Widget get _postFrameFooter => Row(
        children: [
          this._postViewsCount,
          Spacer(),
          this._postCommands,
        ],
      );

  Widget get _postViewsCount => Row(
        children: [
          Icon(
            Icons.visibility,
            size: 16,
            color: Colors.grey,
          ).paddingOnly(right: 5),
          Text(
            '$postViewsCount',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          )
        ],
      );

  Widget get _postCommands => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.share,
            size: 20,
            color: Colors.grey,
          ).paddingOnly(right: 10),
          Icon(
            Icons.bookmark_outline,
            size: 20,
            color: Colors.grey,
          )
        ],
      );
}
