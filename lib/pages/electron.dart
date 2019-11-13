import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => ElectronPageState();
}

class ElectronPageState extends BasePageState<Page> {
	List<Device> _pdus = [];
	String _mainEleID = "";
	Map<String, String> _eleVals = {
		"电压": "0.0",
		"电流": "0.0",
		"有功功率": "0.0",
		"有功电能": "0.0",
		"功率因数": "0.0",
		"输入频率": "0.0"
	};
	Map<String, String> _pduVals = {
		"PDU-输出电压": "0.0",
		"PDU-输出电流": "0.0",
		"PDU-有功功率": "0.0",
		"PDU-功率因数": "0.0",
		"PDU-输出频率": "0.0",
		"PDU-有功电能": "0.0"
	};

	@override
	Widget build(BuildContext context) => Column(children: <Widget>[
		DataCard(title: "市电输入", tailing: IconButton(
			icon: Icon(Icons.info_outline, color: global.primaryColor),
			onPressed: () => setState(() {})
		), child: Column(children: <Widget>[
			Expanded(child: Padding(padding: EdgeInsets.all(20), child: Row(children: <Widget>[
				Expanded(child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
							Instrument(
								radius: 120.0,
								numScales: 10,
								max: 300.0,
								scalesColor: {
									Offset(0, 180): Colors.grey,
									Offset(240, 300): Colors.red
								},
								value: double.parse("0.0"),
								suffix: "V"
							),
							Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
								Text("AB-相电压", style: TextStyle(fontSize: 20))
							])
						]),
						VerticalDivider(color: Colors.white, width: 50),
						Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
							Instrument(
								radius: 120.0,
								numScales: 10,
								max: 300.0,
								scalesColor: {
									Offset(0, 180): Colors.grey,
									Offset(240, 300): Colors.red
								},
								value: double.parse("0.0"),
								suffix: "V"
							),
							Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
								Text("BC-相电压", style: TextStyle(fontSize: 20))
							])
						]),
						VerticalDivider(color: Colors.white, width: 50),
						Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
							Instrument(
								radius: 120.0,
								numScales: 10,
								max: 300.0,
								scalesColor: {
									Offset(0, 180): Colors.grey,
									Offset(240, 300): Colors.red
								},
								value: double.parse("0.0"),
								suffix: "V"
							),
							Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
								Text("CA-相电压", style: TextStyle(fontSize: 20))
							])
						])
					]
				)),
				Expanded(child: Row(children: <Widget>[
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("A 相电压", size: 20.0),
							DescListItemContent("-1.0", blocked: true),
							titleAlign: TextAlign.center,
							contentAlign: TextAlign.center,
							contentWidth: 200,
							suffix: DescListItemSuffix(text: "V")
						),
						DescListItem(
							DescListItemTitle("B 相电压", size: 20.0),
							DescListItemContent("-1.0", blocked: true),
							titleAlign: TextAlign.center,
							contentAlign: TextAlign.center,
							contentWidth: 200,
							suffix: DescListItemSuffix(text: "V")
						),
						DescListItem(
							DescListItemTitle("C 相电压", size: 20.0),
							DescListItemContent("-1.0", blocked: true),
							titleAlign: TextAlign.center,
							contentAlign: TextAlign.center,
							contentWidth: 200,
							suffix: DescListItemSuffix(text: "V")
						),
						DescListItem(
							DescListItemTitle("", size: 20.0),
							DescListItemContent(""),
							titleAlign: TextAlign.center,
							contentAlign: TextAlign.center,
							contentWidth: 200
						)
					])),
					VerticalDivider(color: Colors.white, width: 30),
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("有功功率", size: 20.0),
							DescListItemContent("-1.0", blocked: true),
							titleAlign: TextAlign.center,
							contentAlign: TextAlign.center,
							contentWidth: 200,
							suffix: DescListItemSuffix(text: "V")
						),
						DescListItem(
							DescListItemTitle("无功功率", size: 20.0),
							DescListItemContent("-1.0", blocked: true),
							titleAlign: TextAlign.center,
							contentAlign: TextAlign.center,
							contentWidth: 200,
							suffix: DescListItemSuffix(text: "V")
						),
						DescListItem(
							DescListItemTitle("视在功率", size: 20.0),
							DescListItemContent("-1.0", blocked: true),
							titleAlign: TextAlign.center,
							contentAlign: TextAlign.center,
							contentWidth: 200,
							suffix: DescListItemSuffix(text: "V")
						),
						DescListItem(
							DescListItemTitle("频率", size: 20.0),
							DescListItemContent("-1.0", blocked: true),
							titleAlign: TextAlign.center,
							contentAlign: TextAlign.center,
							contentWidth: 200,
							suffix: DescListItemSuffix(text: "V")
						)
					]))
				]))
			]))),
			Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
				Icon(Icons.brightness_1),
				IconButton(icon: Icon(Icons.panorama_fish_eye), onPressed: () {})
			])
		])),
		Expanded(child: Row(children: <Widget>[
			DataCard(title: "PDU", child: ListView(children: <Widget>[
				_pduListItem("PDU 1")
			])),
			DataCard(title: "配电分析", flex: 4, child: Padding(
				padding: EdgeInsets.all(5),
				child: Row(children: <Widget>[
					Expanded(child: Column(children: <Widget>[
						Text("输出电压", style: TextStyle(color: global.primaryColor, fontSize: 25)),
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
						))
					])),
					VerticalDivider(color: global.primaryColor),
					Expanded(child: Column(children: <Widget>[
						Text("输出电流", style: TextStyle(color: global.primaryColor, fontSize: 25)),
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
						))
					]))
				])
			))
		]))
	]);

	Widget _pduListItem(String name) => ListTile(title: Text(name));

	@override
	String pageId() => "electron";

	@override
	void hdlDevices(data) => setState(() {
		global.idenDevs = [];
		if (data["ele"] != null) {
			_mainEleID = Device.fromJSON(data["ele"]).id;
			global.idenDevs.add(_mainEleID);
		} else {
			_mainEleID = "";
		}

		if (data["pdu"] == null) {
			return;
		}
		_pdus = [];
		for (var pdu in data["pdu"]) {
			_pdus.add(Device.fromJSON(pdu));
		}
		if (global.currentDevID.isEmpty && _pdus.isNotEmpty) {
			global.currentDevID = _pdus[0].id;
		}
		global.idenDevs.add(global.currentDevID);
	});

	@override
	void hdlPointVals(dynamic data) => setState(() {
		if (_mainEleID.isEmpty || global.currentDevID.isEmpty) {
			return;
		}
		for (PointVal pv in data) {
			if (pv.deviceId == _mainEleID) {
				String poiName = global.protocolMapper[pv.id];
				if (_eleVals[poiName] != null) {
					_eleVals[poiName] = pv.value.toStringAsFixed(2);
				}
			} else if (pv.deviceId == global.currentDevID) {
				String poiName = global.protocolMapper[pv.id];
				if (_pduVals[poiName] != null) {
					_pduVals[poiName] = pv.value.toStringAsFixed(2);
				}
			}
		}
	});
}