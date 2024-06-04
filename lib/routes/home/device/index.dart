import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:screen_app/common/gateway_platform.dart';
import 'package:screen_app/common/index.dart';
import 'package:screen_app/models/index.dart';
import 'package:screen_app/states/page_change_notifier.dart';
import 'package:screen_app/widgets/card/edit.dart';
import 'package:screen_app/widgets/keep_alive_wrapper.dart';
import 'package:screen_app/widgets/util/debouncer.dart';
import 'package:screen_app/widgets/util/net_utils.dart';

import '../../../common/api/api.dart';
import '../../../common/homlux/api/homlux_user_api.dart';
import '../../../common/homlux/push/event/homlux_push_event.dart';
import '../../../common/logcat_helper.dart';
import '../../../common/meiju/push/event/meiju_push_event.dart';
import '../../../models/device_entity.dart';
import '../../../states/device_list_notifier.dart';
import '../../../states/layout_notifier.dart';
import '../../../states/relay_change_notifier.dart';
import '../../../states/scene_list_notifier.dart';
import '../../../widgets/event_bus.dart';
import '../../../widgets/indicatior.dart';
import '../../../widgets/util/compare.dart';
import '../../../widgets/util/deviceEntityTypeInP4Handle.dart';
import 'card_type_config.dart';
import 'grid_container.dart';
import 'layout_data.dart';

/// 非待机首页刷新时间 3分钟
const int normalLoopTime = 3 * 60;

