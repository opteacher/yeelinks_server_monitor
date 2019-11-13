import 'package:flutter/material.dart';
import 'package:yeelinks/async.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => UpsPageState();
}

class UpsPageState extends BasePageState<Page> {
	final _infoPdg = const EdgeInsets.symmetric(vertical: 10, horizontal: 15);
	final Map<double, String> _modMap = {
		20480: "开机模式",
		21248: "待机模式",
		22784: "旁路模式",
		19456: "在线模式",
		16896: "电池模式",
		21504: "电池测试模式",
		17920: "故障模式",
		17664: "HE/ECO",
		17152: "转换器模式",
		17408: "关机"
	};

	bool _showDetail = false;
	Map<String, String> _values = {
		"UPS负载率": "0.0",
		"输入电压": "0.0",
		"输入频率": "0.0",
		"输出电压": "0.0",
		"输出电流": "0.0",
		"输出频率": "0.0",
		"运行模式": "未知模式",
		"电池容量": "0.0",
		"电池剩余时间": "0",
		"电池电压": "0.0",
		"电池电流": "0.0",
		"电池电量不足": "0",
		"过载": "未知",
		"低电池电压": "未知",
		"电池过充": "未知",

		"电池开启": "0",
		"旁路功率不稳定": "0",
		"EEPROM错误": "0",
		"输出过载": "0",
		"根据用户指令，UPS准备好供电": "0",
		"已准备供电": "0",
		"电池电量不足": "0",
		"电池模式": "0",
		"在线模式": "0",
		"输出电压不良": "0"
	};

	@override
	Widget build(BuildContext context) {
		var data = _genTempData();
		data[0]["input"] = data[0]["input"].replaceFirst("{data}", _values["输入电压"]);
		data[0]["output"] = data[0]["output"].replaceFirst("{data}", _values["输出电压"]);
		data[0]["battery"] = data[0]["battery"].replaceFirst("{data}", _values["电池电压"]);
		data[0]["others"] = data[0]["others"].replaceFirst("{data}", _values["过载"]);
		data[1]["output"] = data[1]["output"].replaceFirst("{data}", _values["输出电流"]);
		data[1]["battery"] = data[1]["battery"].replaceFirst("{data}", _values["电池电流"]);
		data[1]["others"] = data[1]["others"].replaceFirst("{data}", _values["低电池电压"]);
		data[2]["input"] = data[2]["input"].replaceFirst("{data}", _values["输入频率"]);
		data[2]["output"] = data[2]["output"].replaceFirst("{data}", _values["输出频率"]);
		data[2]["battery"] = data[2]["battery"].replaceFirst("{data}", _values["电池电量不足"]);
		data[2]["others"] = data[2]["others"].replaceFirst("{data}", _values["电池过充"]);

		return Column(children: <Widget>[
			Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
				FlatButton(
					child: Text("UPS 1", style: TextStyle(color: Colors.white)),
					disabledColor: global.primaryColor,
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.all(Radius.zero),
					),
					onPressed: null
				),
				OutlineButton(
					child: Text("UPS 2", style: TextStyle(color: global.primaryColor)),
					borderSide: BorderSide(color: global.primaryColor),
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.all(Radius.zero),
					),
					onPressed: () => setState(() {})
				)
			]),
			Expanded(child: Row(children: <Widget>[
				DataCard(title: "输入", child: Padding(
					padding: EdgeInsets.all(10),
					child: Row(children: <Widget>[
						Expanded(child: Column(children: <Widget>[
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
							Text("相电压")
						])),
						Expanded(child: Column(children: <Widget>[
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
							Text("相电流")
						]))
					])
				)),
				DataCard(title: "旁路", child: Padding(
					padding: EdgeInsets.all(10),
					child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
						Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
							Instrument(
								radius: 100.0,
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
								Text("A-相电压", style: TextStyle(fontSize: 20))
							])
						])),
						Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
							Instrument(
								radius: 100.0,
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
								Text("B-相电压", style: TextStyle(fontSize: 20))
							])
						])),
						Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
							Instrument(
								radius: 100.0,
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
								Text("C-相电压", style: TextStyle(fontSize: 20))
							])
						]))
					])
				))
			])),
			Expanded(flex: 2, child: Row(children: <Widget>[
				DataCard(title: "输出", flex: 2, child: Padding(
					padding: EdgeInsets.all(10),
					child: Row(children: <Widget>[])
				)),
				DataCard(title: "电池", child: Padding(
					padding: EdgeInsets.all(10),
					child: Row(children: <Widget>[])
				)),
				DataCard(title: "状态", child: Padding(
					padding: EdgeInsets.all(10),
					child: Row(children: <Widget>[])
				))
			]))
		]);
	}

	List<Map<String, String>> _genTempData() => [{
		"subject": "电压",
		"input": "{data} V",
		"output": "{data} V",
		"battery": "{data} V",
		"others": "过载 {data}"
	}, {
		"subject": "电流",
		"input": "-",
		"output": "{data} A",
		"battery": "{data} A",
		"others": "低电池电压 {data}"
	}, {
		"subject": "频率",
		"input": "{data} Hz",
		"output": "{data} Hz",
		"battery": "电池更换告警 {data}",
		"others": "电池过充 {data}"
	}];

    @override
    String pageId() => "ups";

	@override
	void hdlDevices(data) {
		if (data["ups"] == null) {
			return;
		}
		global.idenDevs = [
			Device.fromJSON(data["ups"]).id
		];
	}

	@override
	void hdlPointVals(dynamic data) => setState(() {
		print(data.length);
		for (PointVal pv in data) {
			String poiName = global.protocolMapper[pv.id];
			if (_values[poiName] != null) {
				_values[poiName] = pv.desc != null ? pv.desc : pv.value.toStringAsFixed(1);
			}
		}
	});
}