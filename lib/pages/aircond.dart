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
		"压缩机转速": "0.0",
		"内风机转速": "0.0",
		"外风机转速": "0.0",
		"膨胀阀开度": "0.0",
		"加热器电流": "0.0",
		"运行状态": "0",
		"制冷状态": "0",
		"加热状态": "0",
		"除湿状态": "0",
		"内风机": "0",
		"外风机": "0",
		"压缩机": "0",
		"运行频率": "0.0",
		"内风机电压": "0.0",
		"出盘温度": "0.0",
		"吸气压力": "0.0",
		"排气压力": "0.0",
		"进盘温度": "0.0",
		"排气温度": "0.0",
		"目标蒸发温度": "0.0"
	};
	String _mstatus = "未知";
	String _rstatus = "未知";
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
									DescListItemTitle("排气压力", size: _titleSize),
									DescListItemContent(_values["排气压力"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "Bar")
								),
								DescListItem(
									DescListItemTitle("吸气压力", size: _titleSize),
									DescListItemContent(_values["吸气压力"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "Bar")
								),
								DescListItem(
									DescListItemTitle("运行频率", size: _titleSize),
									DescListItemContent(_values["运行频率"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "Hz")
								),
								DescListItem(
									DescListItemTitle("内风机电压", size: _titleSize),
									DescListItemContent(_values["内风机电压"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "V")
								)
							])),
							VerticalDivider(width: 60),
							Expanded(child: Column(children: <Widget>[
								DescListItem(
									DescListItemTitle("排气温度", size: _titleSize),
									DescListItemContent(_values["排气温度"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "℃")
								),
								DescListItem(
									DescListItemTitle("蒸发温度", size: _titleSize),
									DescListItemContent(_values["目标蒸发温度"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "℃")
								),
								DescListItem(
									DescListItemTitle("进盘温度", size: _titleSize),
									DescListItemContent(_values["进盘温度"], right: _sufSpace),
									suffix: DescListItemSuffix(text: "℃")
								),
								DescListItem(
									DescListItemTitle("出盘温度", size: _titleSize),
									DescListItemContent(_values["出盘温度"], right: _sufSpace),
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
								DescListItemTitle("机组状态", size: _titleSize),
								DescListItemContent(_mstatus, right: _sufSpace)
							),
							DescListItem(
								DescListItemTitle("运行模式", size: _titleSize),
								DescListItemContent(_rstatus, right: _sufSpace)
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
				_values[poiName] = pv.value.toStringAsFixed(1);
			}
			if (poiName == "机组开关机") {
				_mstatus = pv.desc;
			}
			if (poiName == "机组运行模式") {
				_rstatus = pv.desc;
			}
		}
	});

	void hdlDetails(dynamic data) => setState(() {
		_details = data;
	});
}