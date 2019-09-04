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
			primaryColor: Colors.green[400],
		),
		home: global.componentInfos["initlize"].page,
		debugShowCheckedModeBanner: false,
	);

	@override
	void dispose() {
		super.dispose();
		global.refreshTimer.cancel();
		global.platform.invokeMethod("lightDown");
	}

	@override
	void initState() {
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
	final Widget _barDivider = Padding(padding: EdgeInsets.symmetric(vertical: 15), child: VerticalDivider(color: Colors.white));
	String _curDevName = "选择设备";

	_refresh() async {
		ResponseInfo ri = await getDevices(global.companyCode, global.roomCode);
		List<Device> devices = ri.data.toList().cast<Device>();
		if (devices.isNotEmpty && global.currentDevice == null) {
			global.currentDevice = devices[0];
			setState(() {
				_curDevName = global.currentDevice.name;
			});
		}
		Toast.show(ri.message, context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
	}

	@override
	void initState() {
		super.initState();
		this._refresh();
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
			_barDivider,
			Expanded(child: Row(children: <Widget>[
				_buildTitleButton(context, global.componentInfos[global.currentPageID].name),
				_barDivider,
				_buildTitleButton(context, (
					global.currentDevice == null ? "选择设备" : global.currentDevice.name
				), callback: () {
					Scaffold.of(context).showBottomSheet((_) => SelDeviceList((Device device) {
						setState(() {
							_curDevName = device.name;
						});
					}));
				}),
				_barDivider,
				_buildTitleButton(context, "添加设备", callback: () {
					global.toIdenPage(context, "initlize");
				})
			])),
			Row(children: <Widget>[
				_buildTitleButton(context, "历史记录", icon: Icons.history),
				_barDivider,
				_buildTitleButton(context, "告警", icon: Icons.warning, callback: () {
					global.manualLight = !global.manualLight;
					global.platform.invokeMethod("lightDown");
//					global.platform.invokeMethod("lightUp", {
//						"color": global.lightColors[Random(DateTime.now().millisecondsSinceEpoch).nextInt(3)],
//						"brightness": 50
//					});
//					global.platform.invokeMethod("flash");
				})
			])
		]),
	);

	_buildTitleButton(BuildContext context, String label, {IconData icon, void Function() callback}) {
		List<Widget> btnContent = [Text(label, style: _titleStyle)];
		if (icon != null) {
			btnContent.insertAll(0, [
				Icon(icon, color: Colors.white), Text("  ")
			]);
		}
		if (callback == null) {
			callback = () {};
		}
		return InkWell(onTap: callback, child: Padding(
			padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
			child: Row(children: btnContent)
		));
	}
}

class Dashboard extends StatelessWidget {
	final Widget _content;

	Dashboard(this._content);

	@override
	Widget build(BuildContext context) => Scaffold(
		appBar: MyAppBar(),
		body: Builder(builder: (context) => Row(children: <Widget>[
			Container(
				width: 120.0,
				color: Colors.grey[300],
				child: Column(children: <Widget>[
					_buildSideButton(context, Icons.home, "首页", "home"),
					_buildSideButton(context, Icons.flash_on, "配电", "electron"),
					_buildSideButton(context, Icons.battery_std, "UPS", "ups"),
					_buildSideButton(context, Icons.ac_unit, "空调", "aircond"),
					_buildSideButton(context, Icons.settings_system_daydream, "环境", "env"),
					_buildSideButton(context, Icons.settings, "设置", "setting"),
				]),
			),
			Expanded(child: Container(
				color: Colors.grey[300],
				padding: const EdgeInsets.all(2.5),
				child: Container(
					color: Colors.white,
					child: _content
				),
			))
		]))
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