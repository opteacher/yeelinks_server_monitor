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
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(2.5), child: Row(children: <Widget>[
		Expanded(child: Container(margin: EdgeInsets.all(3.5), decoration: BoxDecoration(
			border: Border.all(color: Theme.of(context).primaryColor)
		), child: ListView(children: <Widget>[

		]))),
		Expanded(flex: 4, child: Column(children: <Widget>[
			DataCard(title: "主路输入", child: Padding(padding: EdgeInsets.all(20), child: Row(children: <Widget>[
				Expanded(child: Padding(padding: EdgeInsets.only(top: 10), child: Instrument(radius: 120.0, numScales: 10, max: 260.0, maxScale: 208.0))),
				VerticalDivider(width: 50),
				Expanded(child: Padding(padding: EdgeInsets.only(top: 10), child: Instrument(radius: 120.0, numScales: 8, max: 32.0, maxScale: 26.0))),
				VerticalDivider(width: 50),
				Expanded(child: Column(children: <Widget>[
					DescListItem(
						DescListItemTitle("有功功率"),
						DescListItemContent(_subVals["主路输入-有功功率"], horizontal: 50.0, blocked: true)
					),
					DescListItem(
						DescListItemTitle("有功电能"),
						DescListItemContent(_subVals["主路输入-有功电能"], horizontal: 50.0, blocked: true)
					),
					DescListItem(
						DescListItemTitle("功率因素"),
						DescListItemContent(_subVals["主路输入-功率因素"], horizontal: 50.0, blocked: true)
					),
					DescListItem(
						DescListItemTitle("输入频率"),
						DescListItemContent(_subVals["主路输入-频率"], horizontal: 50.0, blocked: true)
					),
				]))
			]))),
			DataCard(title: "PDU", tailing: Row(children: <Widget>[
				OutlineButton(
					child: Text("PDU1#", style: TextStyle(color: Colors.grey[600])),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(4))),
					onPressed: () {}),
				OutlineButton(
					child: Text("PDU2#", style: TextStyle(color: Colors.grey[600])),
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(4))),
					onPressed: () {})
			]), child: Row(children: <Widget>[
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
		]))
	]));

	String getCompId(String name) {
		return "";
	}

//	@override
//	void collectData(dynamic data) {
//		String mainCode = getCompId("市电输入");
//		String pduCode = getCompId("PDU");
//		resetValues();
//		for (var name in values.keys) {
//			var pointId = global.protocolMapper[name];
//			if (pointId == null) {
//				continue;
//			}
//			setState(() {
//				for (var val in data["sensors"]) {
//					if (val.pointId != pointId) {
//						continue;
//					}
//					if (val.compId == mainCode) {
//						_subVals["主路输入-$name"] = val.value;
//					}
//					if (val.compId == pduCode) {
//						_subVals["PDU-$name"] = val.value;
//					}
//				}
//			});
//		}
//		print(_subVals);
//	}

	@override
	String pageId() => "electron";

	@override
	void hdlDevices(data) {
		print(data);
	}
}