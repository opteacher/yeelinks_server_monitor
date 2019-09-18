import 'package:flutter/material.dart';
import 'package:yeelinks/components.dart';

import '../async.dart';

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => WarningPageState();
}

class WarningPageState extends BasePageState<Page> {
	List<Map<String, String>> _warningRecords = [];

	@override
	Widget build(BuildContext context) => Container(
		margin: EdgeInsets.all(3.5),
		padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
		decoration: BoxDecoration(
			border: Border.all(color: Theme.of(context).primaryColor),
		),
		child: Column(children: <Widget>[
			MyDataTable({
				"等级": MyDataHeader("level", 0.05),
				"设备": MyDataHeader("name", 0.1),
				"标题": MyDataHeader("warning", 0.15),
				"说明": MyDataHeader("meaning", 0.25),
				"生成时间": MyDataHeader("start", 0.175),
				"确认时间": MyDataHeader("confirm", 0.175),
				"状态": MyDataHeader("status", 0.1)
			}, _warningRecords, vpadding: 5.0, isStriped: true, hasBorder: false,
				headerTxtStyle: const TextStyle(fontSize: 20.0),
				bodyTxtStyle: const TextStyle(fontSize: 20.0)
			)
		])
	);

	@override
	String pageId() => "warning";

	@override
	void hdlDevices(data) => setState(() {
		if (data["alarms"] != null) {
			_warningRecords = [];
			for (var alarm in data["alarms"]) {
				_warningRecords.add(EventRecord.fromJSON(alarm).toMap());
			}
		}
	});

	@override
	void hdlPointVals(dynamic data) {

	}
}