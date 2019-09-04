import 'package:flutter/material.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => AircondPageState();

}

class AircondPageState extends BasePageState<Page> {
	bool _showDetail = false;

	AircondPageState() {
		resetValues();
	}

	@override
	void resetValues() {
		values = {
			"送风温度": "0.0",
			"回风温度": "0.0",
			"回风湿度": "0.0",
			"压缩机转速": "0.0",
			"内风机转速": "0.0",
			"外风机转速": "0.0",
			"膨胀阀开度": "0.0",
			"加热器电流": "0.0",
			"运行状态": "0",
			"制冷状态": "0",
			"加热状态": "0",
			"除湿状态": "0",
			"自检状态": "0",
			"内风机": "0",
			"外风机": "0",
			"压缩机": "0",
			"送风温度传感器故障": "0",
			"回风温度传感器故障": "0",
			"冷凝盘管温度传感器故障": "0",
			"过热度温度传感器故障": "0",
			"环境温度传感器故障": "0",
			"系统低压压力传感器故障": "0",
			"回风湿度传感器故障": "0",
			"内风机故障": "0",
			"外风机故障": "0",
			"压缩机故障": "0",
			"加热器故障": "0",
			"回风高温告警": "0",
			"电源电压过高告警": "0",
			"电源电压过低告警": "0",
			"系统高压力告警": "0",
			"系统低压力告警": "0",
			"水浸告警": "0",
			"压缩机温度过高告警": "0",
			"内外机通信故障告警": "0",
			"烟雾告警": "0",
			"回风高湿告警": "0",
			"回风低湿告警": "0",
			"回风低温告警": "0",
			"送风高温告警": "0",
			"送风低温告警": "0",
			"过热度过高报警": "0",
			"过热度过低报警": "0",
			"高压开关故障告警": "0"
		};
	}

