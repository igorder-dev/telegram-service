import 'package:id_mvc_app_framework/utils/async/async_lock.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';
import 'package:telegram_service/tdapi.dart' as tdapi;

import 'package:telegram_service_example/utils/telegram/handlers/telegram_file_download_handler.dart';

class LoadMessagePhotoCmd {
  static MvcCommand<MvcCommandSingleParam<tdapi.PhotoSize>, void> cmd(
          tdapi.PhotoSize photoFile) =>
      MvcCommand<MvcCommandSingleParam<tdapi.PhotoSize>, void>.async(
        params: MvcCommandSingleParam(photoFile),
        func: (param) async {
          final photoObject = param.value;
          if (photoObject == null) return;

          final asyncLock = AsyncLock();
          TdlibFileDownloadHandler.instance.downloadFile(photoObject.photo,
              (file, path) {
            photoObject.photo = file;
            asyncLock.release();
          }, onFileDownloading: (file) {});

          return await asyncLock();
        },
        canBeDoneOnce: true,
      );
}
