import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:yeelinks/async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => SettingPageState();
}

enum CtrlType {
	INPUT_SETTING,
	SWITCH_SETTING
}

class SettingPageState extends BasePageState<Page> {
	static const SYS_SETTING = 1;
	static const DEV_SETTING = 2;
	static const ARCD_SETTING = 3;
	static const UPS_SETTING = 4;
	static const ENV_SETTING = 5;
	List<Device> _devices = [];
	Map<int, NamedWithID> _settings = {};
	int _selSetting = DEV_SETTING;

	Map<String, String> _aircondSettings = {
		"空调开关机": "关机",
		"回风温度设定": "30.0",
		"送风温度设定": "30.0",
		"最小湿度设定": "30.0",
		"最大湿度设定": "30.0",
		"回风高温告警": "30.0",
		"送风高温告警": "30.0",
		"送风低温告警": "30.0",
		"回风高湿告警": "30.0",
		"回风低湿告警": "30.0"
	};

	@override
	void initState() {
		global.refreshTimer.register("listDevicesOfSetting", TimerJob(getDevList, hdlDevices, {
			TimerJob.PAGE_IDEN: pageId()
		}));
		_settings = {
			SYS_SETTING: NamedWithID(SYS_SETTING, "系统设置", _systemSettingContent),
			ARCD_SETTING: NamedWithID(ARCD_SETTING, "空调设置", _arcdSettingContent),
			UPS_SETTING: NamedWithID(UPS_SETTING, "UPS设置", _upsSettingContent),
			ENV_SETTING: NamedWithID(ENV_SETTING, "环境设置", _envSettingContent),
			DEV_SETTING: NamedWithID(DEV_SETTING, "设备设置", _devSettingContent)
		};
		KeyboardVisibilityNotification().addNewListener(onHide: () {
			SystemChrome.setEnabledSystemUIOverlays([]);
		});
	}

	Widget _systemSettingContent() => Center(child: FlatButton(
		color: global.primaryColor,
		child: Text("检查更新", style: TextStyle(color: Colors.white)),
		onPressed: () {

		})
	);

