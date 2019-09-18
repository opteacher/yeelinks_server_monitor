import 'dart:ui';

import 'package:flutter/material.dart';
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
		"烟雾": "0",
		"水浸": "0",
		"前门": "0",
		"后门": "0"
	};
	double _load = 0.0;
	double _pue = 0.0;

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
		return Container(padding: const EdgeInsets.all(2.5), child: Column(children: <Widget>[
			Expanded(child: Row(children: <Widget>[
				DataCard(title: "PUE", child: Padding(
					padding: EdgeInsets.only(top: 20),
					child: Instrument(
						radius: 110.0,
						numScales: 4,
						max: 4.0,
						maxScale: 3.0,
						value: _pue,
					)
				)),
				DataCard(title: "UPS运行模式", child: Padding(padding: EdgeInsets.only(top: 20), child: UpsRunningMod())),
				DataCard(title: "UPS负载率", child: Padding(
					padding: EdgeInsets.only(top: 20),
					child: Instrument(
						radius: 110.0,
						numScales: 10,
						max: 120.0,
						maxScale: 96,
						suffix: "%",
						value: _load,
					)
				))
			])),
			Expanded(child: Row(children: <Widget>[
				DataCard(title: "环境信息", child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), child: Row(children: <Widget>[
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("冷通道温", size: 20.0),
							DescListItemContent(_values["冷通道温"], blocked: true),
							contentAlign: TextAlign.center
						),
						DescListItem(
							DescListItemTitle("热通道温", size: 20.0),
							DescListItemContent(_values["热通道温"], blocked: true),
							contentAlign: TextAlign.center
						),
						DescListItem(
							DescListItemTitle("烟        感", size: 20.0),
							DescListItemContent("正常", blocked: true),
							contentAlign: TextAlign.center
						),
						DescListItem(
							DescListItemTitle("前        门", size: 20.0),
							DescListItemContent("关闭", blocked: true),
							contentAlign: TextAlign.center
						),
					])),
					VerticalDivider(width: 30),
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("冷通道湿", size: 20.0),
							DescListItemContent(_values["冷通道湿"], blocked: true),
							contentAlign: TextAlign.center
						),
						DescListItem(
							DescListItemTitle("热通道湿", size: 20.0),
							DescListItemContent(_values["热通道湿"], blocked: true),
							contentAlign: TextAlign.center
						),
						DescListItem(
							DescListItemTitle("水        浸", size: 20.0),
							DescListItemContent("正常", blocked: true),
							contentAlign: TextAlign.center
						),
						DescListItem(
							DescListItemTitle("后        门", size: 20.0),
							DescListItemContent("关闭", blocked: true),
							contentAlign: TextAlign.center
						),
					]))
				]))),
				DataCard(title: "事件记录", flex: 2, child: ListView(
					padding: const EdgeInsets.all(10),
					children: eveRcdList
				))
			]))
		]));
	}

	@override
	String pageId() => "home";

	@override
	void hdlDevices(data) => setState(() {
		if (data["alarms"] != null) {
			_eventRecords = [];
			for (var alarm in data["alarms"]) {
				_eventRecords.add(EventRecord.fromJSON(alarm).toMap());
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
	});

	@override
	void hdlPointVals(dynamic data) {

	}
}
