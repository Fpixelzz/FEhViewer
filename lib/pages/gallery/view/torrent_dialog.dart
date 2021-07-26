import 'dart:collection';
import 'dart:math';

import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class TorrentView extends StatelessWidget {
  const TorrentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TorrentController controller = Get.find(tag: pageCtrlDepth);
    return controller.obx(
      (TorrentProvider? state) {
        if (state == null) {
          return const SizedBox.shrink();
        }

        final column = SingleChildScrollView(
          child: Column(
            children: state.torrents
                .map((torrent) => Column(
                      children: [
                        TorrentItem(
                            torrent: torrent, token: state.torrentToken),
                        Divider(
                          height: 0.5,
                          color: CupertinoDynamicColor.resolve(
                              CupertinoColors.systemGrey4, context),
                        ),
                      ],
                    ))
                .toList(),
          ),
        );

        return IntrinsicHeight(
          child: column,
        );
      },
      onLoading: Container(
        child: const CupertinoActivityIndicator(
          radius: 14,
        ),
      ),
      onError: (err) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  Icons.refresh,
                  size: 30,
                  color: Colors.red,
                ),
                onPressed: () {
                  controller.reload();
                },
              ),
              const Text(
                'Error',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TorrentItem extends StatelessWidget {
  const TorrentItem({
    Key? key,
    required this.torrent,
    required this.token,
  }) : super(key: key);

  final GalleryTorrent torrent;
  final String token;

  @override
  Widget build(BuildContext context) {
    final LinkedHashMap<IconData, String?> trMap = LinkedHashMap.from(
      {
        LineIcons.arrowCircleUp: torrent.seeds,
        LineIcons.arrowCircleDown: torrent.peerd,
        LineIcons.checkCircle: torrent.downloads,
        LineIcons.ggCurrencyCircle: torrent.sizeText,
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: trMap.entries
                .map(
                  (e) => Row(
                    children: [
                      Icon(e.key,
                              size: 16,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.label, context))
                          .paddingOnly(right: 3),
                      Text(e.value ?? ''),
                    ],
                  ),
                )
                .toList(),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      torrent.name ?? '',
                      textAlign: TextAlign.start,
                      // maxLines: 3,
                      // overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                  onTap: () async {
                    final String torrentUrl =
                        '${EHConst.EH_TORRENT_URL}/$token/${torrent.hash}.torrent';
                    logger.d('${torrent.name}\n${torrent.hash}\ntorrentUrl');
                    if (await canLaunch(torrentUrl)) {
                      await launch(torrentUrl);
                    } else {
                      throw 'Could not launch $torrentUrl';
                    }
                  },
                ),
              ),
              CupertinoTheme(
                data: const CupertinoThemeData(
                    primaryColor: CupertinoColors.systemRed),
                child: CupertinoButton(
                  padding: const EdgeInsets.only(left: 0),
                  minSize: 30,
                  child: const Icon(
                    FontAwesomeIcons.magnet,
                    size: 16,
                  ),
                  onPressed: () {
                    final String _magnet =
                        'magnet:?xt=urn:btih:${torrent.hash}';
                    logger.v(_magnet);
                    Share.share(_magnet);
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showTorrentDialog() {
  return showCupertinoDialog<void>(
      context: Get.overlayContext!,
      barrierDismissible: true,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(S.of(Get.context!).p_Torrent),
          content: const TorrentView(),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(Get.context!).cancel),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      });
}

Future<void> showTorrentModal() {
  return showCupertinoModalBottomSheet<void>(
      context: Get.overlayContext!,
      // barrierDismissible: true,
      builder: (_) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
                onPressed: () {}, child: const TorrentView()),
          ],
        );
      });
}
