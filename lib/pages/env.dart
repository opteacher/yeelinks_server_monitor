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
	String _selDevID = "";
	String _switcherID = "";

	@override
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(2.5), child: Row(children: <Widget>[
		Expanded(child: Column(children: <Widget>[
			DataCard(title: "冷通道环境", child: Padding(padding: _envBlkPdg,
				child: Column(children: _genHumiTempCard(_cloudDevs.values.toList()))
			))
		])),
		Expanded(flex: 2, child: Column(children: <Widget>[
			DataCard(title: "温度曲线", child: SimpleTimeSeriesChart("温度", "20479254")),
			DataCard(title: "湿度曲线", child: SimpleTimeSeriesChart("湿度", "20361980")),
			DataCard(title: "机柜状态", height: 200, child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: <Widget>[
				Expanded(child: Column(children: <Widget>[
					Text("前门"), RaisedButton(elevation: 0, onPressed: () {}, child: Text("开启"))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("后门"), RaisedButton(elevation: 0, onPressed: () {}, child: Text("开启"))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("水浸"), RaisedButton(elevation: 0, onPressed: () {}, child: Text("正常"))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("烟感"), RaisedButton(elevation: 0, onPressed: () {}, child: Text("异常", style: TextStyle(color: Colors.orangeAccent)))
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
		if (_selDevID.isNotEmpty && _selDevID == dev.id) {
			titleBar = FlatButton(padding: EdgeInsets.all(0), child: ListTile(
				title: Text(dev.name, style: _dividerTxtStyle),
				trailing: Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
			), disabledColor: Colors.grey[100], onPressed: null);
		} else {
			titleBar = FlatButton(padding: EdgeInsets.all(0), child: ListTile(
				title: Text(dev.name, style: _dividerTxtStyle)
			), color: Colors.grey[100], onPressed: () => setState(() {
				_selDevID = dev.id;
			}));
		}
		return Container(margin: EdgeInsets.only(bottom: 50), child: Column(children: <Widget>[
			titleBar,
			Container(margin: EdgeInsets.only(top: 10), child: Row(children: <Widget>[
				DescListItem(
					DescListItemTitle("温度", size: 20.0),
					DescListItemContent(dev.temp.toStringAsFixed(2), blocked: true),
					contentAlign: TextAlign.center
				),
				VerticalDivider(width: 10),
				DescListItem(
					DescListItemTitle("湿度", size: 20.0),
					DescListItemContent(dev.humi.toStringAsFixed(2), blocked: true),
					contentAlign: TextAlign.center
				)
			])),
		]));
	}).toList();

	@override
	String pageId() => "env";

	@override
	void hdlDevices(data) {
		setState(() {
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
		});
		if (_selDevID.isEmpty) {
			if (_cloudDevs.isNotEmpty) {
				_selDevID = _cloudDevs.keys.first;
			} else if (_hotDevs.isNotEmpty) {
				_selDevID = _hotDevs.keys.first;
			}
		}
		global.idenDevs = [];
		global.idenDevs.addAll(_cloudDevs.keys);
		global.idenDevs.addAll(_hotDevs.keys);
		if (_switcherID.isNotEmpty) {
			global.idenDevs.add(_switcherID);
		}
	}

	@override
	void hdlPointVals(dynamic data) => setState(() {
		for (PointVal pv in data) {
			if (_cloudDevs[pv.deviceId] != null) {
				if (pv.id == "15285839") {
					_cloudDevs[pv.deviceId].temp = pv.value;
				} else if (pv.id == "15039855") {
					_cloudDevs[pv.deviceId].humi = pv.value;
				}
			}
			if (_hotDevs[pv.deviceId] != null) {
				if (pv.id == "15285839") {
					_hotDevs[pv.deviceId].temp = pv.value;
				} else {
					_hotDevs[pv.deviceId].humi = pv.value;
				}
			}
			if (_switcherID == pv.deviceId) {
				// TODO:
			}
		}
	});
}