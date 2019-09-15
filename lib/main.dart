import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'async.dart';
import 'components.dart';
import 'global.dart' as global;

void main() {
	SystemChrome.setPreferredOrientations([
		DeviceOrientation.landscapeLeft,
		DeviceOrientation.landscapeLeft
	]);
	return runApp(MyApp());
}

class MyApp extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
	@override
	Widget build(BuildContext context) => MaterialApp(
		title: "My app",
		theme: ThemeData(
			primaryColorLight: const Color(0xffE7F9E9),
			primaryColor: const Color(0xff3dcd58),
			primaryColorDark: const Color(0xff009530)
		),
		home: global.componentInfos["initlize"].page,
		debugShowCheckedModeBanner: false,
	);

	@override
	void dispose() {
		super.dispose();
//		global.refreshTimer.cancel();
//		global.platform.invokeMethod("lightDown");
	}

	@override
	void initState() {
		super.initState();
//		global.refreshTimer.start();
	}
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
	@override
	State<StatefulWidget> createState() => MyAppBarState();

	@override
	Size get preferredSize => Size.fromHeight(75.0);
}

class MyAppBarState extends State<MyAppBar> {
	final TextStyle _titleStyle = TextStyle(fontSize: 20.0, color: Colors.white);
	final Widget _barDivider = Padding(
		padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
		child: VerticalDivider(color: Colors.white)
	);
	Timer _timer;
	DateTime _time = DateTime.now();

	_refresh() async {
		ResponseInfo ri = await getDevices(global.companyCode, global.roomCode);
		global.devices = ri.data.toList().cast<Device>();
		Toast.show(ri.message, context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
	}

	@override
	void initState() {
		super.initState();
//		this._refresh();
		_timer = Timer.periodic(const Duration(minutes: 1), (Timer t) => setState(() {
			_time = DateTime.now();
		}));
	}

	@override
	void dispose() {
		_timer.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) => Ink(
		decoration: BoxDecoration(color: Theme.of(context).primaryColor),
		child: Row(children: <Widget>[
			Container(
				width: 110.0,
				alignment: Alignment.center,
				padding: EdgeInsets.symmetric(vertical: 10.0),
				child: Image.asset("images/logo.png"),
			),
			Expanded(child: Row(children: <Widget>[
				_buildTitleButton(context, "首页", "home", icon: Icons.home),
				_buildTitleButton(context, "配电", "electron", icon: Icons.flash_on),
				_buildTitleButton(context, "空调", "aircond", icon: Icons.ac_unit),
				_buildTitleButton(context, "环境", "env", icon: Icons.settings_system_daydream),
				_buildTitleButton(context, "告警", "warning", icon: Icons.warning),
				_buildTitleButton(context, "历史", "history", icon: Icons.history),
				_buildTitleButton(context, "设置", "setting", icon: Icons.settings)
			])),
			Padding(
				padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
				child: Column(children: <Widget>[
					Text("${_time.hour.toString().padLeft(2, "0")}:${_time.minute.toString().padLeft(2, "0")}",
						style: TextStyle(color: Colors.white, fontSize: 30)
					),
					Text("${_time.year.toString().padLeft(4, "0")}-${_time.month.toString().padLeft(2, "0")}-${_time.day.toString().padLeft(2, "0")}",
						style: TextStyle(color: Colors.white, fontSize: 15)
					)
				]
			))
		]),
	);

	_buildTitleButton(BuildContext context, String label, String pid, {IconData icon, void Function() callback}) {
		List<Widget> btnContent = [Text(label, style: _titleStyle)];
		if (icon != null) {
			btnContent.insertAll(0, [
				Icon(icon, color: Colors.white, size: 35), Text("  ")
			]);
		}
		if (callback == null) {
			callback = () {
				global.currentPageID = pid;
				global.toIdenPage(context, pid);
			};
		}
		if (global.currentPageID == pid) {
			return Container(
				color: Theme.of(context).primaryColorDark,
				padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
				child: Row(children: btnContent)
			);
		} else {
			return InkWell(onTap: callback, child: Container(
				padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
				child: Row(children: btnContent)
			));
		}
	}
}

class Dashboard extends StatelessWidget {
	final Widget _content;

	Dashboard(this._content);

	@override
	Widget build(BuildContext context) => Scaffold(
		appBar: MyAppBar(),
		body: Builder(builder: (context) => Container(
			color: Colors.grey[300],
			padding: const EdgeInsets.all(2.5),
			child: Container(
				color: Colors.white,
				child: _content
			)
		))
	);

	_buildSideButton(BuildContext context, IconData icon, String label, [String id = "home"]) {
		var active = global.currentPageID == id;
		return GestureDetector(
			onTap: active ? null : () {
				global.currentPageID = id;
				global.toIdenPage(context, id);
			},
			child: Container(
				color: active ? Theme.of(context).primaryColor : Colors.white,
				padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
				margin: const EdgeInsets.symmetric(vertical: 2.5),
				child: Column(children: <Widget>[
					Icon(icon, size: 50.0,
						color: active ? Colors.white : Colors.grey),
					Text(label,
						style: TextStyle(
							color: active ? Colors.white : Colors.grey,
							fontSize: 20.0)),
				]),
			),
		);
	}
}