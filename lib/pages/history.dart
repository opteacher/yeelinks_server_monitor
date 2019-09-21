import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:yeelinks/async.dart';
import 'package:yeelinks/components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => HistoryPageState();
}

class HistoryPageState extends BasePageState<Page> {
	final _noBorderRadius = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)));
	final dtFmter = DateFormat("yyyy-MM-dd");

	List<Map<String, String>> _historyRecords = [];
	Map<String, List<Device>> _devices = {};
	String _selType = "选择设备类型";
	int _curPage = 1;
	int _maxItmPerPage = 10;
	int _numPage = 1;
	int _hlfMaxPages = 3;
	DateTime _begTime = DateTime.now().subtract(Duration(days: 5));
	DateTime _endTime = DateTime.now();
	bool _showHistory = true;

	@override
	void initState() {
		global.refreshTimer.register("listDevicesOfHistory", TimerJob(getDevList, hdlDevices, {
			TimerJob.PAGE_IDEN: pageId()
		}));
		global.refreshTimer.register("getDeviceEventHistory", TimerJob(() {
			return getEventHistory(_begTime, _endTime);
		}, hdlPointVals, {
			TimerJob.PAGE_IDEN: pageId(),
			TimerJob.ACTV_IDEN: "1"
		}));
		global.refreshTimer.register("getDeviceEventActive", TimerJob(getEventActive, hdlPointVals, {
			TimerJob.PAGE_IDEN: pageId(),
			TimerJob.ACTV_IDEN: ""
		}));
	}

	List<Widget> _genPages() {
		const pgPdg = const EdgeInsets.symmetric(horizontal: 5);
		const btnWid = 55.0;
		List<Widget> pages = [
			Padding(padding: pgPdg, child: SizedBox(width: btnWid, child: OutlineButton(
				child: Icon(Icons.chevron_left),
				onPressed: _curPage > 1 ? () => setState(() {
					_curPage--;
				}) : null)
			))
		];
		int sttPage = _curPage > _hlfMaxPages ? _curPage - _hlfMaxPages : 1;
		if (sttPage > 1) {
			pages.add(Padding(padding: pgPdg, child: Text("...")));
		}
		int endPage = _curPage < _numPage - _hlfMaxPages - 1 ? _curPage + _hlfMaxPages : _numPage;
		for (int i = sttPage; i <= endPage; i++) {
			if (_curPage == i) {
				pages.add(Padding(padding: pgPdg, child: SizedBox(width: btnWid, child: FlatButton(
					child: Text(i.toString()), onPressed: null
				))));
			} else {
				pages.add(Padding(padding: pgPdg, child: SizedBox(width: btnWid, child: OutlineButton(
					child: Text(i.toString()),
					onPressed: () => setState(() {
						_curPage = i;
					})
				))));
			}
		}
		if (endPage < _numPage) {
			pages.add(Padding(padding: pgPdg, child: Text("...")));
		}
		pages.add(Padding(
			padding: pgPdg,
			child: SizedBox(width: btnWid, child: OutlineButton(
				child: Icon(Icons.chevron_right),
				onPressed: _curPage < _numPage ? () => setState(() {
					_curPage++;
				}) : null)
			)));
		return pages;
	}

	@override
	Widget build(BuildContext context) {
		final primaryColor = Theme.of(context).primaryColor;
		_numPage = (_historyRecords.length ~/ _maxItmPerPage).toInt() + 1;
		var sttIdx = (_curPage - 1) * _maxItmPerPage;
		var endIdx = _historyRecords.length - sttIdx > _maxItmPerPage ? sttIdx + _maxItmPerPage : _historyRecords.length;
		var dispRecords = _historyRecords.isNotEmpty ? _historyRecords.sublist(sttIdx, endIdx) : <Map<String, String>>[];
		return Container(
			padding: const EdgeInsets.all(2.5),
			child: Column(children: <Widget>[
				Row(children: <Widget>[
					Expanded(child: Container(
						padding: EdgeInsets.symmetric(vertical: 8),
						color: primaryColor,
						child: Center(child: Text("历史警告", style: TextStyle(color: Colors.white))),
					)),
					Expanded(child: OutlineButton(
						borderSide: BorderSide(color: primaryColor),
						textColor: primaryColor,
						shape: _noBorderRadius,
						child: Text("历史数据"),
						onPressed: () {}))
				]),
				Expanded(child: Row(children: <Widget>[
					Expanded(child: Column(children: <Widget>[
						Row(children: <Widget>[
							Expanded(child: OutlineButton(
								borderSide: BorderSide(color: Theme.of(context).primaryColor),
								textColor: Theme.of(context).primaryColor,
								shape: _noBorderRadius,
								child: Text(_selType),
								onPressed: () async {
									await showDialog(
										context: context,
										builder: (BuildContext context) {
											List<String> types = _devices.keys.toList();
											return SimpleDialog(children: types.map<Widget>((typ) {
												return SimpleDialogOption(child: Text(typ), onPressed: () => setState(() {
													_selType = typ;
													Navigator.pop(context);
												}));
											}).toList());
										}
									);
								}))
						]),
						Expanded(child: Container(
							padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
							decoration: BoxDecoration(
								border: Border.all(color: Theme.of(context).primaryColor)
							),
							child: ListView(children: (_selType != "选择设备类型" && _devices.isNotEmpty ?
								_devices[_selType].map<Widget>((device) {
									if (global.currentDevID == device.id) {
										return FlatButton(
											disabledColor: primaryColor,
											disabledTextColor: Colors.white,
											child: Text(device.name),
											onPressed: null);
									} else {
										return OutlineButton(
											borderSide: BorderSide(color: primaryColor),
											child: Text(device.name, style: TextStyle(color: primaryColor)),
											onPressed: () => setState(() {
												global.currentDevID = device.id;
												_curPage = 1;
											}));
									}
								}).toList() : []
							))
						))
					])),
					Expanded(flex: 3, child: Padding(padding: EdgeInsets.only(left: 5), child: Column(children: <Widget>[
						Row(children: <Widget>[
							OutlineButton(
								borderSide: BorderSide(color: primaryColor),
								child: Text(dtFmter.format(_begTime), style: TextStyle(color: primaryColor)),
								onPressed: () async {
									DateTime pkTime = await showDatePicker(
										context: context,
										initialDate: _begTime,
										firstDate: DateTime(2000),
										lastDate: DateTime(2050)
									);
									if (pkTime != null) {
										setState(() {
											_begTime = pkTime;
										});
									}
								}
							),
							Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("-")),
							OutlineButton(
								borderSide: BorderSide(color: primaryColor),
								child: Text(dtFmter.format(_endTime), style: TextStyle(color: primaryColor)),
								onPressed: () async {
									DateTime pkTime = await showDatePicker(
										context: context,
										initialDate: _endTime,
										firstDate: DateTime(2000),
										lastDate: DateTime(2050)
									);
									if (pkTime != null) {
										setState(() {
											_endTime = pkTime;
										});
									}
								}
							),
							Padding(padding: EdgeInsets.only(left: 10), child: Text(_showHistory ? "历史数据" : "实时数据")),
							Switch(activeColor: primaryColor, onChanged: (bool value) => setState(() {
								_showHistory = !_showHistory;
								global.refreshTimer.getJob("getDeviceEventHistory").doActive(_showHistory);
								global.refreshTimer.getJob("getDeviceEventActive").doActive(!_showHistory);
								_curPage = 1;
							}), value: _showHistory)
						]),
						Padding(padding: EdgeInsets.all(10), child: Column(children: <Widget>[
							MyDataTable({
								"等级": MyDataHeader("level", 0.05),
								"设备": MyDataHeader("name", 0.1),
								"标题": MyDataHeader("warning", 0.15),
								"说明": MyDataHeader("meaning", 0.25),
								"生成时间": MyDataHeader("start", 0.175),
								"解除时间": MyDataHeader("confirm", 0.175),
								"状态": MyDataHeader("status", 0.1)
							}, dispRecords,
								vpadding: 5.0, isStriped: true, hasBorder: false,
								headerTxtStyle: const TextStyle(fontSize: 15.0),
								bodyTxtStyle: const TextStyle(fontSize: 15.0)
							),
							Row(mainAxisAlignment: MainAxisAlignment.end, children: _genPages())
						]))
					])))
				]))
			])
		);
	}

	@override
	String pageId() => "history";

	@override
	void hdlDevices(data) => setState(() {
		_devices.clear();
		if (data == null || data.isEmpty) {
			return;
		}
		for (var device in data) {
			if (_devices[device.typeStr] == null) {
				_devices[device.typeStr] = [];
			}
			_devices[device.typeStr].add(device);
		}
	});

	@override
	void hdlPointVals(dynamic data) => setState(() {
		_historyRecords = [];
		for (EventRecord er in data) {
			_historyRecords.add(er.toMap());
		}
	});
}