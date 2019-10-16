import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'global.dart' as global;
import 'components.dart';
import 'package:package_info/package_info.dart';

class RequestInfo {
	final String _method;
	final String _path;
	Map<String, Object> _body = {};

	RequestInfo(this._method, this._path, this._body);

	Map<String, Object> get body => _body;
	String get path => _path;
	String get method => _method;

	RequestInfo chgBody(String key, Object val) {
		_body[key] = val;
		return this;
	}

	RequestInfo rmvBody(String key) {
		_body.remove(key);
		return this;
	}

	String cmbBodyAsParamIntoPath() {
		String ret = _path;
		var keys = _body.keys.toList();
		for (var i = 0; i < keys.length; i++) {
			ret += i == 0 ? "?" : "&";
			ret += "${keys[i]}=${_body[keys[i]]}";
		}
		return ret;
	}
}

class ResponseInfo {
	final dynamic _data;
	final String _message;

	ResponseInfo(this._data, this._message);

	String get message => _message;
	dynamic get data => _data;
}

const url = "http://10.168.1.95:8080";// "http://test_api.ncpi-om.com"
final devPage = RequestInfo("GET", "/api/v1/devices/page", {
	"type": ""
});
final getPoiSensor = RequestInfo("POST", "/api/v1/points/sensor", {
	"devices": []
});
final listDevices = RequestInfo("POST", "/api/v1/devices/list", {});
final getAlarms = RequestInfo("GET", "/api/v1/alarms/active", {});
final _poiHistory = RequestInfo("POST", "/api/v1/points/history", {
	"id": "",
	"points": [],
	"time": 1,
	"time_range": []
});
final devEventHistory = RequestInfo("POST", "/api/v1/alarms/history", {
	"device_id": "",
	"time_range": []
});
final devEventActive = RequestInfo("GET", "/api/v1/alarms/active", {
	"device_id": ""
});
final _turnOnOffDev = RequestInfo("PUT", "/api/v1/devices/update", {
	"id": "",
	"status": -1
});
const DEV_ON = 1;
const DEV_OFF = 2;
final _getDevPoints = RequestInfo("GET", "/api/v1/devices/points", {
	"id": ""
});
final devTypes = RequestInfo("GET", "/api/v1/dictionary/list?type=1", {});
final devProxies = RequestInfo("GET", "/api/v1/protocols/list", {
	"device_type": ""
});
final addDevice = RequestInfo("POST", "/api/v1/devices/add", {
	"name": "",
	"type": -1,
	"access_type": 1,
	"com_port": -1,
	"slave_id": -1,
	"protocol_id": ""
});
const updateURL = "http://py9z68s8h.bkt.clouddn.com/apk-release-v{version}.apk";

class DeviceComponent {
	String _id;
	String _name;

	DeviceComponent.fromJSON(Map json):
		_id = json["id"], _name = json["name"];

	String get name => _name;
	String get id => _id;
}

class Device {
	String _id;
	String _name;
	int _type;
	String _typeStr;
	String _protocolId;
	double _temp = 0.0;
	double _humi = 0.0;
	int _status;
	bool _loading = false;

	Device.fromJSON(Map json):
		_id = json["id"], _name = json["name"], _type = json["type"],
		_typeStr = json["device_type_str"], _protocolId = json["protocol_id"],
		_status = json["status"] != null ? json["status"].toInt() : 0;

	String get name => _name;
	String get id => _id;
	int get type => _type;
	String get protocolId => _protocolId;
	String get typeStr => _typeStr;
	double get humi => _humi;
	set humi(double value) {
		_humi = value;
	}
	double get temp => _temp;
	set temp(double value) {
		_temp = value;
	}
	int get status => _status;
	bool get loading => _loading;
	set loading(bool value) {
		_loading = value;
	}
}

class PointVal {
	final String _id;
	final String _deviceId;
	final double _value;
	final String _unit;

	PointVal(this._id, this._deviceId, this._value, this._unit);

	PointVal.fromJSON(Map json):
		_id = json["id"].toString(), _deviceId = json["device_id"],
		_value = double.parse(json["value"].toString()), _unit = json["unit"];

	String get id => _id;
	String get deviceId => _deviceId;
	double get value => _value;
	String get unit => _unit;
}

class EventRecord {
	final int _id;
	final String _name;
	final String _warning;
	final String _meaning;
	final String _level;
	final String _checker;
	final String _start;
	final String _check;
	final String _status;
	final String _unchain;
	final String _unchainer;

