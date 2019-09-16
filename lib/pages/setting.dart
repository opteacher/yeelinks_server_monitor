import 'package:flutter/material.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => SettingPageState();
}

class SettingPageState extends BasePageState<Page> {
	@override
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(2.5), child: Column(children: <Widget>[
		Center(child: Container(width: 200.0, child: Row(children: <Widget>[
			OutlineButton(child: Text("系统设置"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(4))), onPressed: null),
			OutlineButton(child: Text("设备设置"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(4))), onPressed: null)
		]))),
		Divider(),
		Expanded(child: Text(""))
	]));

    @override
    String pageId() => "setting";

	@override
	void hdlDevices(data) {
		// TODO: implement hdlDevices
	}
}