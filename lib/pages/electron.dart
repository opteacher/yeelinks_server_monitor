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
	Device _selPDU;
	Device _mainEle;

	Map<String, String> _eleVals = {
		"电压": "0.0",
		"电流": "0.0",
		"有功功率": "0.0",
		"有功电能": "0.0",
		"功率因素": "0.0",
		"输入频率": "0.0"
	};
	Map<String, String> _pduVals = {
		"输出电压": "0.0",
		"输出电流": "0.0",
		"有功功率": "0.0",
		"功率因素": "0.0",
		"输出频率": "0.0",
		"有功电能": "0.0"
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
				child: ListView(children: _pdus.map<Widget>((pdu) => (_selPDU != null && _selPDU.id == pdu.id ? FlatButton(
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
						_selPDU = pdu;
						if (_mainEle != null) {
							global.idenDevs = [_mainEle.id];
						}
						global.idenDevs.add(_selPDU.id);
						global.refreshTimer.refreshPointSensor();
					}))
				)).toList())
			)),
			Expanded(flex: 4, child: Column(children: <Widget>[
				DataCard(title: "主路输入", child: Padding(padding: EdgeInsets.all(20), child: Row(children: <Widget>[
					Expanded(child: Padding(padding: EdgeInsets.only(top: 10),
						child: Instrument(radius: 120.0, numScales: 10, max: 260.0, maxScale: 208.0, value: double.parse(_eleVals["电压"]))
					)),
					VerticalDivider(width: 50),
					Expanded(child: Padding(padding: EdgeInsets.only(top: 10),
						child: Instrument(radius: 120.0, numScales: 8, max: 32.0, maxScale: 26.0, value: double.parse(_eleVals["电流"]))
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
				DataCard(title: "PDU", tailing: _selPDU != null ? OutlineButton(
					child: Text(_selPDU.name, style: TextStyle(color: Colors.grey[600])),
					onPressed: null
				) : Text(""), child: Row(children: <Widget>[
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("输出电压"),
							DescListItemContent(_pduVals["输出电压"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "V"),
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("输出电流"),
							DescListItemContent(_pduVals["输出电流"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "A"),
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("有功功率"),
							DescListItemContent(_pduVals["有功功率"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "W"),
							horizontal: 50.0
						),
					])),
					Expanded(child: Column(children: <Widget>[
						DescListItem(
							DescListItemTitle("功率因素"),
							DescListItemContent(_pduVals["功率因素"], horizontal: 50.0),
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("输出频率"),
							DescListItemContent(_pduVals["输出频率"], horizontal: 50.0),
							suffix: DescListItemSuffix(text: "Hz"),
							horizontal: 50.0
						),
						DescListItem(
							DescListItemTitle("有功电能"),
							DescListItemContent(_pduVals["有功电能"], horizontal: 50.0),
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
		bool manualRefresh = false;
		global.idenDevs = [];
		if (data["ele"] != null) {
			_mainEle = Device.fromJSON(data["ele"]);
			global.idenDevs.add(_mainEle.id);
			manualRefresh = true;
		} else {
			_mainEle = null;
		}
		if (data["pdu"] == null) {
			return;
		}

		_pdus = [];
		for (var pdu in data["pdu"]) {
			_pdus.add(Device.fromJSON(pdu));
		}
		if (_selPDU == null && _pdus.isNotEmpty) {
			_selPDU = _pdus[0];
			global.idenDevs.add(_selPDU.id);
			manualRefresh = true;
		}
		if (manualRefresh) {
			global.refreshTimer.refreshPointSensor();
		}
	});

	@override
	void hdlPointVals(dynamic data) => setState(() {
		if (_mainEle == null || _selPDU == null) {
			return;
		}
		for (PointVal pv in data) {
			if (pv.deviceId == _mainEle.id) {
				String poiName = global.protocolMapper[pv.id];
				if (_eleVals[poiName] != null) {
					_eleVals[poiName] = pv.value.toStringAsFixed(2);
				}
			} else if (pv.deviceId == _selPDU.id) {
				String poiName = global.protocolMapper[pv.id];
				if (_pduVals[poiName] != null) {
					_pduVals[poiName] = pv.value.toStringAsFixed(2);
				}
			}
		}
	});
}