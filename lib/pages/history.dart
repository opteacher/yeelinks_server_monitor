import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:yeelinks/async.dart';
import 'package:yeelinks/components.dart';
import '../global.dart' as global;

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
	Map<String, List<Device>> _devices;
	String _selType = "选择设备类型";

	@override
	void initState() {
		super.initState();
		global.refreshTimer.register("listDevicesOfHistory", TimerJob(getDevList, hdlDevices, {
			TimerJob.PAGE_IDEN: pageId()
		}));
	}

	@override
	Widget build(BuildContext context) {
		final primaryColor = Theme.of(context).primaryColor;
		return Container(
			padding: const EdgeInsets.all(2.5),
			child: Column(children: <Widget>[
				Row(children: <Widget>[
					Expanded(child: Container(
						padding: EdgeInsets.symmetric(vertical: 8),
						color: primaryColor,
						child: Center(child: Text("历史警告", style: TextStyle(color: Colors.white))),
					)),
					Expanded(child: OutlineButton(
						borderSide: BorderSide(color: primaryColor),
						textColor: primaryColor,
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
								child: Text(_selType),
								onPressed: () async {
									switch (await showDialog<global.ConfirmCancel>(
										context: context,
										builder: (BuildContext context) => SimpleDialog(children: <Widget>[
											ListView(children: _devices.keys.map<Widget>((tname) => ListTile(
												title: Text(tname),
												onTap: () {
													Navigator.pop(context);
													Toast.show(tname, context);
												}
											)).toList())
										])
									)) {
										case global.ConfirmCancel.CONFIRMED:
											break;
										case global.ConfirmCancel.CANCELED:
										default:
									}
								}))
						]),
						Expanded(child: Container(
							padding: EdgeInsets.all(5),
							decoration: BoxDecoration(
								border: Border.all(color: Theme.of(context).primaryColor)
							),
							child: ListView(children: _selType != "选择设备类型" ? _devices[_selType].map<Widget>((device) => FlatButton(
								color: Theme.of(context).primaryColor,
								textColor: Colors.white,
								child: Text(device.name),
								onPressed: () {})
							).toList() : [])
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
	}

	@override
	String pageId() => "history";

	@override
	void hdlDevices(data) => setState(() {
		_devices.clear();
		for (Device device in data) {
			_devices[device.typeStr].add(device);
		}
	});

	@override
	void hdlPointVals(dynamic data) {

	}
}