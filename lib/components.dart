import 'dart:async';
import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toast/toast.dart';
import 'async.dart';
import 'global.dart' as global;
import 'pages/home.dart' as home;
import 'dart:ui' as ui;

class DataCard extends StatelessWidget {
	final String title;
	final Widget child;
	final Widget tailing;
	final int flex;
	final double height;

	DataCard({this.title, this.child, this.tailing = null, this.flex = 1, this.height = -1});

	@override
	Widget build(BuildContext context) {
		final titleStyle = TextStyle(fontSize: 25.0, color: Theme.of(context).primaryColor);
		final dataCard = Card(elevation: 0, child: Container(decoration: BoxDecoration(
			border: Border.all(color: Theme.of(context).primaryColor)
		), child: title == null ? Expanded(child: child) : Column(children: <Widget>[
			Container(padding: EdgeInsets.symmetric(horizontal: 20.0), height: 50.0, color: Theme.of(context).primaryColorLight,
				child: tailing == null ? Center(child: Text(title, style: titleStyle)) : Row(children: <Widget>[
					Expanded(child: Text(title, style: titleStyle)), tailing
				])
			),
			// NOTE: 将Divider的高度设为0，可以让分割线的上下间隔去掉
//			Divider(height: 0),
			Expanded(child: child)
		])));
		return height == -1 ? Expanded(flex: flex, child: dataCard) : Container(height: height, child: dataCard);
	}
}

class DescListItemTitle {
	final String text;
	final double size;
	final Color color;

	DescListItemTitle(this.text, {this.size = 20.0, this.color = const Color(0xFF757575)});
}

class DescListItemContent {
	final String text;
	bool blocked;
	Color color;
	EdgeInsets padding;

	DescListItemContent(this.text, {
		this.blocked = false,
		this.color = Colors.blueAccent,
		double left = 0.0, double top = 0.0,
		double right = 0.0, bottom = 0.0,
		double horizontal = 0.0, double vertical = 0.0
	}) {
		if (horizontal != 0.0 || vertical != 0.0) {
			padding = EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal);
		} else {
			padding = EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
		}
	}
}

class DescListItemSuffix {
	final String text;
	Color color;

	DescListItemSuffix({this.text = "", this.color = const Color(0xFF757575)});
}

class DescListItem extends StatelessWidget {
	final DescListItemTitle title;
	final DescListItemContent content;
	DescListItemSuffix suffix;
	EdgeInsets outPadding;
	TextAlign contentAlign;
	double titleWidth;

	DescListItem(this.title, this.content, {
		this.suffix = null,
		double left = 0.0, double top = 0.0,
		double right = 0.0, bottom = 0.0,
		double horizontal = 0.0, double vertical = 0.0,
		this.contentAlign = TextAlign.left,
		this.titleWidth = -1
	}) {
		if (suffix == null) {
			suffix = DescListItemSuffix();
		}
		if (horizontal != 0.0 || vertical != 0.0) {
			outPadding = EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal);
		} else {
			outPadding = EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
		}
	}

	@override
	Widget build(BuildContext context) {
		var ttl = Text(title.text, style: TextStyle(fontSize: title.size, color: title.color));
		List<Widget> children = [
			titleWidth == -1 ? Expanded(child: ttl) : Container(width: titleWidth, child: ttl)
		];
		var ctt = [
			Padding(padding: content.padding, child: Text(content.text, style: TextStyle(fontSize: title.size, color: content.color), textAlign: contentAlign)),
			suffix.text.isNotEmpty ? Text(suffix.text, style: TextStyle(fontSize: title.size, color: suffix.color), textAlign: contentAlign) : Text(" ")
		];
		if (content.blocked) {
			children.add(Container(
				padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
				decoration: BoxDecoration(
					color: Colors.grey[100],
					borderRadius: BorderRadius.all(Radius.circular(4))
				),
				child: Row(children: ctt)
			));
		} else {
			children.addAll(ctt);
		}
		return Expanded(child: Padding(padding: outPadding, child: Row(children: children)));
	}
}

class Instrument extends StatelessWidget {
	double _radius;
	double _max;
	double _min;
	int _numScales;
	Map<Offset, Color> _scalesColor;
	double _value = 0.0;
	String _suffix;

