import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../async.dart';
import '../global.dart' as global;
import '../components.dart';

class HomePageState extends State<Page> {
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
					child: Column(children: <Widget>[
						Instrument(
							radius: 110.0,
							numScales: 4,
							max: 4.0,
							min: 1.0,
							scalesColor: {
								Offset(2.5, 3.25): Colors.orange,
								Offset(3.25, 4): Colors.red
							},
							value: _pue,
						),
						DescListItem(
							DescListItemTitle("总用电量", size: 20.0),
							[DescListItemContent("17.3", blocked: true, suffixText: "KW")],
							contentAlign: TextAlign.center,
							contentWidth: 120,
							horizontal: 60
						),
						DescListItem(
							DescListItemTitle("IT用电量", size: 20.0),
							[DescListItemContent("15.6", blocked: true, suffixText: "KW")],
							contentAlign: TextAlign.center,
							contentWidth: 120,
							horizontal: 60
						)
					])
				)),
				DataCard(title: "UPS运行模式", flex: 2, child: UpsRunningMod()),
				DataCard(title: "配电信息", flex: 2, child: Padding(
					padding: EdgeInsets.all(10),
					child: Column(children: <Widget>[
						Expanded(child: charts.TimeSeriesChart(
							[
								charts.Series<TimeSeriesSales, DateTime>(
									id: "Sales",
									colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
									domainFn: (TimeSeriesSales sales, _) => sales.time,
									measureFn: (TimeSeriesSales sales, _) => sales.sales,
									data: [],
								)
							],
							animate: false,
							dateTimeFactory: const charts.LocalDateTimeFactory(),
						)),

						Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("市电相电压")]),
						Expanded(child: charts.TimeSeriesChart(
							[
								charts.Series<TimeSeriesSales, DateTime>(
									id: "Sales",
									colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
									domainFn: (TimeSeriesSales sales, _) => sales.time,
									measureFn: (TimeSeriesSales sales, _) => sales.sales,
									data: [],
								)
							],
							animate: false,
							dateTimeFactory: const charts.LocalDateTimeFactory(),
						)),
						Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("UPS输出相电压")])
					])
				))
			])),
			Expanded(child: Row(children: <Widget>[
				DataCard(title: "环境信息", child: Padding(
					padding: EdgeInsets.all(10.0),
					child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("温湿度 1", size: 20.0),
							[
								DescListItemContent(
									global.values["温湿度系统-温湿度1-温度"] != null ?
									global.values["温湿度系统-温湿度1-温度"].status :
									"0.00",
									blocked: true,
									suffixText: "℃"
								),
								DescListItemContent(
									global.values["温湿度系统-温湿度1-湿度"] != null ?
									global.values["温湿度系统-温湿度1-湿度"].status :
									"0.00",
									blocked: true,
									suffixText: "%"
								)
							],
							contentAlign: TextAlign.right,
							contentWidth: 200,
							horizontal: 30,
						),
						DescListItem(
							DescListItemTitle("温湿度 2", size: 20.0),
							[
								DescListItemContent(
									global.values["温湿度系统-温湿度2-温度"] != null ?
									global.values["温湿度系统-温湿度2-温度"].status :
									"0.00",
									blocked: true,
									suffixText: "℃"
								),
								DescListItemContent(
									global.values["温湿度系统-温湿度2-湿度"] != null ?
									global.values["温湿度系统-温湿度2-湿度"].status :
									"0.00",
									blocked: true,
									suffixText: "%"
								)
							],
							contentAlign: TextAlign.right,
							contentWidth: 200,
							horizontal: 30
						),
						Expanded(child: Padding(
							padding: EdgeInsets.symmetric(horizontal: 30),
							child: Row(children: <Widget>[
								DescListItem(
									DescListItemTitle("烟感", size: 20.0),
									[DescListItemContent("未知", blocked: true)],
									contentAlign: TextAlign.center,
									contentWidth: 80
								),
								VerticalDivider(color: Colors.white, width: 20),
								DescListItem(
									DescListItemTitle("门禁", size: 20.0),
									[DescListItemContent("未知", blocked: true)],
									contentAlign: TextAlign.center,
									contentWidth: 80
								)
							])
						)),
						Expanded(child: Padding(
							padding: EdgeInsets.symmetric(horizontal: 30),
							child: Row(children: <Widget>[
								DescListItem(
									DescListItemTitle("漏水", size: 20.0),
									[DescListItemContent("未知", blocked: true)],
									contentAlign: TextAlign.center,
									contentWidth: 80
								),
								VerticalDivider(color: Colors.white, width: 20),
								DescListItem(
									DescListItemTitle("天窗", size: 20.0),
									[DescListItemContent("未知", blocked: true)],
									contentAlign: TextAlign.center,
									contentWidth: 80
								)
							])
						))
					])
				)),
				DataCard(title: "事件记录", flex: 2, child: ListView(
					padding: const EdgeInsets.all(10),
					children: eveRcdList
				)),
				DataCard(title: "通讯状态", flex: 2, child: Padding(
					padding: EdgeInsets.all(20),
					child: Column(children: <Widget>[
						Expanded(child: Row(children: <Widget>[
							_commuState("UPS", true),
							VerticalDivider(color: global.primaryColor),
							_commuState("市电", false),
							VerticalDivider(color: global.primaryColor),
							_commuState("PDU", true),
							VerticalDivider(color: global.primaryColor),
							_commuState("空调", false),
							VerticalDivider(color: global.primaryColor),
							_commuState("温湿度", false),
						])),
						Divider(color: global.primaryColor, height: 0),
						Expanded(child: Row(children: <Widget>[
							_commuState("烟感", true),
							VerticalDivider(color: global.primaryColor),
							_commuState("门禁", false),
							VerticalDivider(color: global.primaryColor),
							_commuState("漏水", true),
							VerticalDivider(color: global.primaryColor),
							_commuState("天窗", false),
							VerticalDivider(color: global.primaryColor),
							_commuState("录像机", false),
						]))
					]),
				))
			]))
		]);
	}

	Widget _commuState(String title, bool state) => Expanded(child: Container(
		child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			crossAxisAlignment: CrossAxisAlignment.center,
			children: <Widget>[
				state ? Icon(Icons.check_circle,
					color: Colors.green,
					size: 40
				) : Icon(Icons.cancel,
					color: Colors.red,
					size: 40
				),
				Divider(color: Colors.white),
				Text(title, style: TextStyle(fontSize: 20))
			]
		)
	));

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
