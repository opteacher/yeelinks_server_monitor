import 'package:flutter/material.dart';
import 'package:yeelinks/components.dart';

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => WarningPageState();
}

class WarningPageState extends BasePageState<Page> {
	List<Map<String, String>> _warningRecords = [{
		"level": "一级",
		"name": "UPS",
		"warning": "设备通训故障",
		"meaning": "设备通训故障，链接失败",
		"start": "2019-08-30 15:39:28",
		"confirm": "",
		"confirmer": "",
		"status": "未确认"
	}];

	@override
	Widget build(BuildContext context) => Container(
		padding: const EdgeInsets.all(2.5),
		child: MyDataTable({
			"等级": MyDataHeader("level", 0.05),
			"设备": MyDataHeader("name", 0.1),
			"标题": MyDataHeader("warning", 0.15),
			"说明": MyDataHeader("meaning", 0.25),
			"生成时间": MyDataHeader("start"),
			"确认时间": MyDataHeader("confirm"),
			"确认者": MyDataHeader("confirmer", 0.1),
			"状态": MyDataHeader("status", 0.1)
		}, _warningRecords, vpadding: 5.0, isStriped: true, hasBorder: false,
			headerTxtStyle: const TextStyle(fontSize: 20.0),
			bodyTxtStyle: const TextStyle(fontSize: 20.0)
		)
	);

	@override
	String pageId() => "warning";
}