	Instrument({
		double radius,
		int numScales,
		double max,
		double min = 0.0,
		Map<Offset, Color> scalesColor = const {},
		String suffix = "",
		double value = 0.0
	}): _radius = radius, _max = max, _min = min, _numScales = numScales,
			_scalesColor = scalesColor, _value = value, _suffix = suffix;

	@override
	Widget build(BuildContext context) => Center(child: Column(children: <Widget>[
		CustomPaint(
			size: Size(2 * _radius, 1.5 * _radius),
			painter: InstrumentGraph(_radius, _numScales, _max, _min, _scalesColor)
				..updateValue(_value),
		),
		Text(
			_value.toStringAsFixed(2) + " $_suffix",
			style: TextStyle(fontSize: 35.0, color: Colors.blueAccent)
		)
	]));

}

class InstrumentGraph extends CustomPainter {
	final double radius;
	final int numScales;
	final double max;
	final double min;
	final Map<Offset, Color> scalesColor;
	double poiLen;
	final double poiWid = 5.0;
	double _angle = -210.0;

	InstrumentGraph(this.radius, this.numScales, this.max, this.min, this.scalesColor) {
		this.poiLen = radius * 0.6;
	}

	void updateValue(double value) {
		double tmp = ((value - min) / (max - min) * 240) - 210;
		if (tmp < -210) {
			_angle = -210;
		} else if (tmp > 30) {
			_angle = 30;
		} else {
			_angle = tmp;
		}
	}

	@override
	void paint(Canvas canvas, Size size) {
		const rate = pi / 180;
		final center = Offset(radius, radius);
		// 绘制背景
		Paint _paint = Paint()
			..color = Colors.grey[200];
//		canvas.drawCircle(center, radius, _paint);
		// 绘制总数据段
		_paint
			..style = PaintingStyle.stroke
			..strokeWidth = 10.0
			..color = Colors.green[400];
		canvas.drawArc(Rect.fromCircle(
			center: center,
			radius: radius
		), -210.0 * rate, 240 * rate, false, _paint);
		// 绘制颜色段
		final rangeRate = 1 / (max - min);
		for (Offset range in scalesColor.keys.toList()) {
			double aglRng = (range.dy - range.dx) * rangeRate * 240;
			double aglBeg = rangeRate * (range.dx - min) * 240 - 210;
			_paint.color = scalesColor[range];
			canvas.drawArc(Rect.fromCircle(
				center: center,
				radius: radius - 10
			), aglBeg * rate, aglRng * rate, false, _paint);
		}
		// 绘制刻度
		final scale = 240.0 / numScales;
		_paint
			..color = Colors.green[400]
			..strokeWidth = 20.0;
		var _tpaint = TextPainter(text: TextSpan(
			text: "0",
			style: TextStyle(color: Colors.green[400])
		),
			textDirection: TextDirection.ltr,
			textAlign: TextAlign.center
		)
			..layout();
		final wdsLen = radius * 0.75;
		final dt = (max - min) / numScales.toDouble();
		int fixed = 0;
		if (dt - dt.toInt() != 0) {
			final dtStr = dt.toStringAsFixed(1);
			fixed = dt == double.parse(dtStr) ? 1 : 2;
		}
		for (double a = -211, t = min; a <= 30 && t <= max; a += scale, t += dt) {
			canvas.drawArc(Rect.fromCircle(
				center: center,
				radius: radius - 5
			), a * rate, 2 * rate, false, _paint);
			_tpaint
				..text = TextSpan(
					text: t.toStringAsFixed(fixed),
					style: TextStyle(color: Colors.green[400])
				)
				..layout();
			var dx = radius + wdsLen * cos(a * rate) - (_tpaint.width / 2);
			var dy = radius + wdsLen * sin(a * rate) - (_tpaint.height / 2);
			_tpaint.paint(canvas, Offset(dx, dy));
		}
		// 画指针
		_paint.color = Colors.orangeAccent;
		final agCos = cos(_angle * rate);
		final agSin = sin(_angle * rate);
		final dw = 20 / poiLen;
		for (double l = 1, w = 20; l <= poiLen; l++, w -= dw) {
			canvas.drawLine(center, Offset(radius + l * agCos, radius + l * agSin), _paint
				..strokeWidth = w);
		}
		_paint
			..strokeWidth = 20
			..color = Colors.green[400];
		canvas.drawCircle(center, 5, _paint);
	}

	@override
	bool shouldRepaint(InstrumentGraph oldDelegate) => true;
}

class SimpleTimeSeriesChart extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => SimpleTimeSeriesChartState();
}

