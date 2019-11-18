import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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
	void initState() {
		super.initState();
		initialize();
	}

	@override
	void dispose() {
		super.dispose();
		uninitialize();
	}

	initialize() async {
		await FlutterDownloader.initialize();
//	await checkNewVersion();
//	global.brightnessCtrl.invokeMethod("turnOff");
		global.dbHelpSubsc = global.dbHelp.receiveBroadcastStream().listen(_onRecvData);
	}

	_onRecvData(dynamic data) {
		print(data);
		setState(() {});
	}

	uninitialize() async {
		global.refreshTimer.cancel();
//  global.ledCtrl.invokeMethod("lightDown");
		if (global.dbHelpSubsc != null) {
			global.dbHelpSubsc.cancel();
			global.dbHelpSubsc = null;
		}
	}
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
	@override
	State<StatefulWidget> createState() => MyAppBarState();

	@override
	Size get preferredSize => Size.fromHeight(global.appBarHeight);
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
				_buildTitleButton(context, "日志", "history", icon: Icons.content_paste),
				_buildTitleButton(context, "监控", "monitor", icon: Icons.videocam)
			])),
			_buildTitleButton(context, "", "setting", icon: Icons.settings, callback: () async {
				final _formKey = GlobalKey<FormState>();
				String _account = "";
				String _password = "";
				switch(await showDialog<global.ConfirmCancel>(context: context, builder: (BuildContext context) => SimpleDialog(
					title: Text("管理员认证"),
					children: <Widget>[Padding(padding: EdgeInsets.all(20), child: Form(key: _formKey, child: Column(children: <Widget>[
						TextFormField(
							decoration: InputDecoration(hintText: "输入管理员账号"),
							autofocus: true,
							onSaved: (content) {
								_account = content;
							},
						),
						TextFormField(
							decoration: InputDecoration(hintText: "输入密码"),
							obscureText: true,
							onSaved: (content) {
								_password = content;
							},
						),
						Padding(padding: EdgeInsets.only(top: 16), child: FlatButton(
							color: Theme.of(context).primaryColor,
							child: Text("登录", style: TextStyle(color: Colors.white)),
							onPressed: () {
								var _form = _formKey.currentState;
								if (!_form.validate()) {
									return;
								}
								_form.save();
								if (_account != "admin" || _password != "admin") {
									Navigator.pop(context, global.ConfirmCancel.CANCELED);
									Toast.show("管理员账户或密码错误！", context);
								} else {
									Navigator.pop(context, global.ConfirmCancel.CONFIRMED);
								}
							})
						)
					])))]
				))) {
					case global.ConfirmCancel.CONFIRMED:
						global.toIdenPage(context, "setting");
						break;
					case global.ConfirmCancel.CANCELED:
					default:
						SystemChrome.setEnabledSystemUIOverlays([]);
				}
			})
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
	Widget build(BuildContext context) {
		global.primaryColor = Theme.of(context).primaryColor;
		return Scaffold(
			appBar: MyAppBar(),
			body: Builder(builder: (context) => SingleChildScrollView(child: Container(
				color: Colors.white,
				padding: const EdgeInsets.all(2.5),
				height: MediaQuery.of(context).size.height - global.appBarHeight,
				child: _content
			)))
		);
	}
}