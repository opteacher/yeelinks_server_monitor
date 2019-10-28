import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'pages/home.dart' as home;
import 'pages/initialize.dart' as initialize;
import 'pages/electron.dart' as electron;
import 'pages/ups.dart' as ups;
import 'pages/aircond.dart' as aircond;
import 'pages/env.dart' as env;
import 'pages/history.dart' as history;
import 'pages/setting.dart' as setting;
import 'pages/history.dart' as history;
import 'pages/monitor.dart' as monitor;
import 'async.dart';
import 'components.dart';
import 'main.dart';

String currentPageID = "home";
String currentGroup = "AnBKy5wyBwMLNaoc";
String currentDevID = "";
List<Device> devices = [];
int upsMode = 17408;
class ComponentInfo {
	final String _id;
	final String _name;
	final Widget _page;
	final int _index;
	final int _numJobs;

	ComponentInfo(this._id, this._name, this._page, this._index, this._numJobs);

	Widget get page => _page;
	String get name => _name;
	String get id => _id;
	int get index => _index;
	int get numJobs => _numJobs;
}
final Map<String, ComponentInfo> componentInfos = {
	"initlize": ComponentInfo("initlize", "添加设备", initialize.InitializePage(), 0, 0),
	"home":     ComponentInfo("home", "首页", Dashboard(home.Page()), 1, 1),
	"electron": ComponentInfo("electron", "配电", Dashboard(electron.Page()), 2, 2),
	"ups":      ComponentInfo("ups", "UPS", Dashboard(ups.Page()), 3, 2),
	"aircond":  ComponentInfo("aircond", "空调", Dashboard(aircond.Page()), 4, 2),
	"env":      ComponentInfo("env", "环境", Dashboard(env.Page()), 5, 2),
	"setting":  ComponentInfo("setting", "设置", Dashboard(setting.Page()), 8, 1),
	"history":  ComponentInfo("history", "历史", Dashboard(history.Page()), 7, 3),
	"monitor":  ComponentInfo("monitor", "监控", Dashboard(monitor.Page()), 6, 0)
};
toIdenPage(BuildContext context, String pid) {
	currentPageID = pid;
	Navigator.push(context, PageSwitchRoute(componentInfos[pid].page));
	Timer(Duration(milliseconds: 200), () {
		refreshTimer.refresh(context, "", () async {
			// 手动启动页面请求
			await refreshTimer.refreshIdenPrefix("devPageOf");
		});
	});
}
final RefreshTimer refreshTimer = RefreshTimer();
bool manualLight = false;
const companyCode = "dd738dbb-0b28-4fa2-8934-efad4d8f9c88";
const roomCode = "swDMvFDTI6JBKcd0";
List<String> idenDevs = [];
List<PointVal> pointValues = [];
const Map<String, String> protocolMapper = {
	"15285839":	"温度",
	"15039855":	"湿度",
	"29707439":	"烟雾",
	"29707441":	"水浸",
	"29707438":	"前门",
	"29707440":	"后门",

	"24599481":	"电压",
	"24073296":	"电流",
	"27203478":	"有功功率",
	"27881826":	"功率因数",
	"11337819":	"频率",
	"10228430":	"有功电能",
	"26644399": "PDU-输出电压",
	"28390360": "PDU-输出电流",
	"21535190": "PDU-有功功率",
	"10621640": "PDU-功率因数",
	"17837682": "PDU-输出频率",
	"12234659": "PDU-有功电能",

	"20975840": "UPS负载率",
	"14698228":	"电池开启",
	"19936714":	"旁路功率不稳定",
	"19634149":	"EEPROM错误",
	"11563380":	"输出过载",
	"15072048":	"根据用户指令，UPS准备好供电",
	"19940632":	"已准备供电",
	"25739124":	"电池电量不足",
	"28539519":	"电池模式",
	"29399240":	"在线模式",
	"12453288":	"输出电压不良",
	"11811578":	"运行模式",
	"20334398":	"电池容量",
	"20986224":	"电池剩余时间",
	"27014081":	"输入电压",
	"15287449":	"输出电压",
	"25753070":	"电池电压",
	"18134440":	"输出电流",
	"19423992":	"电池电流",
	"16296920":	"输入频率",
	"23672353":	"输出频率",
	"29719932": "过载",
	"27511151": "低电池电压",
	"20222069": "电池过充",

	"21324119":	"送风温度",
	"10072493":	"回风温度",
	"22897338":	"回风湿度",
	"17155700":	"压缩机转速",
	"15322686":	"内风机转速",
	"14122292":	"外风机转速",
	"20777895":	"膨胀阀开度",
	"18271622":	"加热器电流",
	"21171621": "环境温度",
	"27490455": "回气温度",
	"29607738": "电源电压值",
	"10237691": "冷凝温度",
	"14940198":	"运行状态",
	"27440670":	"制冷状态",
	"18635450":	"加热状态",
	"11405570":	"除湿状态",
	"28287607":	"自检状态",
	"23052353":	"内风机",
	"25863829":	"外风机",
	"26712276":	"压缩机",
	"15875698":	"送风温度传感器故障",
	"10943046":	"回风温度传感器故障",
	"15963996":	"冷凝盘管温度传感器故障",
	"22539599":	"过热度温度传感器故障",
	"17673964":	"环境温度传感器故障",
	"13915185":	"系统低压压力传感器故障",
	"24433967":	"回风湿度传感器故障",
	"22325651":	"内风机故障",
	"19970313":	"外风机故障",
	"11669618":	"压缩机故障",
	"29707437":	"加热器故障",
	"20657947":	"回风高温告警",
	"18163715":	"电源电压过高告警",
	"21356865":	"电源电压过低告警",
	"17715002":	"系统高压力告警",
	"19578137":	"系统低压力告警",
	"19247419":	"水浸告警",
	"24781474":	"压缩机温度过高告警",
	"25419020":	"内外机通信故障告警",
	"24745906":	"烟雾告警",
	"28664366":	"回风高湿告警",
	"11697519":	"回风低湿告警",
	"20223191":	"回风低温告警",
	"23226822":	"送风高温告警",
	"21595930":	"送风低温告警",
	"15976488":	"过热度过高报警",
	"25894281":	"过热度过低报警",
	"28855905":	"高压开关故障告警",
	"11285140": "运行频率",
	"12425421": "内风机电压",
	"17215922": "出盘温度",
	"18052084": "机组运行模式",
	"18470217": "吸气压力",
	"19384635": "排气压力",
	"23026671": "进盘温度",
	"23840234": "排气温度",
	"26005249": "目标蒸发温度",
	"23524287": "机组开关机",

	"29607741": "热通道温度",
	"29607742": "热通道湿度",
	"29607739": "冷通道温度",
	"29607740": "冷通道湿度",
	"14556241": "防雷",
	"13615618": "门禁",
	"14605355": "漏水",
	"18359908": "烟感"
};
const ledCtrl = const MethodChannel("com.yeelinks.plugins/led_ctrl");
//const brightnessCtrl = const MethodChannel("com.yeelinks.plugins/bright_ctrl");
const lightColors = ["RED", "GREEN", "BLUE"];
enum ConfirmCancel {
	CONFIRMED, CANCELED
}
final dtFmter = DateFormat("yyyy-MM-dd");
final dttmParser = DateFormat("yyyy-MM-dd\THH:mm:ss");
final dttmFmter = DateFormat("yyyy-MM-dd HH:mm:ss");