class SimpleTimeSeriesChartState extends State<SimpleTimeSeriesChart> {
	List<TimeSeriesSales> _humis = [TimeSeriesSales(DateTime.now(), 0)];
	List<TimeSeriesSales> _temps = [TimeSeriesSales(DateTime.now(), 0)];
	TimeSectionEnum _active = TimeSectionEnum.in1Hour;

	@override
	void initState() {
		super.initState();
		global.refreshTimer.register("tempHumiChartInEnv", TimerJob(() {
			return getTempHumi(_active.index + 1);
		}, (dynamic data) => setState(() {
			_humis = data["humis"].toList();
			_temps = data["temps"].toList();
		})));
	}

	@override
	Widget build(BuildContext context) => Column(children: <Widget>[
		Row(children: _genRadios()),
		Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("温度")]),
		Expanded(child: charts.TimeSeriesChart(
			[
				charts.Series<TimeSeriesSales, DateTime>(
					id: "Sales",
					colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
					domainFn: (TimeSeriesSales sales, _) => sales.time,
					measureFn: (TimeSeriesSales sales, _) => sales.sales,
					data: _temps,
				)
			],
			animate: false,
			dateTimeFactory: const charts.LocalDateTimeFactory(),
		)),
		Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("湿度")]),
		Expanded(child: charts.TimeSeriesChart(
			[
				charts.Series<TimeSeriesSales, DateTime>(
					id: "Sales",
					colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
					domainFn: (TimeSeriesSales sales, _) => sales.time,
					measureFn: (TimeSeriesSales sales, _) => sales.sales,
					data: _humis,
				)
			],
			animate: false,
			dateTimeFactory: const charts.LocalDateTimeFactory(),
		))
	]);

	List<Widget> _genRadios() {
		List<Widget> ret = <Widget>[];
		for (var ele in TimeSectionEnum.values) {
			ret.add(Flexible(child: RadioListTile(
				title: Text(TimeSectionDescs[ele]),
				value: ele,
				groupValue: _active,
				onChanged: (TimeSectionEnum value) {
					setState(() { _active = value; });
					global.refreshTimer.refresh(context, global.currentDevID, null);
				})
			));
		}
		return ret;
	}
}

class TimeSeriesSales {
	final DateTime time;
	final double sales;

	TimeSeriesSales(this.time, this.sales);
}

enum TimeSectionEnum {
	in1Hour, in24Hours, in1Mon
}

const Map<TimeSectionEnum, String> TimeSectionDescs = {
	TimeSectionEnum.in1Hour: "1 h",
	TimeSectionEnum.in24Hours: "24 h",
	TimeSectionEnum.in1Mon: "1 mon"
};

class MyDataHeader {
	final String _key;
	double _width;

	MyDataHeader(this._key, [this._width = 0.0]);
}

class MyDataTable extends StatelessWidget {
	final Map<String, MyDataHeader> _header;
	final List<Map<String, String>> _data;
	final bool hasBorder;
	final bool isStriped;
	EdgeInsetsGeometry _padding;
	final _border = BorderSide(color: Colors.grey[300]);
	final headerTxtStyle;
	final bodyTxtStyle;

	MyDataTable(this._header, this._data, {
		this.hasBorder = true,
		this.isStriped = false,
		double vpadding = 0,
		double hpadding = 0,
		this.headerTxtStyle = const TextStyle(fontSize: 20),
		this.bodyTxtStyle = const TextStyle(fontSize: 20)
	}) {
		_padding = EdgeInsets.symmetric(
			vertical: vpadding,
			horizontal: hpadding
		);
	}
	
	@override
	Widget build(BuildContext context) {
		var headerList = _header.keys.toList();
		List<TableRow> rows = [
			_genRow(headerList, txtStyle: headerTxtStyle)
		];
		_data.asMap().forEach((index, item) {
			List<String> row = [];
			_header.forEach((_, rel) {
				row.add(item[rel._key]);
			});
			rows.add(_genRow(row, striped: isStriped && index.isEven));
		});
		var columnWidth = 1 / headerList.length;
		Map<int, TableColumnWidth> columnWidths = {};
		headerList.asMap().forEach((index, key) {
			if (_header[key]._width == 0) {
				_header[key]._width = columnWidth;
			}
			columnWidths[index] = FractionColumnWidth(_header[key]._width);
		});
//		return Scrollbar(child: ListView(children: <Widget>[
//			SingleChildScrollView(
//				scrollDirection: Axis.horizontal,
//				child: Table(
//					columnWidths: columnWidths,
//					border: hasBorder ? TableBorder.symmetric(inside: _border) : null,
//					defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//					children: rows
//				)
//			)
//		]));
		return Table(
			columnWidths: columnWidths,
			border: hasBorder ? TableBorder.symmetric(inside: _border) : null,
			defaultVerticalAlignment: TableCellVerticalAlignment.middle,
			children: rows
		);
	}

