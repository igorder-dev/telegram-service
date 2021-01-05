import 'package:id_mvc_app_framework/utils/async/async_lock.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';
import 'package:telegram_service/tdapi.dart' as tdapi;

import 'package:telegram_service_example/utils/telegram/handlers/telegram_file_download_handler.dart';

class LoadMessageVideoCmd {
  static MvcCommand<MvcCommandSingleParam<tdapi.Video>, void> cmd(
      tdapi.Video videoObject, void Function(tdapi.File file) onLoading) {
    MvcCommand cmd;
    cmd = MvcCommand<MvcCommandSingleParam<tdapi.Video>, void>.async(
      params: MvcCommandSingleParam(videoObject),
      func: (param) async {
        final videoObject = param.value;
        if (videoObject == null) return;

        final asyncLock = AsyncLock();
        TdlibFileDownloadHandler.instance.downloadFile(videoObject.video,
            (file, path) {
          videoObject.video = file;
          asyncLock.release();
        }, onFileDownloading: (file) {
          videoObject.video = file;
          onLoading?.call(file);
          cmd.refresh();
        });

        return await asyncLock();
      },
      canBeDoneOnce: true,
    );
    return cmd;
  }
}
