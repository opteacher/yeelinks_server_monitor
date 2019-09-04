import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../global.dart' as global;
import '../async.dart' as backend;

class InitializePage extends StatefulWidget {
	@override
	State createState() => InitializePageState();
}

class InitializePageState extends State<InitializePage> {
	final TextStyle _titleStyle = TextStyle(fontSize: 20.0, color: Colors.white);
	final EdgeInsetsGeometry _formMargin = EdgeInsets.symmetric(horizontal: 100.0, vertical: 50.0);

	String _devName = "";
	int _slaveId = -1;
	int _comPort = -1;
	backend.DevType _devType;
	backend.DevProxy _devProxy;

	@override
	Widget build(BuildContext context) => Scaffold(
		appBar: AppBar(title: Text("添加设备", style: _titleStyle), automaticallyImplyLeading: false),
		body: SingleChildScrollView(
			scrollDirection: Axis.vertical,
			child: Container(margin: _formMargin, child: Column(children: <Widget>[
				TextField(
					autofocus: true,
					decoration: InputDecoration(hintText: "输入设备名称"),
					onChanged: (str) => setState(() {
						_devName = str;
					}),
				),
				TextField(
					decoration: InputDecoration(hintText: "输入硬件地址（1~255）"),
					keyboardType: TextInputType.number,
					maxLength: 3,
					onChanged: (str) => setState(() {
						_slaveId = int.parse(str);
					}),
				),
				TextField(
					decoration: InputDecoration(hintText: "输入COM口号（1~8）"),
					keyboardType: TextInputType.number,
					maxLength: 1,
					onChanged: (str) => setState(() {
						_comPort = int.parse(str);
					}),
				),
				Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
					RaisedButton(child: Text("选择设备类型"), onPressed: () async {
						List<backend.DevType> typeList = (
							await backend.getDevTypeList()
						).data.toList().cast<backend.DevType>();
						List<Widget> tlchildren = [];
						for (var tp in typeList) {
							tlchildren.add(Divider());
							tlchildren.add(SimpleDialogOption(
								child: Text(tp.name),
								onPressed: () {
									setState(() {
										_devType = tp;
									});
									Navigator.of(context).pop();
								}
							));
						}
						await showDialog(context: context,
							builder: (BuildContext context) => SimpleDialog(
								title: const Text("选择类型"),
								children: tlchildren,
							)
						);
					}),
					Padding(padding: EdgeInsets.only(left: 20.0),
						child: Text(_devType != null ? _devType.name : "")
					)
				]),
				Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
					RaisedButton(child: Text("选择协议"), onPressed: _devType != null ? () async {
						List<backend.DevProxy> proxyList = (
							await backend.getDevProxyList(_devType.id.toString())
						).data.toList().cast<backend.DevProxy>();
						List<Widget> plChildren = [];
						for (var dp in proxyList) {
							plChildren.add(Divider());
							plChildren.add(SimpleDialogOption(
								child: Text(dp.name),
								onPressed: () {
									setState(() {
										_devProxy = dp;
									});
									Navigator.of(context).pop();
								}
							));
						}
						await showDialog(context: context,
							builder: (BuildContext context) => SimpleDialog(
								title: const Text("选择协议"),
								children: plChildren,
							)
						);
					} : null),
					Padding(padding: EdgeInsets.only(left: 20.0),
						child: Text(_devProxy != null ? _devProxy.name : "")
					)
				]),
				Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
					Container(margin: EdgeInsets.all(5.0), child: RaisedButton(
						onPressed: () {
							global.toIdenPage(context, "home");
						},
						child: Text("跳 过", style: TextStyle(fontSize: 20)),
					)),
					Container(margin: EdgeInsets.all(5.0), child: RaisedButton(
						color: Theme.of(context).primaryColor,
						onPressed: validFormData() ? () async {
							backend.ResponseInfo resp = await backend.postAddDev(
								_devName, _slaveId, _comPort, _devType.id, _devProxy.id
							);
							if (resp.data != null && resp.data["id"].toString().isNotEmpty) {
								Toast.show("设备：$_devName添加成功！", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
								Navigator.of(context).pop();
							} else {
								Toast.show("添加设备发生错误：${resp.message}", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
							}
						} : null,
						child: Text("确 定", style: TextStyle(fontSize: 20)),
					)),
				])
			]))
		)
	);

	bool validFormData() => _devName != null && _devName.isNotEmpty
		&& _slaveId != null && _slaveId != -1
		&& _comPort != null && _comPort != -1
		&& _devType != null && _devProxy != null;
}
