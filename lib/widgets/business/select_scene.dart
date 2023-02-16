import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/states/index.dart';
import 'package:screen_app/widgets/index.dart';
import 'package:screen_app/widgets/event_bus.dart';

import '../../common/utils.dart';
import '../../routes/home/scene/scene.dart';

class SelectSceneList extends StatefulWidget {
  const SelectSceneList({super.key, confirm});

  @override
  State<StatefulWidget> createState() => _SelectSceneListState();
}

class _SelectSceneListState extends State<SelectSceneList> {
  List<Scene> sceneList = [];
  List<String> selectList = [];

  @override
  Widget build(BuildContext context) {
    final sceneChangeNotifier = context.watch<SceneChangeNotifier>();
    sceneList = sceneChangeNotifier.sceneList;
    // TODO: 需要切换到正确的图片
    Widget content = sceneList.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Image(
                  image: AssetImage('assets/imgs/scene/empty.png'),
                  width: 200,
                  height: 200),
              Opacity(
                opacity: 0.5,
                child: Text(
                  '请到美居APP内添加场景',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'MideaType',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          )
        : ListView.builder(
            shrinkWrap: true,
            prototypeItem: _SelectSceneItem(
              isSelect: true,
              title: '123',
              value: true,
              onTap: (_) {},
            ),
            itemCount: sceneList.length,
            itemBuilder: (context, index) {
              return _SelectSceneItem<Scene>(
                isSelect: selectList.contains(sceneList[index].key),
                title: sceneList[index].name,
                value: sceneList[index],
                onTap: (value) {
                  setState(() {
                    final findIndex = selectList
                        .indexWhere((element) => element == value.key);
                    if (findIndex != -1) {
                      selectList.removeAt(findIndex);
                      return;
                    } else if (selectList.length > 3) {
                      TipsUtils.toast(content: '最多选择4个场景');
                      return;
                    }
                    selectList.add(value.key);
                  });
                },
              );
            },
          );
    return content;
  }

  @override
  void initState() {
    super.initState();
    bus.on('selectSceneConfirm', (arg) {
      confirm();
    });
    final sceneChangeNotifier = context.read<SceneChangeNotifier>();
    selectList = List.from(sceneChangeNotifier.selectList);
    if (sceneChangeNotifier.sceneList.isEmpty) {
      // 可能场景加载失败，再请求一次
      sceneChangeNotifier.updateSceneList();
    }
  }

  void confirm() {
    final sceneChangeNotifier = context.read<SceneChangeNotifier>();
    sceneChangeNotifier.selectList = selectList;
    sceneChangeNotifier.updateSceneList();
    Navigator.pop(context);
  }
}

class _SelectSceneItem<T> extends StatelessWidget {
  final bool isSelect;
  final String title;
  final T value;
  final void Function(T value) onTap;

  const _SelectSceneItem({
    super.key,
    required this.isSelect,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100),
      child: MzCell(
        hasTopBorder: true,
        title: title,
        titleSize: 20.0,
        onTap: () => onTap(value),
        rightSlot: MzRadio<bool>(
          value: true,
          groupValue: isSelect,
        ),
      ),
    );
  }
}
