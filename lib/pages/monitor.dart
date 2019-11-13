import 'package:flutter/material.dart';
import 'package:flutter_ijk/flutter_ijk.dart';

import '../components.dart';
import '../global.dart' as global;

class Page extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => MonitorPageState();
}

class MonitorPageState extends BasePageState<Page> {
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
			Expanded(child: Container(
				decoration: BoxDecoration(
					border: Border.all(color: global.primaryColor),
				),
				margin: EdgeInsets.all(3.5),
				padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
				child: ListView(children: global.devices.map<Widget>(
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
				).toList())
			)),
			Expanded(flex: 4, child: _controller == null ? Container() : Center(
				child: _controller.value.initialized ? AspectRatio(
					aspectRatio: _controller.value.aspectRatio,
					child: IjkPlayer(_controller)
				) : Container()
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