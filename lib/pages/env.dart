import 'package:flutter/material.dart';
import '../async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => EnvPageState();
}

class EnvPageState extends BasePageState<Page> {
	final _dividerTxtStyle = TextStyle(
		fontSize: 20,
		fontWeight: FontWeight.w900,
		color: const Color(0xFF757575)
	);
	final _envBlkPdg = const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0);
	final _envTitlePdg = const EdgeInsets.symmetric(vertical: 5, horizontal: 15);
	final _titleBtmMgn = const EdgeInsets.only(bottom: 15);

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
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(2.5), child: Row(children: <Widget>[
		Expanded(child: Column(children: <Widget>[
			DataCard(title: "冷通道环境", child: Padding(padding: _envBlkPdg, child: Column(children: <Widget>[
				Row(children: <Widget>[
					Expanded(child: Container(padding: _envTitlePdg, margin: _titleBtmMgn, color: Colors.grey[100], child: Text("环境1", style: _dividerTxtStyle)))
				]),
				Row(children: <Widget>[
					DescListItem(
						DescListItemTitle("温度", size: 20.0),
						DescListItemContent(values["温度"], blocked: true),
						contentAlign: TextAlign.center
					),
					VerticalDivider(width: 25),
					DescListItem(
						DescListItemTitle("湿度", size: 20.0),
						DescListItemContent(values["湿度"], blocked: true),
						contentAlign: TextAlign.center
					)
				]),
				Divider(height: 50),
				Row(children: <Widget>[
					Expanded(child: Container(padding: _envTitlePdg, margin: _titleBtmMgn, color: Colors.grey[100], child: Text("环境2", style: _dividerTxtStyle)))
				]),
				Row(children: <Widget>[
					DescListItem(
						DescListItemTitle("温度", size: 20.0),
						DescListItemContent(values["温度"], blocked: true),
						contentAlign: TextAlign.center
					),
					VerticalDivider(width: 25),
					DescListItem(
						DescListItemTitle("湿度", size: 20.0),
						DescListItemContent(values["湿度"], blocked: true),
						contentAlign: TextAlign.center
					)
				]),
			])))
		])),
		Expanded(flex: 2, child: Column(children: <Widget>[
			DataCard(title: "温度曲线", child: SimpleTimeSeriesChart("温度", "20479254")),
			DataCard(title: "湿度曲线", child: SimpleTimeSeriesChart("湿度", "20361980")),
			DataCard(title: "机柜状态", height: 200, child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row(children: <Widget>[
				Expanded(child: Column(children: <Widget>[
					Text("前门"), RaisedButton(elevation: 0, onPressed: () {}, child: Text("开启"))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("后门"), RaisedButton(elevation: 0, onPressed: () {}, child: Text("开启"))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("水浸"), RaisedButton(elevation: 0, onPressed: () {}, child: Text("正常"))
				])),
				VerticalDivider(),
				Expanded(child: Column(children: <Widget>[
					Text("烟感"), RaisedButton(elevation: 0, onPressed: () {}, child: Text("异常", style: TextStyle(color: Colors.orangeAccent)))
				])),
				VerticalDivider()
			])))
		])),
		Expanded(child: Column(children: <Widget>[
			DataCard(title: "热通道环境", child: Padding(padding: _envBlkPdg, child: Column(children: <Widget>[
				Row(children: <Widget>[
					Expanded(child: Container(padding: _envTitlePdg, margin: _titleBtmMgn, color: Colors.grey[100], child: Text("环境1", style: _dividerTxtStyle)))
				]),
				Row(children: <Widget>[
					DescListItem(
						DescListItemTitle("温度", size: 20.0),
						DescListItemContent(values["温度"], blocked: true),
						contentAlign: TextAlign.center
					),
					VerticalDivider(width: 25),
					DescListItem(
						DescListItemTitle("湿度", size: 20.0),
						DescListItemContent(values["湿度"], blocked: true),
						contentAlign: TextAlign.center
					)
				]),
				Divider(height: 50),
				Row(children: <Widget>[
					Expanded(child: Container(padding: _envTitlePdg, margin: _titleBtmMgn, color: Colors.grey[100], child: Text("环境2", style: _dividerTxtStyle)))
				]),
				Row(children: <Widget>[
					DescListItem(
						DescListItemTitle("温度", size: 20.0),
						DescListItemContent(values["温度"], blocked: true),
						contentAlign: TextAlign.center
					),
					VerticalDivider(width: 25),
					DescListItem(
						DescListItemTitle("湿度", size: 20.0),
						DescListItemContent(values["湿度"], blocked: true),
						contentAlign: TextAlign.center
					)
				]),
			])))
		])),
	]));

	@override
	String pageId() => "env";

	@override
	void hdlDevices(data) {
		// TODO: implement hdlDevices
	}
}