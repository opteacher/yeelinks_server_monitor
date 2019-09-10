import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'global.dart' as global;
import 'components.dart';

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

const url = "http://10.168.1.95:9090";// "http://test_api.ncpi-om.com"
final listDevice = RequestInfo("POST", "/api/v1/devices/list", {});
final getPoiSensor = RequestInfo("GET", "/api/v1/points/sensor", {});
final humiture = RequestInfo("POST", "/api/v1/points/history", {
	"device_id": "",
	"points": [],
	"time_range": ["2019-07-01", "2019-08-22"]
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

	Device.fromJSON(Map json):
		_id = json["id"], _name = json["name"], _type = json["type"],
		_typeStr = json["device_type_str"], _protocolId = json["protocol_id"];

	String get name => _name;
	String get id => _id;
	int get type => _type;
	String get protocolId => _protocolId;
	String get typeStr => _typeStr;
}

class PointVal {
	final String _deviceId;
	final String _pointId;
	final String _value;

	PointVal(this._deviceId, this._pointId, this._value);

	String get value => _value;
	String get pointId => _pointId;
	String get deviceId => _deviceId;
}

class EventRecord {
	final String _name;
	final String _warning;
	final String _meaning;
	final String _level;
	final String _start;

	EventRecord(this._name, this._warning, this._meaning, this._level, this._start);

	String get start => _start;
	String get level => _level;
	String get meaning => _meaning;
	String get warning => _warning;
	String get name => _name;

	Map<String, String> toMap() => {
		"name": _name,
		"warning": _warning,
		"meaning": _meaning,
		"level": _level,
		"start": _start,
	};
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

getDevices(String companyCode, String roomCode) => reqTempFunc(http.post(
	url + listDevice.path,
	headers: {"Content-Type": "application/json"},
	body: jsonEncode(listDevice.body)
), (dynamic data) {
	for (var dynDev in data["devices"]) {
		global.devices.add(Device.fromJSON(dynDev));
	}
	return global.devices;
});

Future<dynamic> getPointSensor() => reqTempFunc(http.get(url + getPoiSensor.path), (dynamic data) {
//	if (data["alarms"].isNotEmpty && !global.manualLight) {
//		global.platform.invokeMethod("lightUp", { "color": "RED", "brightness": 50 });
//	}
	List<EventRecord> alarms = [];
	for (var ala in data["alarms"]) {
		alarms.add(EventRecord(
			ala["device_name"].toString(),
			ala["title"].toString(),
			ala["content"].toString(),
			ala["level"].toString(),
			ala["time"].toString()
		));
	}
	List<PointVal> sensors = [];
	data["sensors"].forEach((_, inf) {
		sensors.add(PointVal(
			inf["device_id"].toString(),
			inf["point_id"].toString(),
			inf["value"].toString()
		));
	});
	return {
		"alarms": alarms,
		"sensors": sensors,
	};
});

getHumiture(String devId, String poiId, TimeSectionEnum tmRng) {
	var reqBody = humiture.body;
	reqBody["device_id"] = devId;
	reqBody["points"] = [int.parse(poiId)];
//	var now = DateTime.now();
//	switch (tmRng) {
//	case TimeSectionEnum.in1Hour:
//		reqBody["time_range"] = [
//			now.subtract(Duration(hours: 1)).toString(),
//			now.toString()
//		];
//		break;
//	case TimeSectionEnum.in24Hours:
//		reqBody["time_range"] = [
//			now.subtract(Duration(days: 1)).toString(),
//			now.toString()
//		];
//		break;
//	case TimeSectionEnum.in1Mon:
//		reqBody["time_range"] = [
//			now.subtract(Duration(days: 30)).toString(),
//			now.toString()
//		];
//		break;
//	case TimeSectionEnum.in1Year:
//		reqBody["time_range"] = [
//			now.subtract(Duration(days: 356)).toString(),
//			now.toString()
//		];
//		break;
//	}
	return reqTempFunc(http.post(url + humiture.path,
		headers: {"Content-Type": "application/json"},
		body: jsonEncode(reqBody)
	), (dynamic data) {
		if (data == null || data.length == 0) {
			return [];
		}
		var now = DateTime.parse(data[data.length - 1]["time"].toString());
		DateTime startTime;
		switch (tmRng) {
		case TimeSectionEnum.in1Hour:
			startTime = now.subtract(Duration(hours: 1));
			break;
		case TimeSectionEnum.in24Hours:
			startTime = now.subtract(Duration(days: 1));
			break;
		case TimeSectionEnum.in1Mon:
			startTime = now.subtract(Duration(days: 30));
			break;
		case TimeSectionEnum.in1Year:
			startTime = now.subtract(Duration(days: 365));
			break;
		}
		List<TimeSeriesSales> ret = [];
		for (var i = data.length - 1; i >= 0; i--) {
			var tsTime = DateTime.parse(data[i]["time"].toString());
			if (tsTime.isAfter(startTime)) {
				ret.add(TimeSeriesSales(tsTime, double.parse(data[i][poiId].toString())));
			} else {
				break;
			}
		}
		return ret;
	});
}

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