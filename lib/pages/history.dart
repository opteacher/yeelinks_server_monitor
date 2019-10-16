import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:yeelinks/async.dart';
import 'package:yeelinks/components.dart';
import '../global.dart' as global;
import 'package:charts_flutter/flutter.dart' as charts;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => HistoryPageState();
}

class HistoryPageState extends BasePageState<Page> {
	final _noBorderRadius = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)));
	final _WngClrLvlMap = <String, Color>{
		"0": Colors.grey,
		"1": Colors.yellow,
		"2": Colors.amber,
		"3": Colors.orange,
		"4": Colors.red,
		"5": Colors.purple
	};

	bool _historyPanel = true;
	List<Map<String, String>> _events = [];
	Map<String, List<Device>> _devices = {};
	String _selType = "选择设备类型";
	int _curPage = 1;
	int _maxItmPerPage = 10;
	int _numPage = 1;
	int _hlfMaxPages = 3;
	DateTime _begTime = DateTime.now().subtract(Duration(days: 1));
	DateTime _endTime = DateTime.now();
	bool _showActive = true;
	List<DevPoint> _devPoints = [];
	List<TimeSeriesSales> _poiVals = [TimeSeriesSales(DateTime.now(), 0)];
	int _selPoi = 0;

	@override
	void initState() {
		global.refreshTimer.register("listDevicesOfHistory", TimerJob(getDevList, hdlDevices, {
			TimerJob.PAGE_IDEN: pageId()
		}));
		global.refreshTimer.register("getDeviceEventHistory", TimerJob(() {
			return getEventHistory(_begTime, _endTime);
		}, hdlEvents, {
			TimerJob.PAGE_IDEN: pageId(),
			TimerJob.ACTV_IDEN: ""
		}));
		global.refreshTimer.register("getDeviceEventActive", TimerJob(getEventActive, hdlEvents, {
			TimerJob.PAGE_IDEN: pageId(),
			TimerJob.ACTV_IDEN: "1"
		}));
		global.refreshTimer.register("getDevicePointHistory", TimerJob(() {
			return getDevPoiHistory([_selPoi], _begTime, _endTime);
		}, hdlPointVals, {
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

	List<Widget> _genCompRdoGrp() {
		return _devPoints.map<Widget>((poi) => RadioListTile(
			activeColor: Theme.of(context).primaryColor,
			title: Text(poi.name, style: TextStyle(color: Colors.grey[600])),
			value: poi.poiID,
			groupValue: _selPoi,
			onChanged: (int value) {
				setState(() { _selPoi = value; });
				global.refreshTimer.refresh(context, global.currentDevID, null);
			}
		)).toList();
	}

	Widget _genToolbar() {
		final primaryColor = Theme.of(context).primaryColor;
		return Row(children: <Widget>[
			OutlineButton(
				borderSide: BorderSide(color: primaryColor),
				child: Text(global.dtFmter.format(_begTime), style: TextStyle(color: primaryColor)),
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
						global.refreshTimer.refresh(context, global.currentDevID, null);
					}
				}
			),
			Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("-")),
			OutlineButton(
				borderSide: BorderSide(color: primaryColor),
				child: Text(global.dtFmter.format(_endTime), style: TextStyle(color: primaryColor)),
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
						global.refreshTimer.refresh(context, global.currentDevID, null);
					}
				}
			),
			_historyPanel ? Row(children: <Widget>[
				Padding(padding: EdgeInsets.only(left: 10), child: Text(!_showActive ? "历史数据" : "实时数据")),
				Switch(activeColor: primaryColor, onChanged: (bool value) => setState(() {
					_showActive = !_showActive;
					global.refreshTimer.getJob("getDeviceEventHistory").doActive(!_showActive);
					global.refreshTimer.getJob("getDeviceEventActive").doActive(_showActive);
					_curPage = 1;
					global.refreshTimer.refresh(context, global.currentDevID, null);
				}), value: _showActive)
			]) : Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
				Text("*点位栏可滚动", style: TextStyle(color: primaryColor))
			]))
		]);
	}

	@override
	Widget build(BuildContext context) {
		final primaryColor = Theme.of(context).primaryColor;
		_numPage = (_events.length ~/ _maxItmPerPage).toInt() + 1;
		var sttIdx = (_curPage - 1) * _maxItmPerPage;
		var endIdx = _events.length - sttIdx > _maxItmPerPage ? sttIdx + _maxItmPerPage : _events.length;
		var dispRecords = _events.isNotEmpty ? _events.sublist(sttIdx, endIdx) : <Map<String, String>>[];
		List<Widget> subPanel = [_genToolbar()];
		if (_historyPanel) {
//			subPanel.addAll([
//				MyDataTable({
//					"等级": MyDataHeader("level", 0.05),
//					"设备": MyDataHeader("name", 0.1),
//					"标题": MyDataHeader("warning", 0.15),
//					"说明": MyDataHeader("meaning", 0.25),
//					"生成时间": MyDataHeader("start", 0.175),
//					"解除时间": MyDataHeader("check", 0.175),
//					"状态": MyDataHeader("status", 0.1)
//				}, dispRecords,
//					vpadding: 5.0, isStriped: true, hasBorder: false,
//					headerTxtStyle: const TextStyle(fontSize: 15.0),
//					bodyTxtStyle: const TextStyle(fontSize: 15.0)
//				),
//				Row(mainAxisAlignment: MainAxisAlignment.end, children: _genPages())
//			]);
			final Color txtClr = Colors.grey[600];
			final String operator = _showActive ? "check" : "unchain";
			subPanel.add(Expanded(child: ListView(children: _events.map<Widget>((rcd) => Card(
				elevation: 0,
				color: Colors.grey[100],
				child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), child: Row(children: <Widget>[
					Padding(padding: EdgeInsets.only(right: 20), child: Center(
						child: Icon(Icons.info, size: 40, color: _WngClrLvlMap[rcd["level"]])
					)),
					Expanded(child: Column(children: <Widget>[
						Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
							Text(rcd["name"], style: TextStyle(color: txtClr))
						]),
						Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
							Text("${rcd["warning"]} : ", style: TextStyle(fontSize: 25, color: txtClr)),
							Flexible(child: Text(rcd["meaning"], style: TextStyle(fontSize: 20, color: txtClr)))
						]),
						Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
							Text(rcd["${operator}er"].isEmpty ? "-" : rcd["${operator}er"], style: TextStyle(color: txtClr))
						]),
					])),
					Column(children: <Widget>[
						Text(rcd["start"], style: TextStyle(color: txtClr)),
						Text("", style: TextStyle(fontSize: 25, color: txtClr)),
						Text(rcd[operator] == "null" ? "-" : global.dttmFmter.format(
							global.dttmParser.parse(rcd[operator])
						), style: TextStyle(color: txtClr)),
					])
				]))
			)).toList())));
		} else {
			subPanel.addAll([
				Container(height: 150, decoration: BoxDecoration(
					border: Border.all(color: primaryColor),
				), child: GridView.count(
					crossAxisCount: 4,
					childAspectRatio: 5,
					children: _genCompRdoGrp(),
				)),
				Flexible(child: Padding(padding: EdgeInsets.all(10), child: charts.TimeSeriesChart(
					[
						charts.Series<TimeSeriesSales, DateTime>(
							id: "Sales",
							colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
							domainFn: (TimeSeriesSales sales, _) => sales.time,
							measureFn: (TimeSeriesSales sales, _) => sales.sales,
							data: _poiVals,
						)
					],
					animate: false,
					dateTimeFactory: const charts.LocalDateTimeFactory(),
				)))
			]);
		}
		return Container(
			padding: const EdgeInsets.all(2.5),
			child: Column(children: <Widget>[
				Row(children: <Widget>[
					_historyPanel ? Expanded(child: Container(
						padding: EdgeInsets.symmetric(vertical: 8),
						color: primaryColor,
						child: Center(child: Text("历史告警", style: TextStyle(color: Colors.white))),
					)) : Expanded(child: OutlineButton(
						borderSide: BorderSide(color: primaryColor),
						textColor: primaryColor,
						shape: _noBorderRadius,
						child: Text("历史告警"),
						onPressed: () => setState(() {
							_historyPanel = true;
							global.refreshTimer.getJob("getDevicePointHistory").doActive(false);
						}))
					),
					_historyPanel ? Expanded(child: OutlineButton(
						borderSide: BorderSide(color: primaryColor),
						textColor: primaryColor,
						shape: _noBorderRadius,
						child: Text("历史数据"),
						onPressed: () async {
							List<DevPoint> points = [];
							if (global.currentDevID.isNotEmpty) {
								ResponseInfo ri = await getDevPoints();
								if (ri.data != null) {
									points = ri.data;
								}
							}
							setState(() {
								_devPoints = points;
								_historyPanel = false;
								global.refreshTimer.getJob("getDevicePointHistory").doActive(true);
							});
						})
					) : Expanded(child: Container(
						padding: EdgeInsets.symmetric(vertical: 8),
						color: primaryColor,
						child: Center(child: Text("历史数据", style: TextStyle(color: Colors.white))),
					))
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
											onPressed: null
										);
									} else {
										return OutlineButton(
											borderSide: BorderSide(color: primaryColor),
											child: Text(device.name, style: TextStyle(color: primaryColor)),
											onPressed: () {
												global.refreshTimer.refresh(context, device.id, () async {
													ResponseInfo ri = await getDevPoints();
													setState(() {
														_curPage = 1;
														_devPoints = ri.data != null ? ri.data : [];
														_poiVals = [];
													});
												});
											}
										);
									}
								}).toList() : []
							))
						))
					])),
					Expanded(flex: 3, child: Padding(padding: EdgeInsets.only(left: 5), child: Column(children: subPanel)))
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
		for (Device device in data) {
			if (_devices[device.typeStr] == null) {
				_devices[device.typeStr] = [];
			}
			if (device.status != 1) {
				continue;
			}
			_devices[device.typeStr].add(device);
		}
	});

	void hdlEvents(dynamic data) => setState(() {
		_events = [];
		for (EventRecord er in data) {
			_events.add(er.toMap());
		}
	});

	@override
	void hdlPointVals(dynamic data) {
		if (data[_selPoi.toString()] != null) {
			setState(() {
				_poiVals = data[_selPoi.toString()];
			});
		}
	}
}