	TableRow _genRow(List<String> data, {bool striped = false, TextStyle txtStyle}) {
		if (txtStyle == null) {
			txtStyle = bodyTxtStyle;
		}
		List<Widget> children = data.map<Widget>((ele) => _genCell(ele, txtStyle)).toList();
		if (striped) {
			return TableRow(decoration: BoxDecoration(color: Colors.grey[300]), children: children);
		} else {
			return TableRow(children: children);
		}
	}

	Widget _genCell(String content, TextStyle txtStyle) {
		return Padding(padding: _padding, child: Center(child: Text(
			"\u3000" + content + "\u3000", style: txtStyle
		)));
	}
}

abstract class BasePageState<T extends StatefulWidget> extends State<T> {
	@override
	void initState() {
		super.initState();
		String pid = pageId();
		global.refreshTimer.register("devPageOf${pid.toUpperCase()}", TimerJob(() {
			return getDevices(global.componentInfos[pid].index);
		}, hdlDevices, { TimerJob.PAGE_IDEN: pid }));
		global.refreshTimer.register("poiValueOf${pid.toUpperCase()}", TimerJob(() {
			return getPointSensor(global.idenDevs);
		}, hdlPointVals, { TimerJob.PAGE_IDEN: pid }));
	}

	String pageId();

	void hdlDevices(dynamic data);

	void hdlPointVals(dynamic data);
}

class TimerJob {
	final Future<dynamic> Function() _job;
	final void Function(dynamic) _callback;
	final Map<String, String> _conditions;
	static const String PAGE_IDEN = "page_iden";
	static const String ACTV_IDEN = "active_iden";

	TimerJob(this._job, this._callback, [this._conditions = const <String, String>{}]);

	doActive(bool active) {
		if (_conditions[ACTV_IDEN] != null) {
			_conditions[ACTV_IDEN] = active ? "1" : "";
		}
	}
}

class RefreshTimer {
	Timer _timer;
	String _idenPrefix = "";
	Map<String, TimerJob> _jobs = {
		"alarmLighter": TimerJob(hasAlarms, (dynamic data) {
			if (data) {
				global.ledCtrl.invokeMethod("lightUp", {
					"color": "RED", "brightness": 50
				});
			} else {
				global.ledCtrl.invokeMethod("lightUp", {
					"color": "GREEN", "brightness": 50
				});
			}
		})
	};

	register(String id, TimerJob job) {
		_jobs[id] = job;
	}

	start() async {
		await _refresh(null);
		if (_timer == null || !_timer.isActive) {
			_timer = Timer.periodic(const Duration(seconds: 2), _refresh);
		}
	}

	bool isStarted() {
		return _timer != null && _timer.isActive;
	}

	stop() {
		_timer.cancel();
	}

	_refresh(Timer t) async {
		for (var id in _jobs.keys.toList()) {
			if (_idenPrefix.isNotEmpty) {
				if (!id.startsWith(_idenPrefix)) {
					continue;
				}
			}
			var job = _jobs[id];
			if (job._conditions[TimerJob.PAGE_IDEN] != null) {
				if (job._conditions[TimerJob.PAGE_IDEN] != global.currentPageID) {
					continue;
				}
			}
			if (job._conditions[TimerJob.ACTV_IDEN] != null) {
				if (job._conditions[TimerJob.ACTV_IDEN].isEmpty) {
					continue;
				}
			}

			ResponseInfo ri = await job._job();
			if (ri == null || ri.data == null) {
				continue;
			}
			print(ri.data);
			if (job._callback != null) {
				job._callback(ri.data);
			}
		}
		_idenPrefix = "";
	}

	refreshIdenPrefix(String prefix) async {
		_idenPrefix = prefix;
		await _refresh(null);
	}

	cancel() => _timer.cancel();

	TimerJob getJob(String iden) => _jobs[iden];