class DevicePage extends StatefulWidget {
  DevicePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> with WidgetNetState {
  // 准备一个定时器
  Timer? _timer;
  Timer? _netTimer;

  /*
  target: 启动定时器-->每 180秒/3分钟 刷新一次列表
  */
  void startPolling(BuildContext context) {
    const oneMinute = Duration(seconds: normalLoopTime);
    // 使用周期性定时器，每分钟触发一次
    _timer?.cancel();
    _timer = Timer.periodic(oneMinute, (Timer timer) async {
      Log.i('[首页] 时间间隔到，刷新页面');
      autoDeleleLayout(context);
    });
  }

  /// [standby] true 进入待机模式 false 退出待机模式
  void standbyChange(bool standby) {
    if (!standby) {
      Log.i('[首页] 退出待机强制刷新页面');
      autoDeleleLayout(context);
      startPolling(context);
    } else {
      Log.i('[首页] 取消后台更新页面定时器');
      _timer?.cancel();
    }
  }

  // [检测网络切换]
  @override
  void netChange(MZNetState? state) {
    if (state != null) {
      Log.i('[首页] 检测网络切换，强制刷新首页');
      _netTimer?.cancel();
      _netTimer = Timer(const Duration(seconds: 10), () {
        Log.i("[首页] 10s延迟到期，即将请求");
        autoDeleleLayout(context);
      });
      startPolling(context);
    }
  }

  /*
  target: 卸载定时器
   */
  void stopPolling() {
    _timer?.cancel();
    _netTimer?.cancel();
  }

  /*
   target: 去除缓存拿到的布局中在屏幕没有启动的情况下被去除的设备
   */
  Future<void> firstInitForOffPower(BuildContext context) async {
    // 立即清除一次
    final sceneModel = context.read<SceneListModel>();
    final deviceModel = context.read<DeviceInfoListModel>();
    final layoutModel = context.read<LayoutModel>();
    // 获取设备列表的网络数据
    List<DeviceEntity> deviceRes = await deviceModel.getDeviceList("查询设备列表：firstInitForOffPower");
    sceneModel.getSceneList();
    // 先收集布局（需要去除场景/时钟/天气/自定义跳转）中的ids
    List<String> layoutDeviceIds = layoutModel.layouts
        .where((element) =>
            element.type != DeviceEntityTypeInP4.Scene &&
            element.type != DeviceEntityTypeInP4.Weather &&
            element.type != DeviceEntityTypeInP4.Clock &&
            element.type != DeviceEntityTypeInP4.DeviceEdit)
        .map((e) => e.deviceId)
        .toList();
    // 再拿到网络设备列表映射成ids
    List<String> netListDeviceIds = deviceRes.map((e) => e.applianceCode).toList();
    // 默认的房间灯组加入网络列表在ids中避免他被自动清掉
    var roomList = await HomluxUserApi.queryRoomList(System.familyInfo!.familyId);
    String curGroupId = roomList.data?.roomInfoWrap?.firstWhere((element) => element.roomId == System.roomInfo?.id).groupId;
    netListDeviceIds.add(curGroupId);
    // 做diff对比上面拿到的两个ids
    List<List<String>> compareDevice = Compare.compareData<String>(layoutDeviceIds, netListDeviceIds);
    // 获取到diff的删除差值，并遍历每一个被删除的设备
    compareDevice[1].forEach((compare) {
      // 想要安全删除目标设备的布局数据：1.确认是否因为删除该布局造成空页，2.流式布局：重新编排该页其他布局的grids，3.确保待定区补充
      // 获取到provider中当前id的Layout数据
      Layout curLayout = layoutModel.getLayoutsByDevice(compare);
      // 没有找到的情况下，逻辑出错退出本函数逻辑
      if (curLayout.deviceId == '-1') return;
      // 删除该布局数据
      layoutModel.deleteAndFlexLayout(compare);
    });
  }

  /*
   target: 在定时器运行拉取到网络数据的瞬间，自动删除已经被删除的设备
   */
  Future<void> autoDeleleLayout(BuildContext context) async {
    final sceneModel = context.read<SceneListModel>();
    final deviceModel = context.read<DeviceInfoListModel>();
    final layoutModel = context.read<LayoutModel>();
    final relayModel = context.read<RelayModel>();
    // 刷新两路继电器名称
    relayModel.getLocalRelayName();
    // 拿到layout数据中的ids
    List<String> layoutIds = layoutModel.layouts.map((e) => e.deviceId).toList();
    // 拉取缓存数据
    List<DeviceEntity> deviceCache = deviceModel.deviceCacheList.where((element) => layoutIds.contains(element.applianceCode)).toList();

    Set<DeviceEntity> deviceCacheSetDeepCopy = Set.from(deviceCache);
    List<DeviceEntity> deviceCaCheListDeepCopy = deviceCacheSetDeepCopy.toList();
    // 拉取网络数据
    List<DeviceEntity> deviceRes = await deviceModel.getDeviceList("查询设备列表：定时器时间到达");
    List<SceneInfoEntity> sceneRes = await sceneModel.getSceneList();
    sceneModel.roomDataAd.queryRoomList(System.familyInfo!);
    // 先收集布局（需要去除场景/时钟/天气/自定义跳转）中的ids
    List<String> layoutDeviceIds = layoutModel.layouts
        .where((element) =>
            element.type != DeviceEntityTypeInP4.Weather &&
            element.type != DeviceEntityTypeInP4.Clock &&
            element.type != DeviceEntityTypeInP4.DeviceEdit)
        .map((e) => e.deviceId)
        .toList();
    // 再拿到网络设备列表映射成ids
    List<String> netListDeviceIds = deviceRes.map((e) => e.applianceCode).toList();
    // 默认的房间灯组加入网络列表在ids中避免他被自动清掉
    var roomList = await HomluxUserApi.queryRoomList(System.familyInfo!.familyId);
    String curGroupId = roomList.data?.roomInfoWrap?.firstWhere((element) => element.roomId == System.roomInfo?.id).groupId;
    netListDeviceIds.add(curGroupId);
    // 再加入网络场景表映射成ids
    netListDeviceIds.addAll(sceneRes.map((e) => e.sceneId as String).toList());
    // 做diff对比上面拿到的两个ids
    List<List<String>> compareDevice = Compare.compareData<String>(layoutDeviceIds, netListDeviceIds);
    // 找到需要删除的设备
    Log.i('找到要删除的设备', compareDevice[1]);
    compareDevice[1].forEach((compare) {
      // 想要安全删除目标设备的布局数据：1.确认是否因为删除该布局造成空页，2.流式布局：重新编排该页其他布局的grids，3.确保待定区补充
      // 获取到provider中当前id的Layout数据
      Layout curLayout = layoutModel.getLayoutsByDevice(compare);
      // 没有找到的情况下，逻辑出错退出本函数逻辑
      if (curLayout.deviceId == '-1') return;
      // 删除该布局数据
      layoutModel.deleteAndFlexLayout(compare);
      // 发起toast提醒用户
      // 获取设备名字
      String deletedDeviceName = deviceCaCheListDeepCopy.firstWhere((element) => element.applianceCode == compare, orElse: () {
        DeviceEntity deviceObj = DeviceEntity();
        deviceObj.name = '未知的设备';
        return deviceObj;
      }).name;
      if (deletedDeviceName != '未知的设备') {
        TipsUtils.toast(content: '已删除$deletedDeviceName');
      }
    });
  }

  // 用于pageView的controller
  PageController _pageController = PageController();

  // 用于存储pageView的页面
  List<Widget> _screens = [];

  // 用于pageView的indicator（指示器）更新
  GlobalKey<IndicatorState> indicatorState = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 启动推送接收
    _startPushListen();
    // 启动首页页数重置bus监听（主要用户custom中造成的页面滑动返回后首页同步这个pageIndex）
    bus.on("mainToRecoverState", changeToTargetPage);
    bus.on("eventStandbyActive", standbyChange);
    Log.develop("DevicePageState initState");
    final deviceListModel = Provider.of<DeviceInfoListModel>(context, listen: false);
    // 拉取设备列表数据
    deviceListModel.getDeviceList("查询设备列表: 首页instate");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 初始化清除断电干扰
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted || !System.isLogin()) return;
        firstInitForOffPower(context);
      });
      // 启动拉取定时器
      startPolling(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // 关闭推送
    _stopPushListen();
    Log.develop("DevicePageState dispose");
    // 关闭custom页数更改bus
    bus.off("eventStandbyActive", standbyChange);
    bus.off("mainToRecoverState", changeToTargetPage);
    // 终止定时器
    stopPolling();
    super.dispose();
  }

  /// 显示更改页面的位置
  void changeToTargetPage(dynamic position) {
    if (mounted) {
      if (position >= _screens.length) return;
      final pageCounterModel = Provider.of<PageCounter>(context, listen: false);
      Log.i('切换到页面：${pageCounterModel.currentPage}');
      _pageController.jumpToPage(pageCounterModel.currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final layoutModel = Provider.of<LayoutModel>(context);
    final deviceModel = Provider.of<DeviceInfoListModel>(context);
    if (mounted) {
      // try {
      getScreenList(layoutModel, deviceModel);
      // } catch (e) {
      //   Log.i('Error', e);
      //   _screens = [];
      // }
    }
    return GestureDetector(
      onLongPress: () {
        Navigator.of(context).pushNamed('Custom');
      },
      child: Stack(
        children: [
          if (layoutModel.layouts.isNotEmpty)
            PageView.builder(
              key: const ValueKey("123456"),
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                context.read<PageCounter>().currentPage = index;
                indicatorState.currentState?.updateIndicator(index);
              },
              allowImplicitScrolling: true,
              itemCount: _screens.length,
              itemBuilder: (context, index) {
                return KeepAliveWrapper(child: _screens[index]);
              },
            ),
          if (layoutModel.layouts.isEmpty)
            const SizedBox(
              width: 480,
              height: 480,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(image: AssetImage('assets/newUI/empty.png')),
                  ],
                ),
              ),
            ),
          if (layoutModel.layouts.isNotEmpty && layoutModel.getMaxPageIndex() > 1)
            Indicator(key: indicatorState, defaultPosition: context.read<PageCounter>().currentPage, itemCount: _screens.length)
        ],
      ),
    );
  }

  /*
  target:对每一页布局数据进行渲染
   */
  List<Widget> getScreenList(LayoutModel layoutModel, DeviceInfoListModel deviceModel) {
    // 清空
    _screens.clear();
    // 当前页面的widgets
    List<Widget> curScreenWidgetList = [];
    // 已经被排布的页面数量
    int hadPageCount = layoutModel.getMaxPageIndex();
    // 初始化布局占位器
    Screen screenLayer = Screen();

    for (int pageCount = 0; pageCount <= hadPageCount; pageCount++) {
      // ************布局
      // 先获取当前页的布局，设置screenLayer布局器
      List<Layout> layoutsInCurPage =
          layoutModel.getLayoutsByPageIndex(pageCount).where((element) => element.cardType != CardType.Null).toList();
      // 防止空页被渲染
      if (layoutsInCurPage.isEmpty) continue;
      for (int layoutInCurPageIndex = 0; layoutInCurPageIndex < layoutsInCurPage.length; layoutInCurPageIndex++) {
        // 取出当前布局的grids
        for (int gridsIndex = 0; gridsIndex < layoutsInCurPage[layoutInCurPageIndex].grids.length; gridsIndex++) {
          // 把已经布局的数据在布局器中占位
          int grid = layoutsInCurPage[layoutInCurPageIndex].grids[gridsIndex];
          int row = (grid - 1) ~/ 4;
          int col = grid % 4 - 1 != -1 ? grid % 4 - 1 : 3;
          screenLayer.setCellOccupied(row, col, true);
        }
      }
      // ************布局

      // ************单页构造
      // 是否能在单页处理中插入editCard
      bool isCanAdd = true;
      // 最后一页，尝试把editCard塞进去
      if (pageCount == hadPageCount) {
        List<int> editCardFillCells = screenLayer.checkAvailability(CardType.Edit);
        // 当占位成功
        List<int> sumGrid = [];
        layoutsInCurPage.forEach((element) {
          sumGrid.addAll(element.grids);
        });
        if (editCardFillCells.isNotEmpty && editCardFillCells[0] > sumGrid.reduce(max)) {
          layoutsInCurPage.add(
            Layout(
              uuid.v4(),
              DeviceEntityTypeInP4.DeviceEdit,
              CardType.Edit,
              hadPageCount,
              editCardFillCells,
              DataInputCard(
                name: '',
                applianceCode: '',
                roomName: '',
                isOnline: '',
                type: '',
                masterId: '',
                modelNumber: '',
                onlineStatus: '1',
              ),
            ),
          );
        } else {
          isCanAdd = false;
        }
      }
      // 映射排序
      List<Layout> sortedLayoutList = Layout.sortLayoutList(layoutsInCurPage);
      // 根据队列顺序插入该屏页面
      for (Layout layoutAfterSort in sortedLayoutList) {
        // 映射出对应的Card
        layoutAfterSort.data.disabled = false;
        layoutAfterSort.data.context = context;
        // Log.i('layoutAfterSort', layoutAfterSort.type);
        if (buildMap[layoutAfterSort.type]?[layoutAfterSort.cardType] == null) {
          Log.e("异常布局类型 ${layoutAfterSort.type} ${layoutAfterSort.cardType} ");
          continue;
        }
        Widget cardWidget = buildMap[layoutAfterSort.type]![layoutAfterSort.cardType]!(layoutAfterSort.data);
        // 映射布局占格
        Widget cardWithPosition = StaggeredGridTile.fit(
          key: UniqueKey(),
          crossAxisCellCount: sizeMap[layoutAfterSort.cardType]!['cross']!,
          child: UnconstrainedBox(
            key: UniqueKey(),
            child: GestureDetector(
              child: cardWidget,
              onLongPress: () {
                Navigator.pushNamed(
                  context,
                  'Custom',
                );
              },
            ),
          ),
        );
        // 扔进页面里
        curScreenWidgetList.add(cardWithPosition);
      }
      // ************单页构造

      // ************插入pageview
      _screens.add(
        UnconstrainedBox(
          key: UniqueKey(),
          child: Container(
            width: 480,
            height: 480,
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 34),
            child: SingleChildScrollView(
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                axisDirection: AxisDirection.down,
                children: curScreenWidgetList,
              ),
            ),
          ),
        ),
      );
      // ************插入pageview

      if (!isCanAdd) {
        // _screens.add(Center(key: UniqueKey(), child: const EditCardWidget()));
      }

      // 每一页处理前重置布局器
      screenLayer.resetGrid();
      // 每一页处理前情况当前页Widget存储器
      curScreenWidgetList = [];
    }
    return _screens;
  }

  void meijuPushDelete(MeiJuDeviceDelEvent args) {
    if (!mounted) {
      return;
    }
    autoDeleleLayout(context);
  }

  void homluxPushMov(HomluxMovWifiDeviceEvent arg) {
    final deviceModel = context.read<DeviceInfoListModel>();
    deviceModel.getDeviceList("查询设备列表: 设备移动");
  }

  void homluxPushSubMov(HomluxMovSubDeviceEvent arg) {
    final deviceModel = context.read<DeviceInfoListModel>();
    deviceModel.getDeviceList("查询设备列表: 子设备移动");
  }

  void homluxPushDel(HomluxDeviceDelEvent arg) {
    autoDeleleLayout(context);
  }

  void homluxPushSubDel(HomluxDelSubDeviceEvent arg) {
    autoDeleleLayout(context);
  }

  void homluxDeviceListChange(HomluxLanDeviceChange arg) {
    handleHomluxDeviceListChange();
  }

  void homluxPushGroupDelete(HomluxGroupDelEvent arg) {
    autoDeleleLayout(context);
  }

  void homluxRoomUpdate(HomluxChangeRoomNameEven arg) {
    final sceneModel = context.read<SceneListModel>();
    sceneModel.roomDataAd.queryRoomList(System.familyInfo!);
    final deviceModel = context.read<DeviceInfoListModel>();
    deviceModel.getDeviceList("查询设备列表: 房间更新");
  }

  void homluxWifiUpdate(HomluxEditWifiEvent arg) {
    final deviceModel = context.read<DeviceInfoListModel>();
    deviceModel.getDeviceList("查询设备列表: wifi设备被编辑");
  }

  handleHomluxDeviceListChange() {
    final deviceModel = context.read<DeviceInfoListModel>();
    deviceModel.getDeviceList("查询设备列表: 设备列表发生变化");
  }

  // 推送启动中枢
  void _startPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOn<HomluxMovWifiDeviceEvent>(homluxPushMov);
      bus.typeOn<HomluxMovSubDeviceEvent>(homluxPushSubMov);
      bus.typeOn<HomluxDeviceDelEvent>(homluxPushDel);
      bus.typeOn<HomluxGroupDelEvent>(homluxPushGroupDelete);
      bus.typeOn<HomluxLanDeviceChange>(homluxDeviceListChange);
      bus.typeOn<HomluxChangeRoomNameEven>(homluxRoomUpdate);
      bus.typeOn<HomluxEditWifiEvent>(homluxWifiUpdate);
    } else {
      bus.typeOn<MeiJuDeviceDelEvent>(meijuPushDelete);
    }
  }

  // 推送关闭中枢
  void _stopPushListen() {
    if (MideaRuntimePlatform.platform == GatewayPlatform.HOMLUX) {
      bus.typeOff<HomluxMovWifiDeviceEvent>(homluxPushMov);
      bus.typeOff<HomluxMovSubDeviceEvent>(homluxPushSubMov);
      bus.typeOff<HomluxDeviceDelEvent>(homluxPushDel);
      bus.typeOff<HomluxDelSubDeviceEvent>(homluxPushSubDel);
      bus.typeOff<HomluxGroupDelEvent>(homluxPushGroupDelete);
      bus.typeOff<HomluxLanDeviceChange>(homluxDeviceListChange);
      bus.typeOff<HomluxChangeRoomNameEven>(homluxRoomUpdate);
      bus.typeOff<HomluxEditWifiEvent>(homluxWifiUpdate);
    } else {
      bus.typeOff<MeiJuDeviceDelEvent>(meijuPushDelete);
    }
  }
}
