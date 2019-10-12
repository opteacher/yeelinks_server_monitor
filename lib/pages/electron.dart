import 'package:flutter/material.dart';
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
		"功率因素": "0.0",
		"输入频率": "0.0"
	};
	Map<String, String> _pduVals = {
		"PDU-输出电压": "0.0",
		"PDU-输出电流": "0.0",
		"PDU-有功功率": "0.0",
		"PDU-功率因素": "0.0",
		"PDU-输出频率": "0.0",
		"PDU-有功电能": "0.0"
	};

	@override
	Widget build(BuildContext context) {
		final primaryColor = Theme.of(context).primaryColor;
		return Container(padding: const EdgeInsets.all(2.5), child: Row(children: <Widget>[
			Expanded(child: Container(
				margin: EdgeInsets.all(3.5),
				padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
				decoration: BoxDecoration(
					border: Border.all(color: Theme.of(context).primaryColor),
				),
				child: ListView(children: _pdus.map<Widget>((pdu) => (global.currentDevID == pdu.id ? FlatButton(
					shape: RoundedRectangleBorder(
						side: BorderSide(color: primaryColor),
						borderRadius: BorderRadius.all(Radius.circular(3))
					),
					disabledColor: primaryColor,
					child: Text(pdu.name, style: TextStyle(color: Colors.white)), onPressed: null,
				) : OutlineButton(
					textColor: primaryColor,
					borderSide: BorderSide(color: primaryColor),
					child: Text(pdu.name), onPressed: () => setState(() {
						global.idenDevs = [pdu.id];
						if (_mainEleID.isNotEmpty) {
							global.idenDevs.add(_mainEleID);
						}
						global.refreshTimer.refresh(context, pdu.id, null);
					}))
				)).toList())
			)),
			Expanded(flex: 4, child: Column(children: <Widget>[
				DataCard(title: "主路输入", child: Padding(padding: EdgeInsets.all(20), child: Row(children: <Widget>[
					Expanded(child: Padding(padding: EdgeInsets.only(top: 10),
						child: Instrument(
							radius: 120.0,
							numScales: 10,
							max: 300.0,
							scalesColor: {
								Offset(0, 180): Colors.grey,
//								Offset(180, 240): Colors.green,
								Offset(240, 300): Colors.red
							},
							value: double.parse(_eleVals["电压"]),
							suffix: "V"
						)
					)),
					VerticalDivider(width: 50),
					Expanded(child: Padding(padding: EdgeInsets.only(top: 10),
						child: Instrument(
							radius: 120.0,
							numScales: 8,
							max: 20.0,
							scalesColor: {
								Offset(16, 20): Colors.red
							},
							value: double.parse(_eleVals["电流"]),
							suffix: "A"
						)
					)),
					VerticalDivider(width: 50),
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("有功功率"),
							DescListItemContent(_eleVals["有功功率"], horizontal: 50.0, blocked: true)
						),
						DescListItem(
							DescListItemTitle("有功电能"),
							DescListItemContent(_eleVals["有功电能"], horizontal: 50.0, blocked: true)
						),
						DescListItem(
							DescListItemTitle("功率因素"),
							DescListItemContent(_eleVals["功率因素"], horizontal: 50.0, blocked: true)
						),
						DescListItem(
							DescListItemTitle("输入频率"),
							DescListItemContent(_eleVals["输入频率"], horizontal: 50.0, blocked: true)
						),
					]))
				]))),
				DataCard(title: "PDU", child: Row(children: <Widget>[
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("输出电压"),
							DescListItemContent(_pduVals["PDU-输出电压"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "V"),
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("输出电流"),
							DescListItemContent(_pduVals["PDU-输出电流"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "A"),
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("有功功率"),
							DescListItemContent(_pduVals["PDU-有功功率"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "W"),
							horizontal: 50.0
						),
					])),
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("功率因素"),
							DescListItemContent(_pduVals["PDU-功率因素"], horizontal: 50.0),
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("输出频率"),
							DescListItemContent(_pduVals["PDU-输出频率"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "Hz"),
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("有功电能"),
							DescListItemContent(_pduVals["PDU-有功电能"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "kWh"),
							horizontal: 50.0
						),
					]))
				]))
			]))
		]));
	}

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