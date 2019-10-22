import 'package:flutter/material.dart';
import '../async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => AircondPageState();

}

class AircondPageState extends BasePageState<Page> {
	bool _showDetail = false;
	List<Device> _airconds = [];
	Map<String, String> _values = {
		"送风温度": "0.0",
		"回风温度": "0.0",
		"回风湿度": "0.0",
		"压缩机转速": "0",
		"内风机转速": "0",
		"外风机转速": "0",
		"膨胀阀开度": "0",
		"加热器电流": "0.0",
		"环境温度": "0.0",
		"回气温度": "0.0",
		"电源电压值": "0.0",
		"冷凝温度": "0.0",
		"机组运行模式": "未知",
		"机组开关机": "未知",
		"运行状态": "未知",
		"制冷状态": "未知",
		"加热状态": "未知",
		"除湿状态": "未知",
		"内风机": "未知",
		"外风机": "未知",
		"压缩机": "未知",
		"运行频率": "0.0",
		"内风机电压": "0.0",
		"出盘温度": "0.0",
		"吸气压力": "0.0",
		"排气压力": "0.0",
		"进盘温度": "0.0",
		"排气温度": "0.0",
		"目标蒸发温度": "0.0"
	};
	List<PointVal> _details = [];

	@override
	void initState() {
		super.initState();
		global.refreshTimer.register("listAircondDetail", TimerJob(getAcDetail, hdlDetails, {
			TimerJob.PAGE_IDEN: pageId(),
			TimerJob.ACTV_IDEN: ""
		}));
	}

