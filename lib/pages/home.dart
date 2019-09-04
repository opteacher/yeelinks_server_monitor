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

	HomePageState() {
		values = {
			"温度": "0.0",
			"湿度": "0.0",
			"烟雾": "0",
			"水浸": "0",
			"前门": "0",
			"后门": "0",
		};
	}

	@override
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(2.5), child: Column(children: <Widget>[
		Expanded(child: Row(children: <Widget>[
			DataCard(title: "PUE", child: Instrument(radius: 90.0, numScales: 4, max: 4.0, maxScale: 3.0)),
			DataCard(title: "UPS运行模式", child: Center(child: Image.asset("images/ups_run_mode.png"))),
			DataCard(title: "UPS负载率", child: Instrument(radius: 90.0, numScales: 10, max: 120.0, suffix: "%"))
		])),
		Expanded(child: Row(children: <Widget>[
			DataCard(title: "环境信息", child: Row(children: <Widget>[
				Expanded(child: Padding(padding: EdgeInsets.only(right: 20.0, left: 10.0), child: Column(children: <Widget>[
					DescListItem(
						DescListItemTitle("温度", size: 25.0),
						DescListItemContent(values["温度"], right: 5.0),
						suffix: DescListItemSuffix(text: "°C"),
						contentAlign: TextAlign.right
					),
					DescListItem(
						DescListItemTitle("烟雾", size: 25.0),
						DescListItemContent(values["烟雾"]),
						contentAlign: TextAlign.right
					),
					DescListItem(
						DescListItemTitle("前门", size: 25.0),
						DescListItemContent(values["前门"], color: Colors.redAccent),
						contentAlign: TextAlign.right
					),
				]))),
				VerticalDivider(),
				Expanded(child: Padding(padding: EdgeInsets.only(right: 20.0), child: Column(children: <Widget>[
					DescListItem(
						DescListItemTitle("湿度", size: 25.0),
						DescListItemContent(values["湿度"], right: 5.0),
						suffix: DescListItemSuffix(text: "%"),
						contentAlign: TextAlign.right
					),
					DescListItem(
						DescListItemTitle("水浸", size: 25.0),
						DescListItemContent(values["水浸"]),
						contentAlign: TextAlign.right
					),
					DescListItem(
						DescListItemTitle("后门", size: 25.0),
						DescListItemContent(values["后门"], color: Colors.redAccent),
						contentAlign: TextAlign.right
					),
				])))
			])),
			DataCard(title: "事件记录", flex: 2, child: MyDataTable({
				"设备名称": MyDataHeader("name", 0.15),
				"告警名称": MyDataHeader("warning"),
				"告警含义": MyDataHeader("meaning", 0.3),
				"级别": MyDataHeader("level", 0.1),
				"开始时刻": MyDataHeader("start", 0.25)
			}, _eventRecords, vpadding: 5.0, isStriped: true, hasBorder: false,
				headerTxtStyle: const TextStyle(fontSize: 15.0),
				bodyTxtStyle: const TextStyle(fontSize: 15.0, color: Colors.redAccent)
			))
		]))
	]));

	@override
	void subColData(dynamic data) {
		setState(() {
			_eventRecords = [];
			for (EventRecord er in data["alarms"].toList().cast<EventRecord>()) {
				_eventRecords.add(er.toMap());
			}
		});
	}

	@override
	String pageId() => "home";
}
