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
	SystemChrome.setEnabledSystemUIOverlays([]);
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
			primaryColorDark: const Color(0xff009530),
			dividerColor: const Color(0xffE7F9E9),
		),
		home: global.componentInfos["home"].page,
		debugShowCheckedModeBanner: false,
	);

	@override
	void dispose() {
		super.dispose();
		global.refreshTimer.cancel();
//		global.platform.invokeMethod("lightDown");
	}

	@override
	void initState() {
		super.initState();
		global.refreshTimer.start();
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
				_buildTitleButton(context, "UPS", "ups", icon: Icons.battery_std),
				_buildTitleButton(context, "空调", "aircond", icon: Icons.ac_unit),
				_buildTitleButton(context, "环境", "env", icon: Icons.settings_system_daydream),
				_buildTitleButton(context, "告警", "warning", icon: Icons.warning),
				_buildTitleButton(context, "历史", "history", icon: Icons.history)
			])),
			_buildTitleButton(context, "", "setting", icon: Icons.settings)
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
}