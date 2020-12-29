import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/controller/setting_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'history_page.dart';

class SettingTab extends GetView<SettingViewController> {
  const SettingTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final String tabIndex;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    controller.initData(context);
    final String _title = S.of(context).tab_setting;
    // logger.d(' ${ehTheme.isDarkMode}');
    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            heroTag: 'setting',
            largeTitle: Text(
              _title,
            ),
            trailing: CupertinoButton(
              padding: const EdgeInsets.all(0.0),
              child: const Icon(
                FontAwesomeIcons.history,
                size: 22,
              ),
              onPressed: () {
                Get.to(
                  const HistoryTab(),
                  transition: Transition.cupertino,
                );
              },
            ),
            // transitionBetweenRoutes: true,
          ),
          SliverSafeArea(
              top: false,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  List _itemList = controller.getItemList();
                  if (index < _itemList.length) {
                    return _itemList[index];
                  } else {
                    return null;
                  }
                }),
              ))
        ],
      ),
    );
  }
}