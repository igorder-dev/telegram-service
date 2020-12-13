import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/helpers.dart';

import 'collapsable_content.controller.dart';

class CollapsablePostContent
    extends MvcWidget<CollapsablePostContentController> {
  final String postText;
  final int minLines;
  final Widget mediaContent;
  final TextStyle postTextStyle;

  // * Constants / defaults definition
  static const int maxLines = 10000;
  static const double postTextHorizontalPadding = 20.0;

  final TextStyle _defaultPostTextStyle = TextStyle(
    fontSize: 14,
    color: Color(0xff666666),
  );

  CollapsablePostContent({
    Key key,
    @required this.postText,
    this.minLines = 4,
    this.mediaContent,
    this.postTextStyle,
  })  : assert(postText != null),
        super(key: key);

  @override
  CollapsablePostContentController initController() =>
      CollapsablePostContentController();

  @override
  Widget buildMain() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          postText.isNotEmpty ? this._postText : Container(),
          this._afterTextContent,
        ],
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

  Widget get _afterTextContent =>
      mediaContent == null ? _collapsableSection : _collapsableSectionWithMedia;

  Widget get _collapsableSection => LayoutBuilder(
        builder: (context, constraints) {
          int numberOfLines = postText.numberOfTextLinesToDisplay(
            style: postTextStyle ?? _defaultPostTextStyle,
            maxWidth: constraints.maxWidth - postTextHorizontalPadding * 2,
            textAlign: TextAlign.justify,
          );
          return numberOfLines > minLines ? _postCollapseButton : Container();
        },
      );
  Widget get _collapsableSectionWithMedia => Stack(
        alignment: Alignment.topCenter,
        children: [
          _postMediaContent,
          Transform.translate(
            offset: Offset(0, -10),
            child: this._collapsableSection,
          ),
        ],
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
            _moreLessButton,
            mediaContent != null
                ? Container()
                : Expanded(
                    child: Divider(
                      indent: 5.0,
                      thickness: 1,
                      color: Colors.grey[400],
                    ),
                  ),
          ],
        ).paddingSymmetric(horizontal: 10),
      );

  Widget get _moreLessButton => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey[300],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(c.postTextCollapsed ? 'more' : 'less'),
            Icon(
              c.postTextCollapsed ? Icons.arrow_drop_down : Icons.arrow_drop_up,
              size: 15,
            ),
          ],
        ).paddingSymmetric(horizontal: 10, vertical: 2),
      );

  Widget get _postMediaContent => mediaContent;
}
