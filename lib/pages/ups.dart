import 'package:flutter/material.dart';
import 'package:yeelinks/async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => UpsPageState();
}

class UpsPageState extends BasePageState<Page> {
	final _infoPdg = const EdgeInsets.symmetric(vertical: 10, horizontal: 15);

	bool _showDetail = false;
	Map<String, String> _values = {
		"输入电压": "0.0",
		"输入频率": "0.0",
		"输出电压": "0.0",
		"输出电流": "0.0",
		"输出频率": "0.0",
		"运行模式": "0",
		"电池容量": "0.0",
		"电池剩余时间": "0",
		"电池电压": "0.0",
		"电池电流": "0.0",
		"电池电量不足": "0"
	};

	@override
	Widget build(BuildContext context) {
		var data = _genTempData();
		data[0]["input"] = data[0]["input"].replaceFirst("{data}", _values["输入电压"]);
		data[0]["output"] = data[0]["output"].replaceFirst("{data}", _values["输出电压"]);
		data[0]["battery"] = data[0]["battery"].replaceFirst("{data}", _values["电池电压"]);
		data[0]["others"] = data[0]["others"].replaceFirst("{data}", "0");
		data[1]["output"] = data[1]["output"].replaceFirst("{data}", _values["输出电流"]);
		data[1]["battery"] = data[1]["battery"].replaceFirst("{data}", _values["电池电流"]);
		data[1]["others"] = data[1]["others"].replaceFirst("{data}", _values["电池电压"]);
		data[2]["input"] = data[2]["input"].replaceFirst("{data}", _values["输入频率"]);
		data[2]["output"] = data[2]["output"].replaceFirst("{data}", _values["输出频率"]);
		data[2]["battery"] = data[2]["battery"].replaceFirst("{data}", _values["电池电量不足"]);
		data[2]["others"] = data[2]["others"].replaceFirst("{data}", "0");

		return Container(padding: const EdgeInsets.all(2.5), child: Row(children: <Widget>[
			Expanded(child: Column(children: <Widget>[
				DataCard(title: "UPS输入信息", child: Padding(padding: _infoPdg, child: Column(children: <Widget>[
					DescListItem(
						DescListItemTitle("输入电压", size: 20.0),
						DescListItemContent(_values["输入电压"], blocked: true)
					),
					DescListItem(
						DescListItemTitle("输入频率", size: 20.0),
						DescListItemContent(_values["输入频率"], blocked: true)
					),
					DescListItem(
						DescListItemTitle("旁路电压", size: 20.0),
						DescListItemContent(_values["输入电压"], blocked: true)
					)
				]))),
				DataCard(title: "UPS输出信息", child: Padding(padding: _infoPdg, child: Column(children: <Widget>[
					DescListItem(
						DescListItemTitle("输出电压", size: 20.0),
						DescListItemContent(_values["输出电压"], blocked: true)
					),
					DescListItem(
						DescListItemTitle("输出电流", size: 20.0),
						DescListItemContent(_values["输出电流"], blocked: true)
					),
					DescListItem(
						DescListItemTitle("输出频率", size: 20.0),
						DescListItemContent(_values["输出频率"], blocked: true)
					)
				])))
			])),
			Expanded(flex: 4, child: Column(children: <Widget>[
				Expanded(child: Row(children: <Widget>[
					DataCard(title: "UPS负载率", child: Padding(
						padding: EdgeInsets.only(top: 20),
						child: Instrument(radius: 120.0, numScales: 10, max: 120.0, maxScale: 96, suffix: "%")
					)),
					DataCard(title: "UPS状态", tailing: IconButton(icon: Icon(Icons.info_outline, color: Theme.of(context).primaryColor), onPressed: () {
						setState(() {
							_showDetail = !_showDetail;
						});
					}), child: !_showDetail ? Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("UPS运行模式"),
							DescListItemContent(_values["运行模式"], right: 20.0),
							titleWidth: 200.0,
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("电池容量"),
							DescListItemContent(_values["电池容量"], right: 20.0),
							suffix: DescListItemSuffix(text: "%"),
							titleWidth: 200.0,
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("电池剩余时间"),
							DescListItemContent(_values["电池剩余时间"], right: 20.0),
							suffix: DescListItemSuffix(text: "Min"),
							titleWidth: 200.0,
							horizontal: 50.0
						),
					]) : ListView(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), children: <Widget>[
						ListTile(
							title: Text("电池开启"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("旁路功率不稳定"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("EEPROM错误"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("输出过载"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("根据用户指令，UPS准备好供电"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("已准备供电"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("电池电量不足"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("电池模式"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("在线模式"),
							trailing: Text("0")
						), Divider(),
						ListTile(
							title: Text("输出电压不良"),
							trailing: Text("0")
						), Divider(),
					]))
				])),
				DataCard(title: "实时数据", child: MyDataTable({
					"": MyDataHeader("subject", 0.1),
					"输入": MyDataHeader("input"),
					"输出": MyDataHeader("output"),
					"电池": MyDataHeader("battery", 0.25),
					"其他": MyDataHeader("others", 0.25)
				}, data, vpadding: 15.0))
			]))
		]));
	}

	List<Map<String, String>> _genTempData() => [{
		"subject": "电压",
		"input": "{data} V",
		"output": "{data} V",
		"battery": "电池电压 {data} V",
		"others": "过载 {data}"
	}, {
		"subject": "电流",
		"input": "-",
		"output": "{data} A",
		"battery": "电池电流 {data} A",
		"others": "低电池电压 {data}"
	}, {
		"subject": "频率",
		"input": "{data} Hz",
		"output": "{data} Hz",
		"battery": "电池更换告警 {data} Hz",
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
		for (PointVal pv in data) {
			String poiName = global.protocolMapper[pv.id];
			if (_values[poiName] != null) {
				_values[poiName] = pv.value.toStringAsFixed(1);
			}
		}
	});
}