	refresh(BuildContext context, String selDevID, Future<dynamic> Function() callback) async {
		showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => SimpleDialog(
			elevation: 0,
			backgroundColor: Colors.transparent,
			children: <Widget>[
				SpinKitFadingCircle(color: Colors.white, size: 100)
			]
		));

		global.currentDevID = selDevID;
		// 暂停所有定时任务
		stop();
		// 有回调则执行
		if (callback != null) {
			await callback();
		}
		// 根据收到的数据调整当前设备，并再次启动定时任务
		await start();

		Navigator.pop(context);
	}
}

class PageSwitchRoute extends PageRouteBuilder {
	final Widget _to;

	PageSwitchRoute(this._to): super(pageBuilder: (
		BuildContext context,
		Animation<double> animation,
		Animation<double> secondaryAnimation
	) => _to, transitionsBuilder: (
		BuildContext context,
		Animation<double> animation,
		Animation<double> secondaryAnimation,
		Widget child
	) => FadeTransition(opacity: animation, child: child));
}

class UpsRunningMod extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => UpsRunningModState();
}

class UpsRunningModState extends State<UpsRunningMod> {
	ui.Image _imgBYPASS;
	ui.Image _imgInput;
	ui.Image _imgACDC;
	ui.Image _imgDCAC;
	ui.Image _imgBatt;

	@override
	Widget build(BuildContext context) => Center(child: CustomPaint(
		size: Size(400, 400),
		painter: UpsRunningModPainter( _imgBYPASS, _imgInput, _imgACDC, _imgDCAC, _imgBatt)
	));

	@override
	void initState() {
		super.initState();
		_loadResources();
	}

	void _loadResources() async {
		_imgBYPASS = await _loadImage("images/bypass.png");
		_imgInput = await _loadImage("images/input.png");
		_imgACDC = await _loadImage("images/acdc.png");
		_imgDCAC = await _loadImage("images/dcac.png");
		_imgBatt = await _loadImage("images/batt.png");
	}

	Future<ui.Image> _loadImage(String asset) async {
		ByteData data = await rootBundle.load(asset);
		ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
		ui.FrameInfo fi = await codec.getNextFrame();
		return fi.image;
	}
}

class UpsRunningModPainter extends CustomPainter {
	final ui.Image _imgBYPASS;
	final ui.Image _imgInput;
	final ui.Image _imgACDC;
	final ui.Image _imgDCAC;
	final ui.Image _imgBatt;

	UpsRunningModPainter(this._imgBYPASS, this._imgInput, this._imgACDC, this._imgDCAC, this._imgBatt);

