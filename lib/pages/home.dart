import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../async.dart';
import '../global.dart' as global;
import '../components.dart';

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends BasePageState<Page> {
	List<Map<String, String>> _eventRecords = [];
	Map<String, String> _values = {
		"冷通道温": "0.0",
		"热通道温": "0.0",
		"冷通道湿": "0.0",
		"热通道湿": "0.0",
		"烟感": "正常",
		"门禁": "关",
		"漏水": "正常",
		"防雷": "正常"
	};
	double _load = 0.0;
	double _pue = 0.0;

	@override
	void initState() {
		super.initState();
		if (!global.refreshTimer.isStarted()) {
			global.refreshTimer.start();
		}
	}

	@override
	Widget build(BuildContext context) {
		List<Widget> eveRcdList = [];
		for (var er in _eventRecords) {
			eveRcdList.add(Container(
				margin: EdgeInsets.only(bottom: 5),
				color: Colors.grey[100],
				padding: EdgeInsets.all(10),
				child: ListTile(
					leading: Icon(Icons.info, size: 50, color: Colors.blueAccent),
					title: Text("${er["name"]}--${er["meaning"]} 等级：${er["level"]}", style: TextStyle(color: Colors.grey[600], fontSize: 20)),
					trailing: Text(er["start"], style: TextStyle(color: Colors.blueAccent, fontSize: 20)),
				)
			));
		}
		return Column(children: <Widget>[
			Expanded(child: Row(children: <Widget>[
				DataCard(title: "PUE", child: Padding(
					padding: EdgeInsets.only(top: 20),
					child: Instrument(
						radius: 110.0,
						numScales: 4,
						max: 4.0,
						min: 1.0,
						scalesColor: {
							Offset(2.5, 3.25): Colors.orange,
							Offset(3.25, 4): Colors.red
						},
						value: _pue,
					)
				)),
				DataCard(title: "UPS运行模式", child: Padding(
					padding: EdgeInsets.only(top: 20),
					child: UpsRunningMod()
				)),
				DataCard(title: "UPS负载率", child: Padding(
					padding: EdgeInsets.only(top: 20),
					child: Instrument(
						radius: 110.0,
						numScales: 10,
						max: 120.0,
						scalesColor: {
							Offset(60, 78): Colors.orange,
							Offset(78, 120): Colors.red
						},
						suffix: "%",
						value: _load,
					)
				))
			])),
			Expanded(child: Row(children: <Widget>[
				DataCard(title: "环境信息", child: Padding(padding: EdgeInsets.all(10.0), child: Row(children: <Widget>[
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("冷通道温度", size: 18.0),
							DescListItemContent(_values["冷通道温"], blocked: true),
							contentAlign: TextAlign.center,
							contentWidth: 90,
							suffix: DescListItemSuffix(text: "℃")
						),
						DescListItem(
							DescListItemTitle("热通道温度", size: 18.0),
							DescListItemContent(_values["热通道温"], blocked: true),
							contentAlign: TextAlign.center,
							contentWidth: 90,
							suffix: DescListItemSuffix(text: "℃")
						),
						DescListItem(
							DescListItemTitle("烟            感", size: 18.0),
							DescListItemContent(_values["烟感"], blocked: true),
							contentAlign: TextAlign.center,
							contentWidth: 90,
						),
						DescListItem(
							DescListItemTitle("漏            水", size: 18.0),
							DescListItemContent(_values["漏水"], blocked: true),
							contentAlign: TextAlign.center,
							contentWidth: 90,
						),
					])),
					VerticalDivider(width: 15),
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("冷通道湿度", size: 18.0),
							DescListItemContent(_values["冷通道湿"], blocked: true),
							contentAlign: TextAlign.center,
							contentWidth: 90,
							suffix: DescListItemSuffix(text: "%")
						),
						DescListItem(
							DescListItemTitle("热通道湿度", size: 18.0),
							DescListItemContent(_values["热通道湿"], blocked: true),
							contentAlign: TextAlign.center,
							contentWidth: 90,
							suffix: DescListItemSuffix(text: "%")
						),
						DescListItem(
							DescListItemTitle("门            禁", size: 18.0),
							DescListItemContent(_values["门禁"], blocked: true),
							contentAlign: TextAlign.center,
							contentWidth: 90,
						),
						DescListItem(
							DescListItemTitle("防            雷", size: 18.0),
							DescListItemContent(_values["防雷"], blocked: true),
							contentAlign: TextAlign.center,
							contentWidth: 90,
						),
					]))
				]))),
				DataCard(title: "事件记录", flex: 2, child: ListView(
					padding: const EdgeInsets.all(10),
					children: eveRcdList
				))
			]))
		]);
	}

	@override
	String pageId() => "home";

	@override
	void hdlDevices(data) => setState(() {
		if (data["alarms"] != null) {
			List alarms = data["alarms"].map<EventRecord>((alarm) {
				return EventRecord.fromJSON(alarm);
			}).toList();
			bool needUpdate = true;
			if (_eventRecords.length == alarms.length) {
				needUpdate = false;
				for (int i = 0; i < alarms.length; i++) {
					if (alarms[i].id.toString() != _eventRecords[i]["id"]) {
						needUpdate = true;
						break;
					}
				}
			}
			if (needUpdate) {
				_eventRecords = [];
				for (var alarm in alarms) {
					_eventRecords.add(alarm.toMap());
				}
			}
		}
		if (data["cloud_humi"] != null) {
			_values["冷通道湿"] = data["cloud_humi"].toDouble().toStringAsFixed(2);
		}
		if (data["cloud_temp"] != null) {
			_values["冷通道温"] = data["cloud_temp"].toDouble().toStringAsFixed(2);
		}
		if (data["hot_humi"] != null) {
			_values["热通道湿"] = data["hot_humi"].toDouble().toStringAsFixed(2);
		}
		if (data["hot_temp"] != null) {
			_values["热通道温"] = data["hot_temp"].toDouble().toStringAsFixed(2);
		}
		if (data["load"] != null) {
			_load = data["load"].toDouble();
		}
		if (data["pue"] != null) {
			_pue = data["pue"].toDouble();
		}
		if (data["switcher"] != null && data["switcher"].isNotEmpty) {
			for (var swh in data["switcher"].toList()) {
				_values[swh["name"]] = swh["value"];
			}
		}
		if (data["ups_status"] != null) {
			global.upsMode = data["ups_status"];
		}
	});

	@override
	void hdlPointVals(dynamic data) {

	}
}
