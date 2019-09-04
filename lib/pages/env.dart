import 'package:flutter/material.dart';
import '../async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => EnvPageState();
}

class EnvPageState extends BasePageState<Page> {
	EnvPageState() {
		values = {
			"温度": "0.0",
			"湿度": "0.0",
			"烟雾": "0",
			"水浸": "0",
			"前门": "0",
			"后门": "0",
		};
	}

	@override
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), child: Row(children: <Widget>[
		Expanded(child: Column(children: <Widget>[
			DataCard(title: "微环境", height: 350, child: Padding(padding: EdgeInsets.only(left: 5.0), child: Row(children: <Widget>[
				Expanded(child: Padding(padding: EdgeInsets.only(right: 20.0), child: Column(children: <Widget>[
					DescListItem(
						DescListItemTitle("温度", size: 25.0),
						DescListItemContent(values["温度"], right: 5.0),
						suffix: DescListItemSuffix(text: "°C"),
						contentAlign: TextAlign.right
					),
					DescListItem(
						DescListItemTitle("烟雾", size: 25.0),
						DescListItemContent(values["烟雾"]),
						contentAlign: TextAlign.right
					),
					DescListItem(
						DescListItemTitle("前门", size: 25.0),
						DescListItemContent(values["前门"], color: Colors.redAccent),
						contentAlign: TextAlign.right
					),
				]))),
				Expanded(child: Padding(padding: EdgeInsets.only(right: 20.0), child: Column(children: <Widget>[
					DescListItem(
						DescListItemTitle("湿度", size: 25.0),
						DescListItemContent(values["湿度"], right: 5.0),
						suffix: DescListItemSuffix(text: "%"),
						contentAlign: TextAlign.right
					),
					DescListItem(
						DescListItemTitle("水浸", size: 25.0),
						DescListItemContent(values["水浸"]),
						contentAlign: TextAlign.right
					),
					DescListItem(
						DescListItemTitle("后门", size: 25.0),
						DescListItemContent(values["后门"], color: Colors.redAccent),
						contentAlign: TextAlign.right
					),
				])))
			])))
		])),
		Expanded(flex: 2, child: Column(children: <Widget>[
			DataCard(title: "温度曲线", child: SimpleTimeSeriesChart("温度", "20479254")),
			DataCard(title: "湿度曲线", child: SimpleTimeSeriesChart("湿度", "20361980"))
		]))
	]));

	@override
	String pageId() => "env";
}