	EventRecord(
		this._id,
		this._name,
		this._warning,
		this._meaning,
		this._level,
		this._start,
		this._check,
		this._status,
		this._checker,
		this._unchain,
		this._unchainer
	);

	EventRecord.fromJSON(Map json): _id = json["id"],
		_name = json["device_name"], _warning = json["title"],
		_meaning = json["content"], _level = json["level"].toString(),
		_start = json["time"].toString(), _check = json["check_time"].toString(),
		_status = json["status"].toString(), _checker = json["checker"],
		_unchain = json["unchain_time"].toString(), _unchainer = json["unchainer"];

	Map<String, String> toMap() => {
		"id": _id.toString(),
		"name": _name,
		"warning": _warning,
		"meaning": _meaning,
		"level": _level,
		"start": _start,
		"check": _check,
		"checker": _checker,
		"status": _status,
		"unchain": _unchain,
		"unchainer": _unchainer
	};

	int get id => _id;
	String get start => _start;
	String get level => _level;
	String get meaning => _meaning;
	String get warning => _warning;
	String get name => _name;
	String get check => _check;
	String get checker => _checker;
	String get status => _status;
	String get unchainer => _unchainer;
	String get unchain => _unchain;
}

class DevPoint {
	final String _name;
	final int _poiID;

	DevPoint(this._name, this._poiID);

	DevPoint.fromJSON(Map json): _name = json["name"],
		_poiID = json["point_id"];

	int get poiID => _poiID;
	String get name => _name;
}

class DevType {
	final int _id;
	final String _name;
	final int _value;

	DevType(this._id, this._name, this._value);

	int get value => _value;
	String get name => _name;
	int get id => _id;
}

class DevProxy {
	final String _id;
	final String _name;

	DevProxy(this._id, this._name);

	String get name => _name;
	String get id => _id;
}

reqTempFunc(Future<http.Response> requester, dynamic Function(dynamic data) succeed) async {
	String message;
	try {
		var resp = await requester;
		if (resp.statusCode == HttpStatus.ok) {
			Map respBody = jsonDecode(resp.body);
			if(respBody["code"] != 100401
			&& respBody["code"] != 100402
			&& respBody["code"] != 100301
			&& respBody["code"] != 0) {
				message = respBody["message"];
			} else {
				message = "请求成功！";
				return Future(() => ResponseInfo(
					succeed(respBody["data"]), message)
				);
			}
		} else {
			message = "后台发生错误，错误码：${resp.statusCode}";
		}
	} catch (e) {
		message = "网络发生错误：${e.toString()}";
	}
	return Future(() => ResponseInfo(null, message));
}

getDevices(int pageIndex) => reqTempFunc(
	http.get(url + devPage.chgBody("type", pageIndex.toString()).cmbBodyAsParamIntoPath()
), (dynamic data) => data);

Future<dynamic> getPointSensor(List<String> devices) => reqTempFunc(http.post(
	url + getPoiSensor.path,
	headers: {"Content-Type": "application/json"},
	body: jsonEncode(getPoiSensor.chgBody("devices", devices).body)
), (dynamic data) {
	global.pointValues = [];
	for (var key in data.keys.toList()) {
		global.pointValues.add(PointVal.fromJSON(data[key]));
	}
	return global.pointValues;
});

Future<dynamic> getDevList() => reqTempFunc(http.post(
	url + listDevices.path,
	headers: {"Content-Type": "application/json"},
	body: jsonEncode(listDevices.body)
), (dynamic data) => data.map<Device>((dev) => Device.fromJSON(dev)).toList());

Future<dynamic> hasAlarms() => reqTempFunc(http.get(url + getAlarms.path), (dynamic data) => data.isNotEmpty);

Future<dynamic> getTempHumi(int time) => reqTempFunc(http.post(
	url + _poiHistory.path,
	headers: {"Content-Type": "application/json"},
	body: jsonEncode(_poiHistory
		.chgBody("id", global.currentDevID)
		.chgBody("points", [29607741, 29607742, 29607739, 29607740])
		.rmvBody("time_range")
		.chgBody("time", time).body)
), (dynamic data) {
	var ret = {
		"humis": <TimeSeriesSales>[],
		"temps": <TimeSeriesSales>[]
	};
	for (var d in data) {
		DateTime dt = DateTime.parse(d["time"]);
		for (var key in d.keys.toList()) {
			String pname = global.protocolMapper[key];
			if (pname == "热通道温度" || pname == "冷通道温度") {
				ret["temps"].add(TimeSeriesSales(dt, d[key].toDouble()));
			} else if (pname == "热通道湿度" || pname == "冷通道湿度") {
				ret["humis"].add(TimeSeriesSales(dt, d[key].toDouble()));
			}
		}
	}
	return ret;
});

