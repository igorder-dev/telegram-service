import 'package:flutter/material.dart';

///Describes post Title  responsive layout (channel avatar / channel name / time of the post) to fill maximum width of partent container
class PostHeader extends StatelessWidget {
  final Color avatarBackgroundColor;
  final ImageProvider avatarImage;
  final TextStyle titleTextStyle;
  final TextStyle postTimeTextStyle;
  final String postTitleString;
  final String postTimeString;

  final TextStyle _defaultTitleTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: const Color(0xff000000).withOpacity(0.87),
  );

  final TextStyle _defaultTimeTextStyle = TextStyle(
    fontSize: 11,
    color: Color(0xff9f9f9f),
  );

  PostHeader({
    Key key,
    this.avatarBackgroundColor,
    this.avatarImage,
    this.titleTextStyle,
    this.postTimeTextStyle,
    @required this.postTitleString,
    @required this.postTimeString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: avatarBackgroundColor,
                    backgroundImage: avatarImage,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          postTitleString,
                          overflow: TextOverflow.ellipsis,
                          style: titleTextStyle ?? _defaultTitleTextStyle,
                        ),
                        Text(
                          postTimeString,
                          style: postTimeTextStyle ?? _defaultTimeTextStyle,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                ],
              ),
            ),
            // Icon(Icons.keyboard_control, size: 20),
          ],
        ),
      );
}
