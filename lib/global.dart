import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home.dart' as home;
import 'pages/initialize.dart' as initialize;
import 'pages/electron.dart' as electron;
import 'pages/ups.dart' as ups;
import 'pages/aircond.dart' as aircond;
import 'pages/env.dart' as env;
import 'pages/setting.dart' as setting;
import 'async.dart';
import 'components.dart';
import 'main.dart';

String currentPageID = "home";
String currentGroup = "AnBKy5wyBwMLNaoc";
List<Device> devices = [];
class ComponentInfo {
	final String _id;
	final String _name;
	final Widget _page;

	ComponentInfo(this._id, this._name, this._page);

	Widget get page => _page;
	String get name => _name;
	String get id => _id;
}
final Map<String, ComponentInfo> componentInfos = {
	"initlize": ComponentInfo("initlize", "添加设备", initialize.InitializePage()),
	"home":     ComponentInfo("home", "首页", Dashboard(home.Page())),
	"electron": ComponentInfo("electron", "配电", Dashboard(electron.Page())),
	"ups":      ComponentInfo("ups", "UPS", Dashboard(ups.Page())),
	"aircond":  ComponentInfo("aircond", "空调", Dashboard(aircond.Page())),
	"env":      ComponentInfo("env", "环境", Dashboard(env.Page())),
	"setting":  ComponentInfo("setting", "设置", Dashboard(setting.Page()))
};
void toIdenPage(BuildContext context, String pid) {
	SystemChrome.setEnabledSystemUIOverlays([]);
	Navigator.push(context, PageSwitchRoute(componentInfos[pid].page));
}
final RefreshTimer refreshTimer = RefreshTimer();
bool manualLight = false;
const companyCode = "dd738dbb-0b28-4fa2-8934-efad4d8f9c88";
const roomCode = "swDMvFDTI6JBKcd0";
final Map<String, String> protocolMapper = {
	"温度": "15285839",
	"湿度": "15039855",
	"烟雾": "22531222",
	"水浸": "29816864",
	"前门": "27373773",
	"后门": "19959702",

	"电压": "26644399",
	"电流": "28390360",
	"有功功率": "21535190",
	"功率因素": "10621640",
	"频率": "17837682",
	"有功电能": "12234659",

	"电池开启": "14698228",
	"旁路功率不稳定": "19936714",
	"EEPROM错误": "19634149",
	"输出过载": "11563380",
	"根据用户指令，UPS准备好供电": "15072048",
	"已准备供电": "19940632",
	"电池电量不足": "25739124",
	"电池模式": "28539519",
	"在线模式": "29399240",
	"输出电压不良": "12453288",
	"运行模式": "13574393",
	"电池容量": "20334398",
	"电池剩余时间": "20986224",
	"输入电压": "27014081",
	"输出电压": "15287449",
	"电池电压": "25753070",
	"输出电流": "18134440",
	"电池电流": "19423992",
	"低电池电压": "25753070",
	"输入频率": "16296920",
	"输出频率": "23672353",
	"电池更换警告": "25739124",

	"送风温度": "21897955",
	"回风温度": "14201048",
	"回风湿度": "11573133",
	"压缩机转速": "17155700",
	"内风机转速": "15322686",
	"外风机转速": "14122292",
	"膨胀阀开度": "20777895",
	"加热器电流": "18271622",
	"运行状态": "10939746",
	"制冷状态": "14481953",
	"加热状态": "24792435",
	"除湿状态": "15025723",
	"自检状态": "25006616",
	"内风机": "16927357",
	"外风机": "25860703",
	"压缩机": "12758077",
	"送风温度传感器故障": "15875698",
	"回风温度传感器故障": "10943046",
	"冷凝盘管温度传感器故障": "15963996",
	"过热度温度传感器故障": "22539599",
	"环境温度传感器故障": "17673964",
	"系统低压压力传感器故障": "13915185",
	"回风湿度传感器故障": "24433967",
	"内风机故障": "22325651",
	"外风机故障": "19970313",
	"压缩机故障": "11669618",
	"加热器故障": "29707437",
	"回风高温告警": "20657947",
	"电源电压过高告警": "18163715",
	"电源电压过低告警": "21356865",
	"系统高压力告警": "17715002",
	"系统低压力告警": "19578137",
	"水浸告警": "19247419",
	"压缩机温度过高告警": "24781474",
	"内外机通信故障告警": "25419020",
	"烟雾告警": "24745906",
	"回风高湿告警": "28664366",
	"回风低湿告警": "11697519",
	"回风低温告警": "20223191",
	"送风高温告警": "23226822",
	"送风低温告警": "21595930",
	"过热度过高报警": "15976488",
	"过热度过低报警": "25894281",
	"高压开关故障告警": "28855905"
};
const platform = const MethodChannel("com.yeelinks.plugins/led_ctrl");
const lightColors = ["RED", "GREEN", "BLUE"];