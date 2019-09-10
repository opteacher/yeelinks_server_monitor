import 'package:flutter/material.dart';
import '../async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => ElectronPageState();
}

class ElectronPageState extends BasePageState<Page> {
	Map<String, String> _subVals = {};

	ElectronPageState() {
		values = {
			"电压": "0.0",
			"电流": "0.0",
			"有功功率": "0.0",
			"功率因素": "0.0",
			"频率": "0.0",
			"有功电能": "0.0",
		};
		resetValues();
	}

	@override
	void resetValues() {
		_subVals = {
			"主路输入-电压": "0.0",
			"主路输入-电流": "0.0",
			"主路输入-有功功率": "0.0",
			"主路输入-功率因素": "0.0",
			"主路输入-频率": "0.0",
			"主路输入-有功电能": "0.0",
			"PDU-电压": "0.0",
			"PDU-电流": "0.0",
			"PDU-有功功率": "0.0",
			"PDU-功率因素": "0.0",
			"PDU-频率": "0.0",
			"PDU-有功电能": "0.0",
		};
	}

	@override
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), child: Column(children: <Widget>[
//		Row(children: <Widget>[
//			Expanded(child: Align(alignment: Alignment.centerRight, child: OutlineButton(
//				child: Text("详细信息", style: TextStyle(color: Theme.of(context).primaryColor)),
//				onPressed: () {
//					// TODO:
//				})
//			))
//		]),
		DataCard(title: "主路输入", child: Row(children: <Widget>[
			Expanded(child: Column(children: <Widget>[
				DescListItem(
					DescListItemTitle("输入电压"),
					DescListItemContent(_subVals["主路输入-电压"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "V"),
					horizontal: 50.0
				),
				DescListItem(
					DescListItemTitle("输入电流"),
					DescListItemContent(_subVals["主路输入-电流"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "A"),
					horizontal: 50.0
				),
				DescListItem(
					DescListItemTitle("有功功率"),
					DescListItemContent(_subVals["主路输入-有功功率"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "W"),
					horizontal: 50.0
				),
			])),
			Expanded(child: Column(children: <Widget>[
				DescListItem(
					DescListItemTitle("功率因素"),
					DescListItemContent(_subVals["主路输入-功率因素"], horizontal: 50.0),
					horizontal: 50.0
				),
				DescListItem(
					DescListItemTitle("输入频率"),
					DescListItemContent(_subVals["主路输入-频率"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "Hz"),
					horizontal: 50.0
				),
				DescListItem(
					DescListItemTitle("有功电能"),
					DescListItemContent(_subVals["主路输入-有功电能"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "kWh"),
					horizontal: 50.0
				),
			]))
		])),
		DataCard(title: "PDU", child: Row(children: <Widget>[
			Expanded(child: Column(children: <Widget>[
				DescListItem(
					DescListItemTitle("输出电压"),
					DescListItemContent(_subVals["PDU-电压"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "V"),
					horizontal: 50.0
				),
				DescListItem(
					DescListItemTitle("输出电流"),
					DescListItemContent(_subVals["PDU-电流"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "A"),
					horizontal: 50.0
				),
				DescListItem(
					DescListItemTitle("有功功率"),
					DescListItemContent(_subVals["PDU-有功功率"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "W"),
					horizontal: 50.0
				),
			])),
			Expanded(child: Column(children: <Widget>[
				DescListItem(
					DescListItemTitle("功率因素"),
					DescListItemContent(_subVals["PDU-功率因素"], horizontal: 50.0),
					horizontal: 50.0
				),
				DescListItem(
					DescListItemTitle("输出频率"),
					DescListItemContent(_subVals["PDU-频率"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "Hz"),
					horizontal: 50.0
				),
				DescListItem(
					DescListItemTitle("有功电能"),
					DescListItemContent(_subVals["PDU-有功电能"], horizontal: 50.0),
					suffix: DescListItemSuffix(text: "kWh"),
					horizontal: 50.0
				),
			]))
		]))
	]));

	String getCompId(String name) {
		return "";
	}

	@override
	void collectData(dynamic data) {
		String mainCode = getCompId("市电输入");
		String pduCode = getCompId("PDU");
		resetValues();
		for (var name in values.keys) {
			var pointId = global.protocolMapper[name];
			if (pointId == null) {
				continue;
			}
			setState(() {
				for (var val in data["sensors"]) {
					if (val.pointId != pointId) {
						continue;
					}
					if (val.compId == mainCode) {
						_subVals["主路输入-$name"] = val.value;
					}
					if (val.compId == pduCode) {
						_subVals["PDU-$name"] = val.value;
					}
				}
			});
		}
		print(_subVals);
	}

	@override
	String pageId() => "electron";
}