	@override
	Widget build(BuildContext context) {
		final double _titleSize = 20.0;
		final double _sufSpace = 3.0;
		final double _htlPadding = 30.0;
		final primaryColor = Theme.of(context).primaryColor;
		return Container(padding: const EdgeInsets.all(2.5), child: Row(children: <Widget>[
			Expanded(child: Container(
				decoration: BoxDecoration(
					border: Border.all(color: primaryColor),
				),
				margin: EdgeInsets.all(3.5),
				padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
				child: ListView(children: _airconds.map<Widget>((acd) => (global.currentDevID == acd.id ? FlatButton(
					shape: RoundedRectangleBorder(
						side: BorderSide(color: primaryColor),
						borderRadius: BorderRadius.all(Radius.circular(3))
					),
					disabledColor: primaryColor,
					child: Text(acd.name, style: TextStyle(color: Colors.white)), onPressed: null,
				) : OutlineButton(
					textColor: primaryColor,
					borderSide: BorderSide(color: primaryColor),
					child: Text(acd.name), onPressed: () => setState(() {
					global.refreshTimer.refresh(context, acd.id, () async {
						global.idenDevs = [acd.id];
					});
				}))
				)).toList())
			)),
			Expanded(flex: 4, child: Column(children: <Widget>[
				Expanded(child: Row(children: <Widget>[
					DataCard(title: "送风温度", child: Padding(
						padding: EdgeInsets.only(top: 20),
						child: Instrument(
							radius: 110.0,
							numScales: 10,
							max: 100.0,
							scalesColor: {
								Offset(80, 100): Colors.red
							},
							value: double.parse(_values["送风温度"]),
							suffix: "℃"
						)
					)),
					DataCard(title: "回风温度", child: Padding(
						padding: EdgeInsets.only(top: 20),
						child: Instrument(
							radius: 110.0,
							numScales: 10,
							max: 100.0,
							scalesColor: {
								Offset(80, 100): Colors.red
							},
							value: double.parse(_values["回风温度"]),
							suffix: "℃"
						)
					)),
					DataCard(title: "回风湿度", child: Padding(
						padding: EdgeInsets.only(top: 20),
						child: Instrument(
							radius: 110.0,
							numScales: 10,
							max: 100.0,
							scalesColor: {
								Offset(80, 100): Colors.red
							},
							value: double.parse(_values["回风湿度"]),
							suffix: "%"
						)
					))
				])),
				Expanded(child: Row(children: <Widget>[
					DataCard(flex: 2, title: "实时数据", tailing: IconButton(
						icon: Icon(Icons.info_outline, color: primaryColor),
						onPressed: () => setState(() {
							_showDetail = !_showDetail;
							global.refreshTimer.getJob("listAircondDetail").doActive(_showDetail);
							global.refreshTimer.refresh(context, global.currentDevID, null);
						})
					), child: Padding(
						padding: EdgeInsets.symmetric(horizontal: _htlPadding),
						child: !_showDetail ? Row(children: <Widget>[
							Expanded(child: Column(children: <Widget>[
								DescListItem(
									DescListItemTitle("外风机转速", size: _titleSize),
									DescListItemContent(_values["外风机转速"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "N")
								),
								DescListItem(
									DescListItemTitle("内风机转速", size: _titleSize),
									DescListItemContent(_values["内风机转速"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "N")
								),
								DescListItem(
									DescListItemTitle("压缩机转速", size: _titleSize),
									DescListItemContent(_values["压缩机转速"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "N")
								),
								DescListItem(
									DescListItemTitle("加热器电流", size: _titleSize),
									DescListItemContent(_values["加热器电流"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "A")
								),
								DescListItem(
									DescListItemTitle("电子膨胀阀开度", size: _titleSize),
									DescListItemContent(_values["膨胀阀开度"], right: _sufSpace)
								)
							])),
							VerticalDivider(width: 60),
							Expanded(child: Column(children: <Widget>[
								DescListItem(
									DescListItemTitle("环境温度", size: _titleSize),
									DescListItemContent(_values["环境温度"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "℃")
								),
								DescListItem(
									DescListItemTitle("回气温度", size: _titleSize),
									DescListItemContent(_values["回气温度"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "℃")
								),
								DescListItem(
									DescListItemTitle("电源电压值", size: _titleSize),
									DescListItemContent(_values["电源电压值"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "V")
								),
								DescListItem(
									DescListItemTitle("冷凝温度", size: _titleSize),
									DescListItemContent(_values["冷凝温度"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "℃")
								)
							]))
						]) : ListView(children: _details.map<Widget>((pv) => ListTile(
							title: Text(pv.name),
							trailing: Text(pv.desc != null ? pv.desc : pv.value.toString()),
						)).toList())
					)),
					DataCard(title: "运行状态", child: Padding(
						padding: EdgeInsets.symmetric(horizontal: _htlPadding),
						child: Column(children: <Widget>[
							DescListItem(
								DescListItemTitle("运行状态", size: _titleSize),
								DescListItemContent(_values["运行状态"], right: _sufSpace)
							),
							DescListItem(
								DescListItemTitle("制冷状态", size: _titleSize),
								DescListItemContent(_values["制冷状态"], right: _sufSpace)
							),
							DescListItem(
								DescListItemTitle("加热状态", size: _titleSize),
								DescListItemContent(_values["加热状态"], right: _sufSpace)
							),
							DescListItem(
								DescListItemTitle("除湿状态", size: _titleSize),
								DescListItemContent(_values["除湿状态"], right: _sufSpace)
							),
							DescListItem(
								DescListItemTitle("内风机", size: _titleSize),
								DescListItemContent(_values["内风机"], right: _sufSpace)
							),
							DescListItem(
								DescListItemTitle("外风机", size: _titleSize),
								DescListItemContent(_values["外风机"], right: _sufSpace)
							),
							DescListItem(
								DescListItemTitle("压缩机", size: _titleSize),
								DescListItemContent(_values["压缩机"], right: _sufSpace)
							)
						])
					))
				]))
			]))
		]));
	}

	@override
	String pageId() => "aircond";

	@override
	void hdlDevices(data) => setState(() {
		_airconds = [];
		for (var acd in data["devices"]) {
			_airconds.add(Device.fromJSON(acd));
		}
		if (global.currentDevID.isEmpty) {
			global.currentDevID = _airconds[0].id;
			global.idenDevs = [global.currentDevID];
		}
	});

	@override
	void hdlPointVals(dynamic data) => setState(() {
		for (PointVal pv in data) {
			String poiName = global.protocolMapper[pv.id];
			if (_values[poiName] != null) {
				if (pv.desc != null && pv.desc.isNotEmpty) {
					_values[poiName] = pv.desc;
				} else if (poiName == "送风温度"
					|| poiName == "回风温度"
					|| poiName == "回风湿度"
					|| poiName == "送风温度"
				) {
					_values[poiName] = pv.value.toStringAsFixed(2);
				} else if (poiName == "加热器电流"
					|| poiName == "环境温度"
					|| poiName == "回气温度"
					|| poiName == "电源电压值"
					|| poiName == "冷凝温度"
				) {
					_values[poiName] = pv.value.toStringAsFixed(1);
				} else {
					_values[poiName] = pv.value.toStringAsFixed(0);
				}
			}
		}
	});

	void hdlDetails(dynamic data) => setState(() {
		_details = data;
	});
}