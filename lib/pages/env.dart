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
		"前门": "关",
		"后门": "关",
		"水浸": "正常",
		"烟雾": "正常"
	};

	@override
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(2.5), child: Row(children: <Widget>[
		Expanded(child: Column(children: <Widget>[
			DataCard(title: "冷通道环境", child: Padding(padding: _envBlkPdg,
				child: Column(children: _genHumiTempCard(_cloudDevs.values.toList()))
			))
		])),
		Expanded(flex: 2, child: Column(children: <Widget>[
			DataCard(title: "历史曲线", child: SimpleTimeSeriesChart()),
			DataCard(title: "机柜状态", height: 200, child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: <Widget>[
				Expanded(child: Column(children: <Widget>[
					Text("前门"), RaisedButton(elevation: 0, onPressed: () {}, child: Text(_switcher["前门"]))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("后门"), RaisedButton(elevation: 0, onPressed: () {}, child: Text(_switcher["后门"]))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("水浸"), RaisedButton(elevation: 0, onPressed: () {}, child: Text(_switcher["水浸"]))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("烟感"), RaisedButton(elevation: 0, onPressed: () {}, child: Text(_switcher["烟雾"]))
				])),
				VerticalDivider()
			])))
		])),
		Expanded(child: Column(children: <Widget>[
			DataCard(title: "热通道环境", child: Padding(padding: _envBlkPdg,
				child: Column(children: _genHumiTempCard(_hotDevs.values.toList()))
			))
		])),
	]));

	List<Widget> _genHumiTempCard(List<Device> devices) => devices.map<Widget>((dev) {
		Widget titleBar;
		if (global.currentDevID.isNotEmpty && global.currentDevID == dev.id) {
			titleBar = FlatButton(padding: EdgeInsets.all(0), child: ListTile(
				title: Text(dev.name, style: _dividerTxtStyle),
				trailing: Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
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
					DescListItemContent(dev.temp.toStringAsFixed(1), blocked: true),
					contentAlign: TextAlign.center,
					suffix: DescListItemSuffix(text: "℃")
				),
				VerticalDivider(width: 5),
				DescListItem(
					DescListItemTitle("湿度", size: 20.0),
					DescListItemContent(dev.humi.toStringAsFixed(1), blocked: true),
					contentAlign: TextAlign.center,
					suffix: DescListItemSuffix(text: "%")
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
					_switcher[poiName] = pv.value != 0 ? "开" : "关";
				}
			}
		}
	});
}