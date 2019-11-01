import 'package:flutter/material.dart';
import 'package:flutter_ijk/flutter_ijk.dart';

import '../components.dart';

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
		return _controller == null ? Container() : Center(
			child: _controller.value.initialized ? AspectRatio(
				aspectRatio: _controller.value.aspectRatio,
				child: IjkPlayer(_controller)
			) : Container()
		);
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