import 'package:id_mvc_app_framework/framework.dart';

import 'package:telegram_service/telegram_service.dart';
import 'package:telegram_service/tdapi.dart';

typedef void OnFileDownloadedCallback(File file, String path);
typedef void OnFileDownloadingCallback(File file);

class TdlibFileDownloadHandler extends TelegramEventHandler
    with GetxServiceMixin {
  static TdlibFileDownloadHandler get instance => Get.find();

  @override
  List<String> get eventsToHandle => [UpdateFile.CONSTRUCTOR];

  final Map<String, FileDownloadRequest> _downloadRequests =
      Map<String, FileDownloadRequest>();

  @override
  void onTelegramEvent(TdObject event, [String requestID]) {
    Get.log("[FileDownloadHandler] : $requestID - ${event.getConstructor()} ");

    if (event == null) return;
    switch (event.getConstructor()) {
      case UpdateFile.CONSTRUCTOR:
        _handleUpdateFileEvent(event as UpdateFile, requestID);
        return;
      case File.CONSTRUCTOR:
        _handleFileEvent(event as File, requestID);
        return;
    }
  }

  void _handleUpdateFileEvent(UpdateFile uFile, String requestID) =>
      _handleFileEvent(uFile.file, requestID);

  void _handleFileEvent(File file, String requestID) {
    if (file == null) return;
    if (requestID != null && _downloadRequests.containsKey(requestID)) {
      _updateDownloadRequest(file, _downloadRequests[requestID]);
    } else {
      _getRequestsByFile(file).forEach(
        (req) => _updateDownloadRequest(file, req),
      );
    }
  }

  void _updateDownloadRequest(File file, FileDownloadRequest request) {
    if (file.local.isDownloadingCompleted && request.onFileDownloaded != null) {
      request.onFileDownloaded(file, file.local.path);
      _downloadRequests.remove(request.requestID);
      return;
    }

    if (file.local.isDownloadingActive && request.onFileDownloading != null) {
      request.onFileDownloading(file);
      request.file = file;
    }
  }

  List<FileDownloadRequest> _getRequestsByFile(File file) =>
      _downloadRequests.values.where((el) => el.fileId == file.id).toList();

  void downloadFile(
    File file,
    OnFileDownloadedCallback onFileDownloaded, {
    OnFileDownloadingCallback onFileDownloading,
    int priority = 1,
    int limit = 0,
    int offset = 0,
  }) async {
    if (file.local.path?.isEmpty ?? true) {
      String rID = await sendCommand(
        DownloadFile(
          fileId: file.id,
          priority: priority,
          limit: limit,
          offset: offset,
          synchronous: false,
        ),
        withCallBack: true,
      );

      if (rID != null) {
        _downloadRequests[rID] = FileDownloadRequest(
          requestID: rID,
          file: file,
          onFileDownloaded: onFileDownloaded,
          onFileDownloading: onFileDownloading,
        );
      }
    } else {
      _updateDownloadRequest(
        file,
        FileDownloadRequest(
          file: file,
          onFileDownloaded: onFileDownloaded,
        ),
      );
    }
  }
}

class FileDownloadRequest {
  final String requestID;
  File file;
  OnFileDownloadedCallback onFileDownloaded;
  OnFileDownloadingCallback onFileDownloading;

  int get fileId => file.id;

  FileDownloadRequest({
    this.requestID,
    this.file,
    this.onFileDownloaded,
    this.onFileDownloading,
  });
}
