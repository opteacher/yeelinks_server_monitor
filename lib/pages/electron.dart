import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:carousel_slider/carousel_slider.dart';
import '../async.dart';
import '../components.dart';
import '../global.dart' as global;

class ElectronPageState extends State<Page> {
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
	bool _showDetail = false;

	Widget _mainElecInputDetail() => Padding(padding: EdgeInsets.all(20), child: GridView.count(
		crossAxisCount: 6,
		children: <Widget>[
			DescListItem(
				DescListItemTitle("AB-线电压", size: 20.0),
				[DescListItemContent("-000.0", blocked: true, suffixText: "V")],
				contentAlign: TextAlign.center,
				contentWidth: 120,
				horizontal: 20,
				expanded: false
			),
			DescListItem(
				DescListItemTitle("AB-线电压", size: 20.0),
				[DescListItemContent("-000.0", blocked: true, suffixText: "V")],
				contentAlign: TextAlign.center,
				contentWidth: 120,
				horizontal: 20,
				expanded: false
			)
		]
	));

	Widget _mainElecInputNormal() => Padding(padding: EdgeInsets.all(20), child: Row(children: <Widget>[
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
						value: double.parse(
							global.values["配电系统-市电输入-AB相电压"] != null ?
							global.values["配电系统-市电输入-AB相电压"].status :
							"0.00"
						),
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
						value: double.parse(
							global.values["配电系统-市电输入-BC相电压"] != null ?
							global.values["配电系统-市电输入-BC相电压"].status :
							"0.00"
						),
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
						value: double.parse(
							global.values["配电系统-市电输入-CA相电压"] != null ?
							global.values["配电系统-市电输入-CA相电压"].status :
							"0.00"
						),
						suffix: "V"
					),
					Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
						Text("CA-相电压", style: TextStyle(fontSize: 20))
					])
				])
			]
		)),
		VerticalDivider(color: Colors.white),
		Expanded(child: Row(children: <Widget>[
			Expanded(child: Column(children: <Widget>[
				DescListItem(
					DescListItemTitle("A 相电压", size: 20.0),
					[DescListItemContent(
						global.values["配电系统-市电输入-A相电压"] != null ?
						global.values["配电系统-市电输入-A相电压"].status :
						"0.00",
						blocked: true,
						suffixText: "V",
						horizontal: 10
					)],
					titleAlign: TextAlign.center,
					contentAlign: TextAlign.center,
					contentWidth: 200
				),
				DescListItem(
					DescListItemTitle("B 相电压", size: 20.0),
					[DescListItemContent(
						global.values["配电系统-市电输入-B相电压"] != null ?
						global.values["配电系统-市电输入-B相电压"].status :
						"0.00",
						blocked: true,
						suffixText: "V",
						horizontal: 10
					)],
					titleAlign: TextAlign.center,
					contentAlign: TextAlign.center,
					contentWidth: 200
				),
				DescListItem(
					DescListItemTitle("C 相电压", size: 20.0),
					[DescListItemContent(
						global.values["配电系统-市电输入-C相电压"] != null ?
						global.values["配电系统-市电输入-C相电压"].status :
						"0.00",
						blocked: true,
						suffixText: "V",
						horizontal: 10
					)],
					titleAlign: TextAlign.center,
					contentAlign: TextAlign.center,
					contentWidth: 200
				),
				DescListItem(
					DescListItemTitle("", size: 20.0),
					[DescListItemContent("")],
					titleAlign: TextAlign.center,
					contentAlign: TextAlign.center,
					contentWidth: 200
				)
			])),
			VerticalDivider(color: Colors.white, width: 30),
			Expanded(child: Column(children: <Widget>[
				DescListItem(
					DescListItemTitle("有功功率", size: 20.0),
					[DescListItemContent(
						global.values["配电系统-市电输入-有功功率"] != null ?
						global.values["配电系统-市电输入-有功功率"].status :
						"0.00",
						blocked: true,
						suffixText: "kW",
						horizontal: 10
					)],
					titleAlign: TextAlign.center,
					contentAlign: TextAlign.center,
					contentWidth: 200
				),
				DescListItem(
					DescListItemTitle("无功功率", size: 20.0),
					[DescListItemContent(
						global.values["配电系统-市电输入-无功功率"] != null ?
						global.values["配电系统-市电输入-无功功率"].status :
						"0.00",
						blocked: true,
						suffixText: "kW",
						horizontal: 10
					)],
					titleAlign: TextAlign.center,
					contentAlign: TextAlign.center,
					contentWidth: 200
				),
				DescListItem(
					DescListItemTitle("视在功率", size: 20.0),
					[DescListItemContent(
						global.values["配电系统-市电输入-视在功率"] != null ?
						global.values["配电系统-市电输入-视在功率"].status :
						"0.00",
						blocked: true,
						suffixText: "kW",
						horizontal: 10
					)],
					titleAlign: TextAlign.center,
					contentAlign: TextAlign.center,
					contentWidth: 200
				),
				DescListItem(
					DescListItemTitle("频率", size: 20.0),
					[DescListItemContent(
						global.values["配电系统-市电输入-频率"] != null ?
						global.values["配电系统-市电输入-频率"].status :
						"0.00",
						blocked: true,
						suffixText: "kW",
						horizontal: 10
					)],
					titleAlign: TextAlign.center,
					contentAlign: TextAlign.center,
					contentWidth: 200
				)
			]))
		]))
	]));

	@override
	Widget build(BuildContext context) => Column(children: <Widget>[
		DataCard(title: "市电输入", tailing: IconButton(
			icon: Icon(Icons.info_outline, color: global.primaryColor),
			onPressed: () => setState(() {})
		), child: Stack(children: <Widget>[
			CarouselSlider(
				height: double.infinity,
				viewportFraction: 1.0,
				enableInfiniteScroll: false,
				items: <Widget>[
					_mainElecInputNormal(),
					_mainElecInputDetail()
				],
				onPageChanged: (index) => setState(() {
					_showDetail = index == 1;
				}),
			),
			Positioned(
				bottom: 0.0,
				left: 0.0,
				right: 0.0,
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [false, true].map<Widget>((index) => Container(
						width: 12.0,
						height: 12.0,
						margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
						decoration: BoxDecoration(
							shape: BoxShape.circle,
							color: index == _showDetail ? Color.fromRGBO(0, 0, 0, 0.9) : Color.fromRGBO(0, 0, 0, 0.4)
						),
					)).toList()
				),
			)
		])),
		Expanded(child: Row(children: <Widget>[
			DataCard(title: "PDU", child: _buildPduListView()),
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
							defaultRenderer: new charts.BarRendererConfig<DateTime>(),
							defaultInteractions: false,
							behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
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
							defaultRenderer: new charts.BarRendererConfig<DateTime>(),
							defaultInteractions: false,
							behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
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

	Widget _buildPduListView() {
		var pduPois = global.values.values.where((ele) => ele.grpName == "PDU系统");
		var pduMap = <String, Map<String, String>>{};
		for (var pduPoi in pduPois) {
			if (pduMap[pduPoi.bayName] != null) {
				pduMap[pduPoi.bayName][pduPoi.poiName] = pduPoi.status;
			} else {
				pduMap[pduPoi.bayName] = {
					"名字": pduPoi.bayName,
					pduPoi.poiName: pduPoi.status
				};
			}
		}
		final idxTxtStyle = TextStyle(fontSize: 20, color: global.primaryColor);
		return ListView(children: pduMap.values.map<Widget>((pdu) => Padding(
			padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
			child: Column(children: <Widget>[
				Padding(padding: EdgeInsets.only(bottom: 10), child: Row(
					mainAxisAlignment: MainAxisAlignment.start,
					children: <Widget>[Text(pdu["名字"], style: TextStyle(
						fontSize: 25,
						fontWeight: FontWeight.w600
					))]
				)),
				Padding(padding: EdgeInsets.only(bottom: 5), child: Row(children: <Widget>[
					Expanded(child: Row(children: <Widget>[
						Expanded(child: Text(
							pdu["A相电压"] != null ? pdu["A相电压"] : "0.00",
							textAlign: TextAlign.left, style: idxTxtStyle
						)),
						Expanded(child: Text("V", style: idxTxtStyle))
					])),
					Expanded(child: Row(children: <Widget>[
						Expanded(child: Text(
							pdu["A相有功"] != null ? pdu["A相有功"] : "0.00",
							textAlign: TextAlign.right, style: idxTxtStyle
						)),
						Expanded(child: Text("", style: idxTxtStyle))
					]))
				])),
				Padding(padding: EdgeInsets.only(bottom: 5), child: Row(children: <Widget>[
					Expanded(child: Row(children: <Widget>[
						Expanded(child: Text(
							pdu["A相电流"] != null ? pdu["A相电流"] : "0.00",
							textAlign: TextAlign.left, style: idxTxtStyle
						)),
						Expanded(child: Text("A", style: idxTxtStyle))
					])),
					Expanded(child: Row(children: <Widget>[
						Expanded(child: Text(
							pdu["频率"] != null ? pdu["频率"] : "0.00",
							textAlign: TextAlign.right, style: idxTxtStyle
						)),
						Expanded(child: Text("Hz",
							textAlign: TextAlign.right, style: idxTxtStyle
						))
					]))
				])),
				Divider(color: global.primaryColor)
			])
		)).toList());
	}
}