	@override
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), child: Column(children: <Widget>[
		Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
			OutlineButton(
				child: Text("详细信息", style: TextStyle(color: Theme.of(context).primaryColor)),
				onPressed: () {
					setState(() {
						_showDetail = !_showDetail;
					});
				},
			)
		]),
		Expanded(child: Row(children: <Widget>[
			DataCard(title: "参数状态", child: Column(children: <Widget>[
				DescListItem(
					DescListItemTitle("送风温度", size: 25.0),
					DescListItemContent(values["送风温度"], right: 50.0),
					suffix: DescListItemSuffix(text: "°C"),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("回风温度", size: 25.0),
					DescListItemContent(values["回风温度"], right: 50.0),
					suffix: DescListItemSuffix(text: "°C"),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("回风湿度", size: 25.0),
					DescListItemContent(values["回风湿度"], right: 50.0),
					suffix: DescListItemSuffix(text: "%"),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("压缩机转速", size: 25.0),
					DescListItemContent(values["压缩机转速"], right: 50.0),
					suffix: DescListItemSuffix(text: "RPM"),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("内风机转速", size: 25.0),
					DescListItemContent(values["内风机转速"], right: 50.0),
					suffix: DescListItemSuffix(text: "RPM"),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("外风机转速", size: 25.0),
					DescListItemContent(values["外风机转速"], right: 50.0),
					suffix: DescListItemSuffix(text: "RPM"),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("膨胀阀开度", size: 25.0),
					DescListItemContent(values["膨胀阀开度"], right: 50.0),
					suffix: DescListItemSuffix(text: "°"),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("加热器电流", size: 25.0),
					DescListItemContent(values["加热器电流"], right: 50.0),
					suffix: DescListItemSuffix(text: "A"),
					horizontal: 50.0,
					titleWidth: 300.0
				),
			])),
			DataCard(title: "运行状态", child: !_showDetail ? Column(children: <Widget>[
				DescListItem(
					DescListItemTitle("运行状态", size: 25.0),
					DescListItemContent(values["运行状态"], right: 50.0, color: Colors.redAccent),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("制冷状态", size: 25.0),
					DescListItemContent(values["制冷状态"], right: 50.0, color: Colors.redAccent),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("加热状态", size: 25.0),
					DescListItemContent(values["加热状态"], right: 50.0),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("除湿状态", size: 25.0),
					DescListItemContent(values["除湿状态"], right: 50.0),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("内风机", size: 25.0),
					DescListItemContent(values["内风机"], right: 50.0),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("外风机", size: 25.0),
					DescListItemContent(values["外风机"], right: 50.0),
					horizontal: 50.0,
					titleWidth: 300.0
				),
				DescListItem(
					DescListItemTitle("压缩机", size: 25.0),
					DescListItemContent(values["压缩机"], right: 50.0),
					horizontal: 50.0,
					titleWidth: 300.0
				),
			]) : ListView(padding: EdgeInsets.all(20.0), children: <Widget>[
				ListTile(
					title: Text("加热器运行状态"),
					trailing: Text(values["加热状态"]),
				), Divider(),
				ListTile(
					title: Text("机组运行状态"),
					trailing: Text(values["运行状态"]),
				), Divider(),
				ListTile(
					title: Text("压缩机运行状态"),
					trailing: Text(values["压缩机"]),
				), Divider(),
				ListTile(
					title: Text("自检状态"),
					trailing: Text(values["自检状态"]),
				), Divider(),
				ListTile(
					title: Text("制冷运行状态"),
					trailing: Text(values["制冷状态"]),
				), Divider(),
				ListTile(
					title: Text("除湿运行状态"),
					trailing: Text(values["除湿状态"]),
				), Divider(),
				ListTile(
					title: Text("送风温度传感器故障"),
					trailing: Text("0"),
				), Divider(),
				ListTile(
					title: Text("内风机运行状态"),
					trailing: Text(values["内风机"]),
				), Divider(),
				ListTile(
					title: Text("外风机运行状态"),
					trailing: Text(values["外风机"]),
				), Divider(),
				ListTile(
					title: Text("回风温度传感器故障"),
					trailing: Text(values["回风温度传感器故障"]),
				), Divider(),
				ListTile(
					title: Text("冷凝盘管温度传感器故障"),
					trailing: Text(values["冷凝盘管温度传感器故障"]),
				), Divider(),
				ListTile(
					title: Text("过热度温度传感器故障"),
					trailing: Text(values["过热度温度传感器故障"]),
				), Divider(),
				ListTile(
					title: Text("环境温度传感器故障"),
					trailing: Text(values["环境温度传感器故障"]),
				), Divider(),
				ListTile(
					title: Text("系统低压压力传感器故障"),
					trailing: Text(values["系统低压压力传感器故障"]),
				), Divider(),
				ListTile(
					title: Text("回风湿度传感器故障"),
					trailing: Text(values["回风湿度传感器故障"]),
				), Divider(),
				ListTile(
					title: Text("内风机故障"),
					trailing: Text(values["内风机故障"]),
				), Divider(),
				ListTile(
					title: Text("外风机故障"),
					trailing: Text(values["外风机故障"]),
				), Divider(),
				ListTile(
					title: Text("压缩机故障"),
					trailing: Text(values["压缩机故障"]),
				), Divider(),
				ListTile(
					title: Text("加热器故障"),
					trailing: Text(values["加热器故障"]),
				), Divider(),
				ListTile(
					title: Text("回风高温告警"),
					trailing: Text(values["回风高温告警"]),
				), Divider(),
				ListTile(
					title: Text("电源电压过高告警"),
					trailing: Text(values["电源电压过高告警"]),
				), Divider(),
				ListTile(
					title: Text("电源电压过低告警"),
					trailing: Text(values["电源电压过低告警"]),
				), Divider(),
				ListTile(
					title: Text("系统高压力告警"),
					trailing: Text(values["系统高压力告警"]),
				), Divider(),
				ListTile(
					title: Text("系统低压力告警"),
					trailing: Text(values["系统低压力告警"]),
				), Divider(),
				ListTile(
					title: Text("水浸告警"),
					trailing: Text(values["水浸告警"]),
				), Divider(),
				ListTile(
					title: Text("压缩机温度过高告警"),
					trailing: Text(values["压缩机温度过高告警"]),
				), Divider(),
				ListTile(
					title: Text("内外机通信故障告警"),
					trailing: Text(values["内外机通信故障告警"]),
				), Divider(),
				ListTile(
					title: Text("烟雾告警"),
					trailing: Text(values["烟雾告警"]),
				), Divider(),
				ListTile(
					title: Text("回风高湿告警"),
					trailing: Text(values["回风高湿告警"]),
				), Divider(),
				ListTile(
					title: Text("回风低湿告警"),
					trailing: Text(values["回风低湿告警"]),
				), Divider(),
				ListTile(
					title: Text("回风低温告警"),
					trailing: Text(values["回风低温告警"]),
				), Divider(),
				ListTile(
					title: Text("送风高温告警"),
					trailing: Text(values["送风高温告警"]),
				), Divider(),
				ListTile(
					title: Text("送风低温告警"),
					trailing: Text(values["送风低温告警"]),
				), Divider(),
				ListTile(
					title: Text("过热度过高报警"),
					trailing: Text(values["过热度过高报警"]),
				), Divider(),
				ListTile(
					title: Text("过热度过低报警"),
					trailing: Text(values["过热度过低报警"]),
				), Divider(),
				ListTile(
					title: Text("高压开关故障告警"),
					trailing: Text(values["高压开关故障告警"]),
				), Divider(),
			]))
		]))
	]));

	@override
	String pageId() => "aircond";
}