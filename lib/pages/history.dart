import 'package:flutter/material.dart';
import 'package:yeelinks/components.dart';

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => HistoryPageState();
}

class HistoryPageState extends BasePageState<Page> {
	final ShapeBorder _noBorderRadius = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)));

	List<Map<String, String>> _historyRecords = [{
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
		child: Column(children: <Widget>[
			Row(children: <Widget>[
				Expanded(child: FlatButton(
					color: Theme.of(context).primaryColor,
					textColor: Colors.white,
					shape: _noBorderRadius,
					child: Text("历史警告"),
					onPressed: () {})),
				Expanded(child: OutlineButton(
					borderSide: BorderSide(color: Theme.of(context).primaryColor),
					textColor: Theme.of(context).primaryColor,
					shape: _noBorderRadius,
					child: Text("历史数据"),
					onPressed: () {}))
			]),
			Expanded(child: Row(children: <Widget>[
				Expanded(child: Column(children: <Widget>[
					Row(children: <Widget>[
						Expanded(child: OutlineButton(
							borderSide: BorderSide(color: Theme.of(context).primaryColor),
							textColor: Theme.of(context).primaryColor,
							shape: _noBorderRadius,
							child: Text("PDU"),
							onPressed: () {}))
					]),
					Expanded(child: Container(
						padding: EdgeInsets.all(5),
						decoration: BoxDecoration(
							border: Border.all(color: Theme.of(context).primaryColor)
						),
						child: ListView(children: <Widget>[
							FlatButton(
								color: Theme.of(context).primaryColor,
								textColor: Colors.white,
								child: Text("PDU#2"),
								onPressed: () {}),
							OutlineButton(
								borderSide: BorderSide(color: Theme.of(context).primaryColor),
								textColor: Theme.of(context).primaryColor,
								child: Text("PDU#1"),
								onPressed: () {}),
						])
					))
				])),
				Expanded(flex: 3, child: Column(children: <Widget>[
					Padding(padding: EdgeInsets.all(10), child: MyDataTable({
						"等级": MyDataHeader("level", 0.05),
						"设备": MyDataHeader("name", 0.1),
						"标题": MyDataHeader("warning", 0.15),
						"说明": MyDataHeader("meaning", 0.25),
						"生成时间": MyDataHeader("start"),
						"解除时间": MyDataHeader("confirm"),
						"解除者": MyDataHeader("confirmer", 0.1),
						"状态": MyDataHeader("status", 0.1)
					}, _historyRecords, vpadding: 5.0, isStriped: true, hasBorder: false,
						headerTxtStyle: const TextStyle(fontSize: 15.0),
						bodyTxtStyle: const TextStyle(fontSize: 15.0)
					))
				]))
			]))
		])
	);

	@override
	String pageId() => "history";

	@override
	void hdlDevices(data) {
		// TODO: implement hdlDevices
	}

	@override
	void hdlPointVals(dynamic data) {

	}
}