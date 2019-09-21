import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yeelinks/async.dart';
import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => SettingPageState();
}

class SettingPageState extends BasePageState<Page> {
	List<Device> _devices = [];

	@override
	void initState() {
		SystemChrome.setEnabledSystemUIOverlays([]);
		global.refreshTimer.register("listDevicesOfSetting", TimerJob(getDevList, hdlDevices, {
			TimerJob.PAGE_IDEN: pageId()
		}));
	}

	@override
	Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(2.5), child: Column(children: <Widget>[
		Center(child: Container(width: 200.0, child: Row(children: <Widget>[
			OutlineButton(child: Text("系统设置"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(4))), onPressed: null),
			OutlineButton(child: Text("设备设置"), shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(4))), onPressed: null)
		]))),
		Divider(),
		Expanded(child: GridView.count(
			crossAxisCount: 5,
			mainAxisSpacing: 10.0,
			crossAxisSpacing: 10.0,
			children: _genDevCards()
		))
	]));

	List<Widget> _genDevCards() {
		final textColor = Colors.grey[600];
		final primaryColor = Theme.of(context).primaryColor;
		final loadBtnCtt = (color) => Padding(padding: EdgeInsets.symmetric(vertical: 10),
			child: SizedBox(width: 80, child: SpinKitWave(size: 25, color: color))
		);
		return _devices.map<Widget>((device) => Container(
			padding: EdgeInsets.symmetric(vertical: 50),
			decoration: BoxDecoration(
				border: Border.all(color: primaryColor)
			),
			child: Column(children: <Widget>[
				Text(device.name, style: TextStyle(fontSize: 30, color: textColor)),
				Text("状态：${device.status == 1 ? "开启" : "关闭"}", style: TextStyle(fontSize: 20, color: textColor)),
				Divider(color:Colors.white, height: 10),
				device.status == 1 ? OutlineButton(
					borderSide: BorderSide(color: primaryColor),
					child: device.loading ? loadBtnCtt(primaryColor) : Text("关闭", style: TextStyle(fontSize: 10, color: primaryColor)),
					onPressed: !device.loading ? () async {
						setState(() {
							device.loading = true;
						});
						await turnOnOffDev(device.id, DEV_OFF);
						device.loading = false;
					} : () {}
				) : FlatButton(
					color: primaryColor,
					child: device.loading ? loadBtnCtt(Colors.white) : Text("开启", style: TextStyle(fontSize: 10, color: Colors.white)),
					onPressed: !device.loading ? () async {
						setState(() {
							device.loading = true;
						});
						await turnOnOffDev(device.id, DEV_ON);
						device.loading = false;
					} : () {}
				),
			])
		)).toList();
	}

    @override
    String pageId() => "setting";

	@override
	void hdlDevices(data) => setState(() {
		_devices = data.toList();
	});

	@override
	void hdlPointVals(dynamic data) {

	}
}