import 'package:flutter/material.dart';
import '../async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => EnvPageState();
}

class EnvPageState extends BasePageState<Page> {
	final _dividerTxtStyle = TextStyle(
		fontSize: 20,
		fontWeight: FontWeight.w900,
		color: const Color(0xFF757575)
	);
	final _envBlkPdg = const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0);
	final _envTitlePdg = const EdgeInsets.symmetric(vertical: 5, horizontal: 15);
	final _titleBtmMgn = const EdgeInsets.only(bottom: 15);

	Map<String, Device> _cloudDevs = {};
	Map<String, Device> _hotDevs = {};
	String _switcherID = "";
	Map<String, String> _switcher = {
		"防雷": "正常",
		"门禁": "关",
		"漏水": "正常",
		"烟感": "正常"
	};

	@override
	Widget build(BuildContext context) => Column(children: <Widget>[
		DataCard(title: "温湿度", flex: 2, tailing: IconButton(
			icon: Icon(Icons.keyboard_arrow_down, color: global.primaryColor),
			onPressed: () => setState(() {})
		), child: Padding(
			padding: EdgeInsets.symmetric(vertical: 20),
			child: Row(children: <Widget>[
				_humiTempItem("温湿度1"),
				VerticalDivider(color: global.primaryColor),
				_humiTempItem("温湿度2")
			])
		)),
		DataCard(title: "烟感", tailing: IconButton(
			icon: Icon(Icons.keyboard_arrow_down, color: global.primaryColor),
			onPressed: () => setState(() {})
		), child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: <Widget>[
			_infoItem("烟感1"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("烟感2"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("烟感3"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("烟感4"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("烟感5"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("烟感6"),
		]))),
		DataCard(title: "门禁", tailing: IconButton(
			icon: Icon(Icons.keyboard_arrow_down, color: global.primaryColor),
			onPressed: () => setState(() {})
		), child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: <Widget>[
			_infoItem("前门", desc: "未知"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("后门", desc: "未知"),
		]))),
		DataCard(title: "漏水", tailing: IconButton(
			icon: Icon(Icons.keyboard_arrow_down, color: global.primaryColor),
			onPressed: () => setState(() {})
		), child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: <Widget>[
			_infoItem("漏水1"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("漏水2"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("漏水3"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("漏水4"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("漏水5"),
			VerticalDivider(color: global.primaryColor),
			_infoItem("漏水6"),
		]))),
		DataCard(title: "天窗", tailing: IconButton(
			icon: Icon(Icons.keyboard_arrow_down, color: global.primaryColor),
			onPressed: () => setState(() {})
		), child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: <Widget>[
			_infoItem("天窗1", ctrl: Row(children: <Widget>[
				Switch(value: false, onChanged: (value) {}), Text("关闭")
			])),
			VerticalDivider(color: global.primaryColor),
			_infoItem("天窗2", ctrl: Row(children: <Widget>[
				Switch(value: false, onChanged: (value) {}), Text("关闭")
			])),
			VerticalDivider(color: global.primaryColor),
			_infoItem("天窗3", ctrl: Row(children: <Widget>[
				Switch(value: false, onChanged: (value) {}), Text("关闭")
			])),
			VerticalDivider(color: global.primaryColor),
			_infoItem("天窗4", ctrl: Row(children: <Widget>[
				Switch(value: false, onChanged: (value) {}), Text("关闭")
			]))
		])))
	]);

	Widget _humiTempItem(String name) => Expanded(child: Column(children: <Widget>[
		Text(name),
		Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
			Instrument(
				radius: 100.0,
				numScales: 10,
				max: 300.0,
				scalesColor: {
					Offset(0, 180): Colors.grey,
					Offset(240, 300): Colors.red
				},
				value: double.parse("0.0"),
				suffix: "V"
			),
			VerticalDivider(color: Colors.white, width: 30),
			Instrument(
				radius: 100.0,
				numScales: 10,
				max: 300.0,
				scalesColor: {
					Offset(0, 180): Colors.grey,
					Offset(240, 300): Colors.red
				},
				value: double.parse("0.0"),
				suffix: "V"
			)
		])
	]));

	Widget _infoItem(String name, {
		bool state = false,
		String desc = "",
		Widget ctrl
	}) {
		if (ctrl == null) {
			if (desc.isNotEmpty) {
				ctrl = Text(desc);
			} else {
				ctrl = Icon(Icons.lens, color: (state
					? Colors.green
					: Colors.red
				));
			}
		}
		return Expanded(child: Row(
			mainAxisAlignment: MainAxisAlignment.center,
			children: <Widget>[
				Text(name),
				VerticalDivider(color: Colors.white),
				ctrl
			]
		));
	}

	List<Widget> _genHumiTempCard(List<Device> devices) => devices.map<Widget>((dev) {
		Widget titleBar;
		if (global.currentDevID.isNotEmpty && global.currentDevID == dev.id) {
			titleBar = FlatButton(padding: EdgeInsets.all(0), child: ListTile(
				title: Text(dev.name, style: _dividerTxtStyle),
				trailing: Icon(Icons.check_circle, color: global.primaryColor)
			), disabledColor: Colors.grey[100], onPressed: null);
		} else {
			titleBar = FlatButton(padding: EdgeInsets.all(0), child: ListTile(
				title: Text(dev.name, style: _dividerTxtStyle)
			), color: Colors.grey[100], onPressed: () => setState(() {
				global.refreshTimer.refresh(context, dev.id, null);
			}));
		}
		return Container(margin: EdgeInsets.only(bottom: 50), child: Column(children: <Widget>[
			titleBar,
			Container(margin: EdgeInsets.only(top: 10), child: Row(children: <Widget>[
				DescListItem(
					DescListItemTitle("温度", size: 20.0),
					[DescListItemContent(dev.temp.toStringAsFixed(1), blocked: true, suffixText: "℃")],
					contentAlign: TextAlign.center,
					contentWidth: 80
				),
				VerticalDivider(width: 5),
				DescListItem(
					DescListItemTitle("湿度", size: 20.0),
					[DescListItemContent(dev.humi.toStringAsFixed(1), blocked: true, suffixText: "%")],
					contentAlign: TextAlign.center,
					contentWidth: 80
				)
			])),
		]));
	}).toList();

	@override
	String pageId() => "env";

	@override
	void hdlDevices(data) => setState(() {
		if (data["cloud_ch"] != null) {
			_cloudDevs = {};
			for (var devData in data["cloud_ch"]) {
				var device = Device.fromJSON(devData);
				_cloudDevs[device.id] = device;
			}
		}
		if (data["hot_ch"] != null) {
			_hotDevs = {};
			for (var devData in data["hot_ch"]) {
				var device = Device.fromJSON(devData);
				_hotDevs[device.id] = device;
			}
		}
		if (data["switcher"] != null && data["switcher"].isNotEmpty) {
			_switcherID = Device.fromJSON(data["switcher"][0]).id;
		}
		if (global.currentDevID.isEmpty) {
			if (_cloudDevs.isNotEmpty) {
				global.currentDevID = _cloudDevs.keys.first;
			} else if (_hotDevs.isNotEmpty) {
				global.currentDevID = _hotDevs.keys.first;
			}
		}
		global.idenDevs = [];
		global.idenDevs.addAll(_cloudDevs.keys);
		global.idenDevs.addAll(_hotDevs.keys);
		if (_switcherID.isNotEmpty) {
			global.idenDevs.add(_switcherID);
		}
	});

	@override
	void hdlPointVals(dynamic data) => setState(() {
		for (PointVal pv in data) {
			if (_cloudDevs[pv.deviceId] != null) {
				if (global.protocolMapper[pv.id] == "冷通道温度") {
					_cloudDevs[pv.deviceId].temp = pv.value;
				} else if (global.protocolMapper[pv.id] == "冷通道湿度") {
					_cloudDevs[pv.deviceId].humi = pv.value;
				}
			}
			if (_hotDevs[pv.deviceId] != null) {
				if (global.protocolMapper[pv.id] == "热通道温度") {
					_hotDevs[pv.deviceId].temp = pv.value;
				} else if (global.protocolMapper[pv.id] == "热通道湿度") {
					_hotDevs[pv.deviceId].humi = pv.value;
				}
			}
			if (_switcherID == pv.deviceId) {
				String poiName = global.protocolMapper[pv.id];
				if (_switcher[poiName] != null) {
					_switcher[poiName] = pv.desc != null ? pv.desc : pv.value.toStringAsFixed(1);
				}
			}
		}
	});
}