	@override
	void paint(Canvas canvas, Size size) {
		if (_imgBYPASS == null || _imgInput == null || _imgACDC == null || _imgDCAC == null || _imgBatt == null) {
			return;
		}

		double lblkWid = 100;
		double sblkWid = 50;
		double blkHgt = 50;
		double hfWid = size.width / 2;
		double ofWid = hfWid / 2;
		double margin = (ofWid - sblkWid) / 2;
		double otHgt = size.height / 4;

		Paint _paint = Paint()
			..color = Color(0xffc2c2c2);

		// 画链路
		Path path = Path();
		_paint
			..style = PaintingStyle.stroke
			..strokeWidth = 10;
		double hfBlkWid = lblkWid / 2;
		double hfBlkHgt = blkHgt / 2;
		path.moveTo(hfWid - hfBlkWid, hfBlkHgt);
		path.lineTo(ofWid, hfBlkHgt);
		path.lineTo(ofWid, otHgt + hfBlkHgt);
		canvas.drawPath(path, _paint);

		path.reset();
		double tfWid = ofWid * 3;
		path.moveTo(hfWid + hfBlkWid, hfBlkHgt);
		path.lineTo(tfWid, hfBlkHgt);
		path.lineTo(tfWid, otHgt + hfBlkHgt);
		canvas.drawPath(path, _paint);

		canvas.drawLine(
			Offset(margin + sblkWid, otHgt + hfBlkHgt),
			Offset(margin + ofWid, otHgt + hfBlkHgt), _paint);

		canvas.drawLine(
			Offset(hfWid - margin, otHgt + hfBlkHgt),
			Offset(hfWid + margin, otHgt + hfBlkHgt), _paint);

		canvas.drawLine(
			Offset(margin + hfWid + sblkWid, otHgt + hfBlkHgt),
			Offset(margin + hfWid + ofWid, otHgt + hfBlkHgt), _paint);

		canvas.drawLine(
			Offset(hfWid, otHgt + hfBlkHgt),
			Offset(hfWid, otHgt * 2), _paint);

		// 画激活的链路
		switch (global.upsMode) {
			case 19456:// 在线模式
				_paint.color = Color(0xff3dcd58);

				canvas.drawLine(
					Offset(margin + sblkWid, otHgt + hfBlkHgt),
					Offset(margin + ofWid, otHgt + hfBlkHgt), _paint);

				canvas.drawLine(
					Offset(hfWid - margin, otHgt + hfBlkHgt),
					Offset(hfWid + margin, otHgt + hfBlkHgt), _paint);

				canvas.drawLine(
					Offset(margin + hfWid + sblkWid, otHgt + hfBlkHgt),
					Offset(margin + hfWid + ofWid, otHgt + hfBlkHgt), _paint);
				break;
			case 16896:// 电池模式
				_paint.color = Color(0xff3dcd58);

				canvas.drawLine(
					Offset(hfWid, otHgt + hfBlkHgt),
					Offset(hfWid + margin, otHgt + hfBlkHgt), _paint);

				canvas.drawLine(
					Offset(margin + hfWid + sblkWid, otHgt + hfBlkHgt),
					Offset(margin + hfWid + ofWid, otHgt + hfBlkHgt), _paint);

				canvas.drawLine(
					Offset(hfWid, otHgt + hfBlkHgt - 5),
					Offset(hfWid, otHgt * 2), _paint);
				break;
			case 22784:// 旁路模式
				_paint.color = Color(0xff3dcd58);

				path.moveTo(hfWid - hfBlkWid, hfBlkHgt);
				path.lineTo(ofWid, hfBlkHgt);
				path.lineTo(ofWid, otHgt + hfBlkHgt);
				path.lineTo(margin + sblkWid, otHgt + hfBlkHgt);
				canvas.drawPath(path, _paint);

				path.reset();
				path.moveTo(hfWid + hfBlkWid, hfBlkHgt);
				path.lineTo(tfWid, hfBlkHgt);
				path.lineTo(tfWid, otHgt + hfBlkHgt);
				path.lineTo(margin + hfWid + ofWid, otHgt + hfBlkHgt);
				canvas.drawPath(path, _paint);
				break;
		}

		// 画各个模块
		canvas.drawImageRect(_imgBYPASS,
			Rect.fromLTWH(0, 0, _imgBYPASS.width.toDouble(), _imgBYPASS.height.toDouble()),
			Rect.fromLTWH(hfWid - lblkWid / 2, 0, lblkWid, blkHgt),
			_paint);
		canvas.drawImageRect(_imgInput,
			Rect.fromLTWH(0, 0, _imgInput.width.toDouble(), _imgInput.height.toDouble()),
			Rect.fromLTWH(margin, otHgt, sblkWid, blkHgt),
			_paint);
		canvas.drawImageRect(_imgACDC,
			Rect.fromLTWH(0, 0, _imgACDC.width.toDouble(), _imgACDC.height.toDouble()),
			Rect.fromLTWH(margin + ofWid, otHgt, sblkWid, blkHgt),
			_paint);
		canvas.drawImageRect(_imgDCAC,
			Rect.fromLTWH(0, 0, _imgDCAC.width.toDouble(), _imgDCAC.height.toDouble()),
			Rect.fromLTWH(margin + hfWid, otHgt, sblkWid, blkHgt),
			_paint);
		canvas.drawImageRect(_imgInput,
			Rect.fromLTWH(0, 0, _imgInput.width.toDouble(), _imgInput.height.toDouble()),
			Rect.fromLTWH(margin + hfWid + ofWid, otHgt, sblkWid, blkHgt),
			_paint);
		canvas.drawImageRect(_imgBatt,
			Rect.fromLTWH(0, 0, _imgBatt.width.toDouble(), _imgBatt.height.toDouble()),
			Rect.fromLTWH(hfWid - 25, otHgt * 2, sblkWid, blkHgt),
			_paint);
	}

	@override
	bool shouldRepaint(CustomPainter oldDelegate) {
		return true;
	}
}

class NamedWithID {
	int _id;
	String _name;

	NamedWithID(this._id, this._name);

	String get name => _name;

	set name(String value) {
		_name = value;
	}

	int get id => _id;

	set id(int value) {
		_id = value;
	}
}