	Widget _buildCtrlItem(String title, String status, {
		double subSize = 0,
		String subTitle = "",
		String suffix = "    ",
		CtrlType ctrlType = CtrlType.INPUT_SETTING,
		Widget ctrl
	}) {
		final titleTextStyle = TextStyle(color: const Color(0xFF757575), fontSize: 25 - subSize);
		final subTitleTextStyle = TextStyle(color: global.primaryColor, fontSize: 15 - subSize);
		final contentTextStyle = TextStyle(color: global.primaryColor, fontSize: 25 - subSize);
		final ctrlTextStyle = TextStyle(color: global.primaryColor, fontSize: 20 - subSize);
		if (ctrl == null) {
			switch (ctrlType) {
				case CtrlType.INPUT_SETTING:
					final onClickSetting = (){

					};
					ctrl = Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
						SizedBox(width: 100 - subSize * 2, child: TextField()),
						VerticalDivider(width: 20 - subSize * 2, color: Colors.white),
						subSize > 5 ? OutlineButton(
							child: Icon(Icons.settings, color: global.primaryColor),
							borderSide: BorderSide(
								color: global.primaryColor
							),
							shape: CircleBorder(),
							onPressed: onClickSetting,
						) : OutlineButton(
							borderSide: BorderSide(
								color: global.primaryColor
							),
							child: Text("设定", style: ctrlTextStyle),
							onPressed: onClickSetting
						)
					]);
					break;
				case CtrlType.SWITCH_SETTING:
					ctrl = Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
						Switch(activeColor: global.primaryColor, value: true, onChanged: (bool value) {}),
						Text("开启", style: ctrlTextStyle)
					]);
					break;
			}
		}
		var ttlAry = [
			Text(title,
				textAlign: TextAlign.center,
				style: titleTextStyle,
			)
		];
		if (subTitle.isNotEmpty) {
			ttlAry.add(Text(subTitle,
				textAlign: TextAlign.center,
				style: subTitleTextStyle,
			));
		}
		return Expanded(child: Row(children: <Widget>[
			Expanded(child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: ttlAry
			)),
			Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
				Text(status,
					textAlign: TextAlign.center,
					style: contentTextStyle
				),
				VerticalDivider(color: Colors.white),
				Text(suffix, style: titleTextStyle)
			]),
			Expanded(child: ctrl)
		]));
	}

	Widget _arcdSettingContent() => Column(children: <Widget>[
		DataCard(title: "空调参数设定", child: Padding(
			padding: EdgeInsets.symmetric(horizontal: 50),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					_buildCtrlItem("空调开关机", _aircondSettings["空调开关机"], ctrlType: CtrlType.SWITCH_SETTING),
					_buildCtrlItem("回风温度设定", _aircondSettings["回风温度设定"], suffix: "℃"),
					_buildCtrlItem("送风温度设定", _aircondSettings["送风温度设定"], suffix: "℃"),
					_buildCtrlItem("最小湿度设定", _aircondSettings["最小湿度设定"], suffix: "%"),
					_buildCtrlItem("最大湿度设定", _aircondSettings["最大湿度设定"], suffix: "%"),
					_buildCtrlItem("回风高温告警", _aircondSettings["回风高温告警"], suffix: "℃"),
					_buildCtrlItem("送风高温告警", _aircondSettings["送风高温告警"], suffix: "℃"),
					_buildCtrlItem("送风低温告警", _aircondSettings["送风低温告警"], suffix: "℃"),
					_buildCtrlItem("回风高湿告警", _aircondSettings["回风高湿告警"], suffix: "%"),
					_buildCtrlItem("回风低湿告警", _aircondSettings["回风低湿告警"], suffix: "%"),
				]
			)
		))
	]);

	Widget _buildBatteryChangeInterval() {
		final TextStyle titleTextStyle = TextStyle(fontSize: 25, color: const Color(0xFF757575));
		final TextStyle subTtlTextStyle = TextStyle(fontSize: 20, color: const Color(0xFF757575));
		final TextStyle contentTextStyle = TextStyle(fontSize: 20, color: global.primaryColor);
		return Expanded(flex: 2, child: Padding(
			padding: EdgeInsets.only(top: 20),
			child: Column(children: <Widget>[
				Column(
					children: <Widget>[
						Text("电池更换时间设置（6位数）", textAlign: TextAlign.center, style: titleTextStyle),
						Row(children: <Widget>[
							Expanded(child: Text("年", textAlign: TextAlign.center, style: subTtlTextStyle)),
							Expanded(child: Text("月", textAlign: TextAlign.center, style: subTtlTextStyle)),
							Expanded(child: Text("日", textAlign: TextAlign.center, style: subTtlTextStyle)),
						]),
						Row(children: <Widget>[
							Expanded(child: Text("17", textAlign: TextAlign.center, style: contentTextStyle)),
							Expanded(child: Text("7", textAlign: TextAlign.center, style: contentTextStyle)),
							Expanded(child: Text("25", textAlign: TextAlign.center, style: contentTextStyle)),
						])
					]
				),
				Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Expanded(child: TextField()),
						VerticalDivider(width: 25, color: Colors.white),
						OutlineButton(
							borderSide: BorderSide(color: global.primaryColor),
							child: Text("设定", style: TextStyle(
								color: global.primaryColor,
								fontSize: 20
							)),
							onPressed: () {}
						)
					]
				))
			])
		));
	}

	Widget _upsSettingContent() => Row(children: <Widget>[
		DataCard(title: "UPS", flex: 2, child: Padding(
			padding: EdgeInsets.symmetric(horizontal: 20),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					_buildCtrlItem("蜂鸣器开启", "是", ctrlType: CtrlType.SWITCH_SETTING),
					_buildCtrlItem("旁路禁止使能", "是", ctrlType: CtrlType.SWITCH_SETTING),
					_buildCtrlItem("关闭时使能旁路", "是", ctrlType: CtrlType.SWITCH_SETTING),
					_buildCtrlItem("高效模式使能", "是", ctrlType: CtrlType.SWITCH_SETTING),
					_buildCtrlItem("旁路高切换电压", "253.00", subTitle: "(253、231、242、264)", suffix: "V", ctrlType: CtrlType.INPUT_SETTING),
					_buildCtrlItem("旁路低切换电压", "253.00", subTitle: "(187、176、165、154)", suffix: "V", ctrlType: CtrlType.INPUT_SETTING),
					_buildCtrlItem("高效模式电压上限", "253.00", suffix: "V", ctrlType: CtrlType.INPUT_SETTING),
					_buildCtrlItem("高效模式电压下限", "253.00", suffix: "V", ctrlType: CtrlType.INPUT_SETTING),
				]
			)
		)),
		Expanded(child: Column(children: <Widget>[
			DataCard(title: "UPS电池", flex: 2, child: Column(children: <Widget>[
				_buildCtrlItem("电池AH数设置", "100", subSize: 8),
				_buildCtrlItem("电池并联组数", "0", subSize: 8),
				_buildBatteryChangeInterval()
			])),
			DataCard(title: "UPS紧急开关机", child: Row(children: <Widget>[
				_buildCtrlItem("UPS状态", "在线模式", ctrlType: CtrlType.SWITCH_SETTING)
			])),
		]),)
	]);

	Widget _envSettingContent() => Column(children: <Widget>[
		Expanded(child: Row(children: <Widget>[
			DataCard(title: "微环境冷通道", child: Column(children: <Widget>[
				_buildCtrlItem("高温报警值", "32.0"),
				_buildCtrlItem("低温报警值", "32.0"),
				_buildCtrlItem("高湿报警值", "32.0"),
			])),
			DataCard(title: "微环境热通道", child: Column(children: <Widget>[
				_buildCtrlItem("高温报警值", "32.0"),
				_buildCtrlItem("低温报警值", "32.0"),
				_buildCtrlItem("高湿报警值", "32.0"),
			]))
		])),
		DataCard(title: "应急风扇控制", child: Column(children: <Widget>[
			_buildCtrlItem("风扇状态", "关闭", ctrlType: CtrlType.SWITCH_SETTING),
			_buildCtrlItem("风扇启动温度", "0.0"),
			_buildCtrlItem("风扇停止温度", "0.0"),
		]))
	]);

	Widget _devSettingContent() => GridView.count(
		crossAxisCount: 5,
		mainAxisSpacing: 10.0,
		crossAxisSpacing: 10.0,
		children: _genDevCards()
	);

	List<Widget> _genSettingBtns() {
		List<Widget> ret = [];
		var stgBtns = _settings.values.toList();
		for (int i = 0; i < stgBtns.length; i++) {
			var btn = stgBtns[i];
			ShapeBorder btnBorder = RoundedRectangleBorder();
			if (i == 0) {
				btnBorder = RoundedRectangleBorder(
					borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
				);
			} else if (i == stgBtns.length - 1) {
				btnBorder = RoundedRectangleBorder(
					borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
				);
			}
			if (btn.id == _selSetting) {
				ret.add(FlatButton(
					child: Text(btn.name, style: TextStyle(color: Colors.white)),
					disabledColor: global.primaryColor,
					shape: btnBorder,
					onPressed: null));
			} else {
				ret.add(OutlineButton(
					child: Text(btn.name, style: TextStyle(color: global.primaryColor)),
					borderSide: BorderSide(color: global.primaryColor),
					shape: btnBorder,
					onPressed: () => setState(() {
						_selSetting = btn.id;
					})
				));
			}
		}
		return ret;
	}

	@override
	Widget build(BuildContext context) {
		Widget content = _settings[_selSetting].func();
		return Column(children: <Widget>[
			Row(mainAxisAlignment: MainAxisAlignment.center, children: _genSettingBtns()),
			Divider(),
			Expanded(child: content)
		]);
	}

	List<Widget> _genDevCards() {
		final textColor = Colors.grey[600];
		final loadBtnCtt = (color) => Padding(padding: EdgeInsets.symmetric(vertical: 10),
			child: SizedBox(width: 80, child: SpinKitWave(size: 25, color: color))
		);
		return _devices.map<Widget>((device) => Container(
			padding: EdgeInsets.symmetric(vertical: 50),
			decoration: BoxDecoration(
				border: Border.all(color: global.primaryColor)
			),
			child: Column(children: <Widget>[
				Text(device.name, style: TextStyle(fontSize: 30, color: textColor)),
				Text("状态：${device.status == 1 ? "开启" : "关闭"}", style: TextStyle(fontSize: 20, color: textColor)),
				Divider(color:Colors.white, height: 10),
				device.status == 1 ? OutlineButton(
					borderSide: BorderSide(color: global.primaryColor),
					child: device.loading ? loadBtnCtt(global.primaryColor) : Text("关闭", style: TextStyle(fontSize: 10, color: global.primaryColor)),
					onPressed: !device.loading ? () async {
						setState(() {
							device.loading = true;
						});
						await turnOnOffDev(device.id, DEV_OFF);
						device.loading = false;
					} : () {}
				) : FlatButton(
					color: global.primaryColor,
					child: device.loading ? loadBtnCtt(Colors.white) : Text("开启", style: TextStyle(fontSize: 10, color: Colors.white)),
					onPressed: !device.loading ? () async {
						setState(() {
							device.loading = true;
						});
						await turnOnOffDev(device.id, DEV_ON);
						device.loading = false;
					} : () {}
				),
			])
		)).toList();
	}

    @override
    String pageId() => "setting";

	@override
	void hdlDevices(data) => setState(() {
		_devices = data.toList();
	});

	@override
	void hdlPointVals(dynamic data) {

	}
}