import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'pages/home.dart' as home;
import 'pages/initialize.dart' as initialize;
import 'pages/electron.dart' as electron;
import 'pages/ups.dart' as ups;
import 'pages/aircond.dart' as aircond;
import 'pages/env.dart' as env;
import 'pages/warning.dart' as warning;
import 'pages/history.dart' as history;
import 'pages/setting.dart' as setting;
import 'pages/warning.dart' as warning;
import 'pages/history.dart' as history;
import 'async.dart';
import 'components.dart';
import 'main.dart';

String currentPageID = "home";
String currentGroup = "AnBKy5wyBwMLNaoc";
String currentDevID = "";
List<Device> devices = [];
class ComponentInfo {
	final String _id;
	final String _name;
	final Widget _page;
	final int _index;

	ComponentInfo(this._id, this._name, this._page, this._index);

	Widget get page => _page;
	String get name => _name;
	String get id => _id;
	int get index => _index;

}
final Map<String, ComponentInfo> componentInfos = {
	"initlize": ComponentInfo("initlize", "添加设备", initialize.InitializePage(), 0),
	"home":     ComponentInfo("home", "首页", Dashboard(home.Page()), 1),
	"electron": ComponentInfo("electron", "配电", Dashboard(electron.Page()), 2),
	"ups":      ComponentInfo("ups", "UPS", Dashboard(ups.Page()), 3),
	"aircond":  ComponentInfo("aircond", "空调", Dashboard(aircond.Page()), 4),
	"env":      ComponentInfo("env", "环境", Dashboard(env.Page()), 5),
	"setting":  ComponentInfo("setting", "设置", Dashboard(setting.Page()), 8),
	"warning":  ComponentInfo("warning", "告警", Dashboard(warning.Page()), 1),
	"history":  ComponentInfo("history", "历史", Dashboard(history.Page()), 7)
};
void toIdenPage(BuildContext context, String pid) {
	currentDevID = "";
	Navigator.push(context, PageSwitchRoute(componentInfos[pid].page));
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
	"27881826":	"功率因素",
	"11337819":	"频率",
	"10228430":	"有功电能",
	"26644399": "PDU-输出电压",
	"28390360": "PDU-输出电流",
	"21535190": "PDU-有功功率",
	"10621640": "PDU-功率因素",
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
	"13574393":	"运行模式",
	"20334398":	"电池容量",
	"20986224":	"电池剩余时间",
	"27014081":	"输入电压",
	"15287449":	"输出电压",
	"25753070":	"电池电压",
	"18134440":	"输出电流",
	"19423992":	"电池电流",
	"16296920":	"输入频率",
	"23672353":	"输出频率",

	"21897955":	"送风温度",
	"14201048":	"回风温度",
	"11573133":	"回风湿度",
	"17155700":	"压缩机转速",
	"15322686":	"内风机转速",
	"14122292":	"外风机转速",
	"20777895":	"膨胀阀开度",
	"18271622":	"加热器电流",
	"10939746":	"运行状态",
	"14481953":	"制冷状态",
	"24792435":	"加热状态",
	"15025723":	"除湿状态",
	"25006616":	"自检状态",
	"16927357":	"内风机",
	"25860703":	"外风机",
	"12758077":	"压缩机",
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

	"29607741": "热通道温度",
	"29607742": "热通道湿度",
	"29607739": "冷通道温度",
	"29607740": "冷通道湿度"
};
const platform = const MethodChannel("com.yeelinks.plugins/led_ctrl");
const lightColors = ["RED", "GREEN", "BLUE"];
enum ConfirmCancel {
	CONFIRMED, CANCELED
}
final dtFmter = DateFormat("yyyy-MM-dd");