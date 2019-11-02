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
	Map<int, NamedWithID> _settingTabs = {};
	int _selSetting = DEV_SETTING;

	Map<String, String> _settings = {
		"空调开关机": "关机",
		"回风温度设定": "30.0",
		"送风温度设定": "30.0",
		"最小湿度设定": "30.0",
		"最大湿度设定": "30.0",
		"回风高温告警": "30.0",
		"送风高温告警": "30.0",
		"送风低温告警": "30.0",
		"回风高湿告警": "30.0",
		"回风低湿告警": "30.0",

		"蜂鸣器开启": "开启",
		"旁路禁止使能": "是",
		"关闭时使能旁路": "是",
		"高效模式使能": "是",
		"旁路高切换电压": "253.00",
		"旁路低切换电压": "253.00",
		"高效模式电压上限": "253.00",
		"高效模式电压下限": "253.00",
		"电池AH数设置": "100",
		"电池并联组数": "0",
		"电池跟换间隔": "170525",
		"UPS状态": "在线模式",

		"冷通道高温报警值": "32.0",
		"冷通道低温报警值": "32.0",
		"冷通道高湿报警值": "32.0",
		"热通道高温报警值": "32.0",
		"热通道低温报警值": "32.0",
		"热通道高湿报警值": "32.0",
		"风扇状态": "关闭",
		"风扇启动温度": "0.0",
		"风扇停止温度": "0.0",
	};

	@override
	void initState() {
		global.refreshTimer.register("listDevicesOfSetting", TimerJob(getDevList, hdlDevices, {
			TimerJob.PAGE_IDEN: pageId()
		}));
		_settingTabs = {
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

	Widget _buildCtrlItem(String title, {
		String category = "",
		double subSize = 0,
		String subTitle = "",
		int maxInt = 3,
		int valFrac = 1,
		String suffix = "    ",
		CtrlType ctrlType = CtrlType.INPUT_SETTING,
		Map<bool, String> swchMapper = const {
			true: "开启", false: "关闭"
		},
		Widget ctrl
	}) {
		assert(swchMapper.isNotEmpty || ctrlType != CtrlType.SWITCH_SETTING);
		final titleTextStyle = TextStyle(color: const Color(0xFF757575), fontSize: 25 - subSize);
		final subTitleTextStyle = TextStyle(color: global.primaryColor, fontSize: 15 - subSize);
		final contentTextStyle = TextStyle(color: global.primaryColor, fontSize: 25 - subSize);
		final ctrlTextStyle = TextStyle(color: global.primaryColor, fontSize: 20 - subSize);
		final String key = "$category$title";
		final RegExp validator = RegExp("^\\d{0,$maxInt}(\\.\\d{0,$valFrac})?\$");
		if (ctrl == null) {
			switch (ctrlType) {
				case CtrlType.INPUT_SETTING:
					final TextEditingController controller = TextEditingController();
					final onClickSetting = () => setState(() {
						_settings[key] = double.parse(controller.value.text).toStringAsFixed(valFrac);
						FocusScope.of(context).requestFocus(FocusNode());
					});
					ctrl = Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
						SizedBox(width: 100 - subSize * 2, child: TextField(
							controller: controller,
							keyboardType: TextInputType.number,
							onEditingComplete: onClickSetting,
							inputFormatters: <TextInputFormatter>[
								TextInputFormatter.withFunction((
									TextEditingValue oldValue,
									TextEditingValue newValue
								) => validator.hasMatch(newValue.text) ? newValue : oldValue)
							]
						)),
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
						Switch(
							activeColor: global.primaryColor,
							value: swchMapper[true] == _settings[key],
							onChanged: (bool value) => setState(() {
								_settings[key] = swchMapper[value];
							}))
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
			SizedBox(width: 150 - subSize * 11, child: Row(
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Text(_settings[key],
						textAlign: TextAlign.center,
						style: contentTextStyle
					),
					VerticalDivider(color: Colors.white),
					Text(suffix, style: titleTextStyle)
				]
			)),
			Expanded(child: ctrl)
		]));
	}

	Widget _arcdSettingContent() => Column(children: <Widget>[
		DataCard(title: "空调参数设定", child: Padding(
			padding: EdgeInsets.symmetric(horizontal: 50),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					_buildCtrlItem("空调开关机", ctrlType: CtrlType.SWITCH_SETTING, swchMapper: {
						true: "开机", false: "关机"
					}),
					_buildCtrlItem("回风温度设定", suffix: "℃"),
					_buildCtrlItem("送风温度设定", suffix: "℃"),
					_buildCtrlItem("最小湿度设定", suffix: "%"),
					_buildCtrlItem("最大湿度设定", suffix: "%"),
					_buildCtrlItem("回风高温告警", suffix: "℃"),
					_buildCtrlItem("送风高温告警", suffix: "℃"),
					_buildCtrlItem("送风低温告警", suffix: "℃"),
					_buildCtrlItem("回风高湿告警", suffix: "%"),
					_buildCtrlItem("回风低湿告警", suffix: "%"),
				]
			)
		))
	]);

	Widget _buildBatteryChangeInterval() {
		final TextStyle titleTextStyle = TextStyle(fontSize: 25, color: const Color(0xFF757575));
		final TextStyle subTtlTextStyle = TextStyle(fontSize: 20, color: const Color(0xFF757575));
		final TextStyle contentTextStyle = TextStyle(fontSize: 20, color: global.primaryColor);
		final TextEditingController yearCtrl = TextEditingController();
		final TextEditingController monthCtrl = TextEditingController();
		final TextEditingController dayCtrl = TextEditingController();
		return Expanded(flex: 3, child: Padding(
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
							Expanded(child: Text(
								_settings["电池跟换间隔"].substring(0, 2),
								textAlign: TextAlign.center,
								style: contentTextStyle
							)),
							Expanded(child: Text(
								_settings["电池跟换间隔"].substring(2, 4),
								textAlign: TextAlign.center,
								style: contentTextStyle
							)),
							Expanded(child: Text(
								_settings["电池跟换间隔"].substring(4, 6),
								textAlign: TextAlign.center,
								style: contentTextStyle
							)),
						])
					]
				),
				Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Expanded(child: TextField(
							controller: yearCtrl,
							keyboardType: TextInputType.number,
							maxLength: 2,
						)),
						Padding(
							padding: EdgeInsets.symmetric(horizontal: 20),
							child: Text("-", style: titleTextStyle)
						),
						Expanded(child: TextField(
							controller: monthCtrl,
							keyboardType: TextInputType.number,
							maxLength: 2,
						)),
						Padding(
							padding: EdgeInsets.symmetric(horizontal: 20),
							child: Text("-", style: titleTextStyle)
						),
						Expanded(child: TextField(
							controller: dayCtrl,
							keyboardType: TextInputType.number,
							maxLength: 2,
						)),
					]
				)),
				Padding(padding: EdgeInsets.only(
					top: 10, left: 40, right: 40
				), child: Row(children: <Widget>[
					Expanded(child: OutlineButton(
						borderSide: BorderSide(color: global.primaryColor),
						child: Text("设定", style: TextStyle(
							color: global.primaryColor,
							fontSize: 20
						)),
						onPressed: () => setState(() {
							if (yearCtrl.value.text.isNotEmpty) {
								_settings["电池跟换间隔"] = yearCtrl.value.text + _settings["电池跟换间隔"].substring(2);
							}
							if (monthCtrl.value.text.isNotEmpty) {
								_settings["电池跟换间隔"] = _settings["电池跟换间隔"].substring(0, 2)
									+ monthCtrl.value.text + _settings["电池跟换间隔"].substring(4);
							}
							if (dayCtrl.value.text.isNotEmpty) {
								_settings["电池跟换间隔"] = _settings["电池跟换间隔"].substring(0, 4) + dayCtrl.value.text;
							}
						})
					))
				]))
			])
		));
	}

	Widget _upsSettingContent() => Row(children: <Widget>[
		DataCard(title: "UPS", flex: 2, child: Padding(
			padding: EdgeInsets.symmetric(horizontal: 20),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					_buildCtrlItem("蜂鸣器开启", ctrlType: CtrlType.SWITCH_SETTING),
					_buildCtrlItem("旁路禁止使能", ctrlType: CtrlType.SWITCH_SETTING, swchMapper: {
						true: "是", false: "否"
					}),
					_buildCtrlItem("关闭时使能旁路", ctrlType: CtrlType.SWITCH_SETTING, swchMapper: {
						true: "是", false: "否"
					}),
					_buildCtrlItem("高效模式使能", ctrlType: CtrlType.SWITCH_SETTING, swchMapper: {
						true: "是", false: "否"
					}),
					_buildCtrlItem("旁路高切换电压",
						subTitle: "(253、231、242、264)",
						maxInt: 3,
						valFrac: 2,
						suffix: "V",
						ctrlType: CtrlType.INPUT_SETTING
					),
					_buildCtrlItem("旁路低切换电压",
						subTitle: "(187、176、165、154)",
						maxInt: 3,
						valFrac: 2,
						suffix: "V",
						ctrlType: CtrlType.INPUT_SETTING
					),
					_buildCtrlItem("高效模式电压上限",
						maxInt: 3,
						valFrac: 2,
						suffix: "V",
						ctrlType: CtrlType.INPUT_SETTING
					),
					_buildCtrlItem("高效模式电压下限",
						maxInt: 3,
						valFrac: 2,
						suffix: "V",
						ctrlType: CtrlType.INPUT_SETTING
					),
				]
			)
		)),
		Expanded(child: Column(children: <Widget>[
			DataCard(title: "UPS电池", flex: 2, child: Column(children: <Widget>[
				_buildCtrlItem("电池AH数设置", subSize: 8, valFrac: 0),
				_buildCtrlItem("电池并联组数", subSize: 8, valFrac: 0),
				_buildBatteryChangeInterval()
			])),
			DataCard(title: "UPS紧急开关机", child: Row(children: <Widget>[
				_buildCtrlItem("UPS状态", ctrlType: CtrlType.SWITCH_SETTING, swchMapper: {
					true: "在线模式", false: "离线模式"
				})
			])),
		]),)
	]);

	Widget _envSettingContent() => Column(children: <Widget>[
		Expanded(child: Row(children: <Widget>[
			DataCard(title: "微环境冷通道", child: Column(children: <Widget>[
				_buildCtrlItem("高温报警值", category: "冷通道"),
				_buildCtrlItem("低温报警值", category: "冷通道"),
				_buildCtrlItem("高湿报警值", category: "冷通道"),
			])),
			DataCard(title: "微环境热通道", child: Column(children: <Widget>[
				_buildCtrlItem("高温报警值", category: "热通道"),
				_buildCtrlItem("低温报警值", category: "热通道"),
				_buildCtrlItem("高湿报警值", category: "热通道"),
			]))
		])),
		DataCard(title: "应急风扇控制", child: Column(children: <Widget>[
			_buildCtrlItem("风扇状态", ctrlType: CtrlType.SWITCH_SETTING),
			_buildCtrlItem("风扇启动温度"),
			_buildCtrlItem("风扇停止温度"),
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
		var stgBtns = _settingTabs.values.toList();
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

	GlobalKey globalKey = GlobalKey();

	@override
	Widget build(BuildContext context) {
		Widget content = _settingTabs[_selSetting].func();
		double height = 0.0;
		if (globalKey.currentContext != null) {
			RenderBox rb = globalKey.currentContext.findRenderObject();
			height += rb.localToGlobal(Offset.zero).dy;
			height += rb.size.height;
		}
		return Column(children: <Widget>[
			Row(mainAxisAlignment: MainAxisAlignment.center, children: _genSettingBtns()),
			Divider(key: globalKey),
			Expanded(child: SingleChildScrollView(child: SizedBox(
				height: MediaQuery.of(context).size.height - height,
				child: GestureDetector(child: content, onTap: () {
					FocusScope.of(context).requestFocus(FocusNode());
				})
			)))
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