Future<dynamic> getEventHistory(DateTime begin, DateTime end) => reqTempFunc(http.post(
	url + devEventHistory.path,
	headers: {"Content-Type": "application/json"},
	body: jsonEncode(devEventHistory.chgBody("device_id", global.currentDevID).chgBody("time_range", [
		begin.toString(), end.toString()
	]).body)
), (dynamic data) => data.map<EventRecord>((rcd) => EventRecord.fromJSON(rcd)).toList());

Future<dynamic> getEventActive() => reqTempFunc(http.get(
	url + devEventActive.chgBody("device_id", global.currentDevID).cmbBodyAsParamIntoPath()
), (dynamic data) => data.map<EventRecord>((rcd) => EventRecord.fromJSON(rcd)).toList());

turnOnOffDev(String devID, int status) => reqTempFunc(http.put(
	url + _turnOnOffDev.path,
	headers: {"Content-Type": "application/json"},
	body: jsonEncode(_turnOnOffDev.chgBody("id", devID).chgBody("status", status).body)
), (dynamic data) => data);

getDevPoints() => reqTempFunc(http.get(
	url + _getDevPoints.chgBody("id", global.currentDevID).cmbBodyAsParamIntoPath()
), (dynamic data) => data.map<DevPoint>((json) {
	return DevPoint.fromJSON(json);
}).toList());

Future<dynamic> getDevPoiHistory(List<int> poiIds, DateTime begin, DateTime end) => reqTempFunc(http.post(
	url + _poiHistory.path,
	headers: {"Content-Type": "application/json"},
	body: jsonEncode(_poiHistory
		.chgBody("id", global.currentDevID)
		.chgBody("points", poiIds.length != 0 && poiIds[0] == 0 ? [] : poiIds)
		.chgBody("time_range", [
		global.dtFmter.format(begin),
		global.dtFmter.format(end)
	])
		.rmvBody("time").body)
), (dynamic data) {
	Map<String, List<TimeSeriesSales>> ret = {};
	for (var d in data) {
		DateTime dt = DateTime.parse(d["time"]);
		for (var key in d.keys.toList()) {
			if (key == "time") {
				continue;
			}
			if (ret[key] == null) {
				ret[key] = [];
			}
			ret[key].add(TimeSeriesSales(dt, d[key].toDouble()));
		}
	}
	return ret;
});

getDevProxyList(String devTyp) => reqTempFunc(http.get(
	url + devProxies.chgBody("device_type", devTyp).cmbBodyAsParamIntoPath()
), (dynamic data) {
	return data.map((dp) => DevProxy(dp["id"].toString(), dp["name"].toString()));
});

getDevTypeList() => reqTempFunc(http.get(url + devTypes.path), (dynamic data) {
	return data.map((dt) => DevType(dt["id"], dt["name"].toString(), dt["value"]));
});

postAddDev(
	String name, int slaveId, int comPort, int typeId, String proxyId
) => reqTempFunc(http.post(
	url + addDevice.path,
	headers: {"Content-Type": "application/json"},
	body: jsonEncode(addDevice
		.chgBody("name", name)
		.chgBody("type", typeId)
		.chgBody("com_port", comPort)
		.chgBody("slave_id", slaveId)
		.chgBody("protocol_id", proxyId)
		.body)
), (dynamic data) => data);

checkVersionForUpdate() async {
	PackageInfo pi = await PackageInfo.fromPlatform();
	List<String> subVers = pi.version.split(".");
	int v1 = int.parse(subVers[0]);
	int v2 = int.parse(subVers[1]);
	int v3 = int.parse(subVers[2]);
	for (int i = 0; i <= 5; i++) {
		for (int j = 0; j <= 10; j++) {
			for (int t = 0; t <= 15; t++) {
				String ver = "${v1 + i}.${v2 + j}.${v3 + t}";
				print(ver);
			}
		}
	}
}