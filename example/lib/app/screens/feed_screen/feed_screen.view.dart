import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post/post.view.dart';
import 'package:telegram_service_example/app/widgets/telegram_post/post_frame.dart';

import 'feed_screen.controller.dart';

class FeedScreen extends MvcScreen<FeedScreenController> {
  @override
  FeedScreenController initController() => FeedScreenController();

  @override
  Widget defaultScreenLayout(
      ScreenParameters screenParameters, FeedScreenController controller) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('TeleFEED'),
      ),
      body: _body,
      backgroundColor: Colors.grey[400],
    );
  }

  Widget get _body => Container(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TelegramPost(
                  postContent: Text('hello World!!!'),
                  postTime: '07:42 AM',
                  postTitle:
                      'The most awesome channel title The most awesome channel title...',
                ),
                Icon(Icons.star, size: 50),
                PostFrame(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(Icons.star, size: 50),
                  ),
                ),
                Icon(Icons.star, size: 50),
              ],
            ),
          ),
        ),
      );
}

const String postText =
    """Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.""";

const String postText1 =
    """Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.
В чем профит канала? Артем пишет о том, что меняет наш мир, рассказы. Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.
В чем профит канала? Артем пишет о том, что меняет наш мир, рассказы.Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.
В чем профит канала? Артем пишет о том, что меняет наш мир, рассказы.Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.
В чем профит канала? Артем пишет о том, что меняет наш мир, рассказы.Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.
В чем профит канала? Артем пишет о том, что меняет наш мир, рассказы.Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.
В чем профит канала? Артем пишет о том, что меняет наш мир, рассказы.Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.
В чем профит канала? Артем пишет о том, что меняет наш мир, рассказы.Есть такой крутой канал Рездопиз. Фишка канала в том, что его ведет известный в IT-кругах предприниматель Артем Бородатюк, который создал группу компаний Netpeak Group.
В чем профит канала? Артем пишет о том, что меняет наш мир, рассказы!!!""";
