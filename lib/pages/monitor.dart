import 'package:flutter/material.dart';
import 'package:flutter_ijk/flutter_ijk.dart';

import '../components.dart';
import '../global.dart' as global;

class MonitorPageState extends State<Page> {
	IjkPlayerController _controller;

	@override
	void initState() {
//		super.initState();
		_controller = IjkPlayerController.network("rtsp://admin:SHtzr1984@192.168.0.64:554/h264/ch1/sub/av_stream")
			..initialize().then((_) => setState(() {
				_controller.play();
			}));
	}

	@override
	Widget build(BuildContext context) {
		return Row(children: <Widget>[
			DataCard(title: "录像机", child: ListView(children: global.devices.map<Widget>(
					(dev) => (global.currentDevID == dev.id ? FlatButton(
					shape: RoundedRectangleBorder(
						side: BorderSide(color: global.primaryColor),
						borderRadius: BorderRadius.all(Radius.circular(3))
					),
					disabledColor: global.primaryColor,
					child: Text(dev.name, style: TextStyle(color: Colors.white)), onPressed: null,
				) : OutlineButton(
					textColor: global.primaryColor,
					borderSide: BorderSide(color: global.primaryColor),
					child: Text(dev.name), onPressed: () => setState(() {
					global.refreshTimer.refresh(context, dev.id, () async {
						global.idenDevs = [dev.id];
					});
				})))
			).toList())),
			DataCard(title: "画面", flex: 4, child: Padding(
				padding: EdgeInsets.symmetric(vertical: 20),
				child: _controller == null ? Container() : Center(
					child: _controller.value.initialized ? AspectRatio(
						aspectRatio: _controller.value.aspectRatio,
						child: IjkPlayer(_controller)
					) : Container()
				)
			))
		]);
	}

	@override
	void hdlDevices(data) {
		// TODO: implement hdlDevices
	}

	@override
	void hdlPointVals(data) {
		// TODO: implement hdlPointVals
	}

	@override
	String pageId() => "monitor";
}