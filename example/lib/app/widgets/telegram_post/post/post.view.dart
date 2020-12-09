import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/helpers.dart';
import '../post_frame.dart';
import '../post_header.dart';
import 'post.controller.dart';

class TelegramPost extends MvcWidget<TelegramPostController> {
  final String postTitle;
  final String postTime;
  final String postText;
  final ImageProvider channelImage;
  final int minLines;
  final TextStyle postTitleTextStyle;
  final TextStyle postTimeTextStyle;
  final TextStyle postTextStyle;
  final VoidCallback onHeaderTap;

  // * Constants / defaults definition
  static const int maxLines = 10000;
  static const double postTextHorizontalPadding = 20.0;

  final TextStyle _defaultPostTextStyle = TextStyle(
    fontSize: 14,
    color: Color(0xff666666),
  );

  TelegramPost({
    @required this.postTitle,
    @required this.postTime,
    @required this.postText,
    this.channelImage,
    this.minLines = 4,
    this.postTitleTextStyle,
    this.postTimeTextStyle,
    this.postTextStyle,
    this.onHeaderTap,
  });

  @override
  TelegramPostController initController() => TelegramPostController();

  @override
  Widget buildMain() => PostFrame(
        maxWidth: c.postMaxWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            this._postFrameHeader,
            this._postText,
            Stack(
              alignment: Alignment.topCenter,
              children: [
                _postMediaContent,
                Transform.translate(
                  offset: Offset(0, -10),
                  child: this._postCollapseSection,
                ),
              ],
            ),
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

// TODO : Implement Post media content handling
  Widget get _postMediaContent => Placeholder(
        color: Colors.yellow,
      );

  Widget get _postText => Text(
        postText,
        maxLines: c.postTextCollapsed ? minLines : maxLines,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: postTextStyle ?? _defaultPostTextStyle,
      )
          .paddingOnly(bottom: 15.0)
          .paddingSymmetric(horizontal: postTextHorizontalPadding);

  Widget get _postCollapseSection => LayoutBuilder(
        builder: (context, constraints) {
          int numberOfLines = postText.numberOfTextLinesToDisplay(
            style: postTextStyle ?? _defaultPostTextStyle,
            maxWidth: constraints.maxWidth - postTextHorizontalPadding * 2,
            textAlign: TextAlign.justify,
          );
          return numberOfLines > minLines ? _postCollapseButton : Container();
        },
      );

  Widget get _postCollapseButton => GestureDetector(
        onTap: c.togglePostText,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                endIndent: 5.0,
                thickness: 1,
                color: Colors.grey[400],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[300],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(c.postTextCollapsed ? 'more' : 'less'),
                  Icon(
                    c.postTextCollapsed
                        ? Icons.arrow_drop_down
                        : Icons.arrow_drop_up,
                    size: 15,
                  ),
                ],
              ).paddingSymmetric(horizontal: 10, vertical: 2),
            ),
          ],
        ).paddingSymmetric(horizontal: 10),
      );
}
