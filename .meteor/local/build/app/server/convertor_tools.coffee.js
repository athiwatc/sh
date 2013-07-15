var Convertor, ConvertorTimelineFormat, DataFilter, Map, SensorDictionary, Set, VisualizeParser, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.fs = Npm.require('fs');

SensorDictionary = (function() {
  function SensorDictionary(path) {
    this._dict = [];
    this._init(path);
  }

  SensorDictionary.prototype._init = function(path) {
    var data, l, lines, tmp, _i, _len, _results;

    data = fs.readFileSync('./public/' + path, 'utf8');
    lines = data.toString().split('\r\n');
    _results = [];
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      l = lines[_i];
      if (l[0] !== '#') {
        tmp = l.split(' ');
        _results.push(this._dict[tmp[0]] = {
          x: tmp[1],
          y: tmp[2]
        });
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  SensorDictionary.prototype.containsKey = function(key) {
    return this._dict[key] !== void 0;
  };

  SensorDictionary.prototype.getXPOS = function(key) {
    if (this.containsKey(key)) {
      return this._dict[key].x;
    }
    return void 0;
  };

  SensorDictionary.prototype.getYPOS = function(key) {
    if (this.containsKey(key)) {
      return this._dict[key].y;
    }
    return void 0;
  };

  return SensorDictionary;

})();

/*
Use to convert data
From format: 
Date Time Sensor_Name Status
or
Date Time Activity_Name Status

2008-02-27	12:45:14.498824	M13	OFF
2008-02-27	12:49:15 asterisk END
To:
1 Unixtime xPos yPos sensor_name sensor_status
0 Unixtime event_name event_status

1 1204112862 683 123 M13 OFF
0 1204116555 asterisk START 

Line of data that is a sensor activation, its converted format data would put prefix '1' in the front
List of data that is a activity, convert, its converted format data would put prefix '0' in the front
*/


Convertor = (function() {
  function Convertor(_path, _sensor_dict) {
    this._path = _path;
    this._sensor_dict = _sensor_dict;
    this._data = [];
    this._preProcessingData();
  }

  Convertor.prototype.getData = function() {
    var result, s, _i, _len, _ref;

    result = [];
    _ref = this._data;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      s = _ref[_i];
      result.push(s);
    }
    return result;
  };

  Convertor.prototype._preProcessingData = function() {
    var l, lines, tmp_data, _i, _len;

    tmp_data = fs.readFileSync('./public/' + this._path, 'utf8');
    lines = tmp_data.toString().split('\n');
    for (_i = 0, _len = lines.length; _i < _len; _i++) {
      l = lines[_i];
      this._data.push(l);
    }
    return this._convertData();
  };

  Convertor.prototype._convertData = function() {
    var addition, is_zero, line, output, result, s, temp, _i, _j, _len, _len1, _ref;

    output = [];
    _ref = this._data;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      temp = line.split(/[\s]/);
      is_zero = true;
      for (_j = 0, _len1 = temp.length; _j < _len1; _j++) {
        s = temp[_j];
        if (this._sensor_dict.containsKey(s)) {
          result = this._processArrayForPrefixOne(temp);
          output.push(this._parseString(result));
          is_zero = false;
          if (temp.length > 4) {
            addition = [temp[0], temp[1], temp[4], temp[5]];
            result = this._processArrayForPrefixZero(addition);
            output.push(this._parseString(result));
          }
          break;
        }
      }
      if (is_zero && temp.length > 2) {
        result = this._processArrayForPrefixZero(temp);
        output.push(this._parseString(result));
      }
    }
    return this._data = output;
  };

  Convertor.prototype._parseString = function(arr) {
    var a, s, _i, _len;

    s = '';
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      a = arr[_i];
      s += ' ' + a;
    }
    return s;
  };

  Convertor.prototype._processArrayForPrefixZero = function(arr) {
    var result;

    result = [];
    result[0] = "0";
    result[1] = this._convertStringDateToUnix(arr[0], arr[1]) + "";
    result[2] = arr[arr.length - 2];
    result[3] = arr[arr.length - 1];
    return result;
  };

  Convertor.prototype._processArrayForPrefixOne = function(arr) {
    var result;

    result = [];
    result[0] = "1";
    result[1] = this._convertStringDateToUnix(arr[0], arr[1]) + "";
    result[2] = this._sensor_dict.getXPOS(arr[2]) + "";
    result[3] = this._sensor_dict.getYPOS(arr[2]) + "";
    result[4] = arr[2];
    result[5] = arr[3];
    return result;
  };

  Convertor.prototype._convertStringDateToUnix = function(ymd, time) {
    var result, s, t;

    t = time;
    s = ymd + "," + t;
    result = moment(s, "YYYY-MM-DD,HH:mm:ss");
    return result;
  };

  return Convertor;

})();

/*
Use to convert data to timeline format (Standard format for this application)
From format: (Converted data format from Convertor Class)
1 1204112607 568 231 M08 ON 
1 1204112607 503 197 M07 ON 
1 1204112608 592 197 M09 ON 
1 1204112609 683 197 M14 ON 
1 1204112609 484 291 M23 OFF 
1 1204112610 484 261 M01 OFF 
1 1204112610 503 197 M07 OFF 
1 1204112611 683 123 M13 ON 
1 1204112611 568 231 M08 OFF 
1 1204112612 592 197 M09 OFF 
1 1204112613 683 197 M14 OFF
0 1204112620 Phone_call begin

To:
Prefix Unixtime [Active Sensors or Activity] [Activity status if it is activity]
1 1204112607 M07 M08 
1 1204112608 M07 M08 M09 
1 1204112609 M07 M08 M09 M14 
1 1204112610 M08 M09 M14
0 1204112620 Phone_call begin
*/


ConvertorTimelineFormat = (function(_super) {
  __extends(ConvertorTimelineFormat, _super);

  function ConvertorTimelineFormat() {
    _ref = ConvertorTimelineFormat.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  ConvertorTimelineFormat.prototype._preProcessingData = function() {
    ConvertorTimelineFormat.__super__._preProcessingData.apply(this, arguments);
    this._check_on = ["ON", "OPEN", "PRESENT"];
    this._check_off = ["OFF", "CLOSE", "ABSENT"];
    return this._convertToTimeline();
  };

  ConvertorTimelineFormat.prototype._convertToTimeline = function() {
    var element, i, next_data, next_data_prefix, next_data_time, on_sensor, prefix, result, sensor_name, sensor_status, time, tmp;

    on_sensor = new Set();
    result = [];
    time = -1;
    i = 0;
    while (i < this._data.length) {
      tmp = this._data[i].trim().split(/[\s]/);
      prefix = parseInt(tmp[0]);
      element = "";
      if (prefix === 0) {
        result.push(this._data[i].trim());
      } else if (prefix === 1) {
        time = parseInt(tmp[1]);
        sensor_name = tmp[4];
        sensor_status = tmp[5];
        if (this._isIn(sensor_status, this._check_on)) {
          on_sensor.add(sensor_name);
        } else if (this._isIn(sensor_status, this._check_off)) {
          on_sensor.remove(sensor_name);
        }
        element = this._buildStringPrefixOne(time, on_sensor.toList());
        if (i === this._data.length - 1) {
          result.push(element);
        } else {
          next_data = this._data[i + 1].trim().split(/[\s]/);
          next_data_prefix = parseInt(next_data[0]);
          next_data_time = parseInt(next_data[1]);
          if (next_data_prefix === 0 || next_data_time !== time || this._isSameSensorChangeAtTheSameTime(this._data[i].trim(), this._data[i + 1].trim())) {
            result.push(element);
          }
        }
      }
      i += 1;
    }
    return this._data = result;
  };

  ConvertorTimelineFormat.prototype._isIn = function(s1, set) {
    var i, _i, _len;

    for (_i = 0, _len = set.length; _i < _len; _i++) {
      i = set[_i];
      if (i.toLowerCase() === s1.toLowerCase()) {
        return true;
      }
    }
    return false;
  };

  ConvertorTimelineFormat.prototype._buildStringPrefixOne = function(time, set) {
    var output, s, _i, _len;

    output = " " + "1 " + time;
    for (_i = 0, _len = set.length; _i < _len; _i++) {
      s = set[_i];
      output += " " + s;
    }
    return output.trim();
  };

  ConvertorTimelineFormat.prototype._isSameSensorChangeAtTheSameTime = function(s1, s2) {
    var first, second;

    first = s1.split(/[\s]/);
    second = s2.split(/[\s]/);
    if (parseInt(first[1]) !== parseInt(second[1])) {
      return false;
    } else if (!first[4].toLowerCase() === second[4].toLowerCase()) {
      return false;
    } else if (this._isIn(first[5], this._check_on) || this._isIn(first[5], this._check_off)) {
      return !first[5].toLowerCase() === second[5].toLowerCase();
    }
    return false;
  };

  return ConvertorTimelineFormat;

})(Convertor);

Set = (function() {
  function Set() {
    this._storage = [];
  }

  Set.prototype.add = function(element) {
    var e, isThere, _i, _len, _ref1;

    isThere = false;
    _ref1 = this._storage;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      e = _ref1[_i];
      if (e === element) {
        isThere = true;
        break;
      }
    }
    if (!isThere) {
      return this._storage.push(element);
    }
  };

  Set.prototype.remove = function(element) {
    var arr, e, _i, _len, _ref1;

    arr = [];
    _ref1 = this._storage;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      e = _ref1[_i];
      if (e !== element) {
        arr.push(e);
      }
    }
    return this._storage = arr;
  };

  Set.prototype.toList = function() {
    var i, result, _i, _len, _ref1;

    result = [];
    _ref1 = this._storage;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      i = _ref1[_i];
      result.push(i);
    }
    return result;
  };

  Set.prototype.size = function() {
    return this._storage.length;
  };

  return Set;

})();

Map = (function() {
  function Map() {
    this._keys = [];
    this._values = [];
  }

  Map.prototype.containsKey = function(key) {
    if (this._keys.indexOf(key) === -1) {
      return false;
    }
    return true;
  };

  Map.prototype.put = function(key, value) {
    var index;

    index = this._keys.indexOf(key);
    if (index === -1) {
      this._keys.push(key);
      return this._values.push(value);
    } else {
      return this._values[index] = value;
    }
  };

  Map.prototype.size = function() {
    return this._keys.length;
  };

  Map.prototype.get = function(key) {
    var index;

    index = this._keys.indexOf(key);
    return this._values[index];
  };

  Map.prototype.toObjectList = function() {
    var i, result;

    result = [];
    i = 0;
    while (i < this._keys.length) {
      result.push({
        key: this._keys[i],
        value: this._values[i]
      });
      i += 1;
    }
    return result;
  };

  Map.prototype.remove = function(key) {
    var except_index, i, new_keys, new_values;

    except_index = this._keys.indexOf(key);
    i = 0;
    new_keys = [];
    new_values = [];
    while (i < this._keys.length) {
      if (i !== except_index) {
        new_keys.push(this._keys[i]);
        new_values.push(this._values[i]);
      }
      i += 1;
    }
    this._keys = new_keys;
    return this._values = new_values;
  };

  return Map;

})();

DataFilter = (function() {
  function DataFilter(_data) {
    this._data = _data;
  }

  DataFilter.prototype.getData = function() {
    var result, s, _i, _len, _ref1;

    result = [];
    _ref1 = this._data;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      s = _ref1[_i];
      result.push(s);
    }
    return result;
  };

  DataFilter.prototype.setData = function(data) {
    return this._data = data;
  };

  DataFilter.prototype.getAllActivities = function() {
    var activity, count, d, prefix, storage, tmp, _i, _len, _ref1;

    storage = new Map();
    _ref1 = this._data;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      d = _ref1[_i];
      tmp = d.trim().split(/[\s]/);
      prefix = parseInt(tmp[0]);
      if (prefix === 0 && tmp[3].toLowerCase() !== 'end') {
        activity = tmp[2];
        if (!storage.containsKey(activity)) {
          storage.put(activity, 1);
        } else {
          count = storage.get(activity);
          storage.put(activity, count + 1);
        }
      }
    }
    return storage.toObjectList();
  };

  DataFilter.prototype.getAllActivitiesInSequencePair = function() {
    var d, first_activity, prefix, second_activity, second_map, state, state_find_first, state_find_second, state_none, storage, tmp, _i, _len, _ref1;

    this._data = ['0 1 Phone_Call begin', '0 1 Asterick begin', '0 1 Asterick end', '0 1 Phone_Call end', '0 1 Eat begin', '1 1 Asterick end', '0 1 Eat end', '1 1 Asterick end', '0 1 Phone_Call begin', '0 1 Phone_Call end', '1 1 Asterick end', '0 1 Cook begin', '0 1 Cook end', '0 1 Eat begin', '1 1 Asterick end', '0 1 Eat end', '1 1 Asterick end', '1 1 Asterick end', '0 1 Phone_Call begin', '1 1 Asterick end', '0 1 Phone_Call end', '0 1 Eat begin', '1 1 Asterick end', '0 1 Eat end', '1 1 Asterick end', '0 1 Sleep begin', '0 1 Sleep end'];
    storage = new Map();
    state_find_first = 1;
    state_find_second = 2;
    state_none = -1;
    state = state_none;
    first_activity = '';
    second_activity = '';
    _ref1 = this._data;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      d = _ref1[_i];
      tmp = d.trim().split(/[\s]/);
      prefix = parseInt(tmp[0]);
      if (prefix === 0) {
        if (state === state_none) {
          if (tmp[3].toLowerCase() === 'begin') {
            first_activity = tmp[2];
            state = state_find_first;
          }
        } else if (state === state_find_first) {
          if (first_activity === tmp[2] && tmp[3].toLowerCase() === 'end') {
            state = state_find_second;
          }
        } else if (state === state_find_second) {
          if (tmp[3].toLowerCase() === 'begin') {
            second_activity = tmp[2];
            second_map = '';
            if (!storage.containsKey(first_activity)) {
              second_map = new Map();
              second_map.put(second_activity, 1);
            } else {
              second_map = storage.get(first_activity);
              if (!second_map.containsKey(second_activity)) {
                second_map.put(second_activity, 1);
              } else {
                second_map.put(second_activity, second_map.get(second_activity) + 1);
              }
            }
            if (!storage.containsKey(second_activity)) {
              storage.put(second_activity, new Map());
            }
            storage.put(first_activity, second_map);
            first_activity = second_activity;
            state = state_find_first;
          }
        }
      }
    }
    return storage.toObjectList();
  };

  return DataFilter;

})();

VisualizeParser = (function() {
  function VisualizeParser() {}

  VisualizeParser.prototype.parsePieChart = function(data) {
    var obj, path, text, _i, _len;

    path = 'piechart.txt';
    text = 'name,data';
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      obj = data[_i];
      text += '\r\n' + obj.key + ',' + obj.value;
    }
    return fs.writeFileSync('./public/' + path, text);
  };

  VisualizeParser.prototype.parseChordDiagram = function(data) {
    var d, data_matrix, data_text, i, index_key, index_val, matrix_map, obj, path_data, path_matrix, random_color, unique_index, val_list, _i, _j, _k, _l, _len, _len1, _len2, _len3;

    path_data = 'chorddiagram.csv';
    path_matrix = 'matrix.json';
    data_text = 'name,color';
    data_matrix = [];
    matrix_map = new Map();
    unique_index = 0;
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      obj = data[_i];
      random_color = '#' + (0x1000000 + (Math.random()) * 0xffffff).toString(16).substr(1, 6);
      data_text += '\r\n' + obj.key + ',' + random_color;
      matrix_map.put(obj.key, unique_index);
      data_matrix.push([]);
      unique_index += 1;
    }
    for (_j = 0, _len1 = data_matrix.length; _j < _len1; _j++) {
      d = data_matrix[_j];
      i = 0;
      while (i < unique_index) {
        data_matrix[i].push(0);
      }
    }
    for (_k = 0, _len2 = data.length; _k < _len2; _k++) {
      obj = data[_k];
      val_list = obj.value.toObjectList();
      for (_l = 0, _len3 = val_list.length; _l < _len3; _l++) {
        d = val_list[_l];
        index_val = matrix_map.get(d.key);
        index_key = matrix_map.get(obj.key);
        data_matrix[index_key][index_val] = d.value;
      }
    }
    return [data_text, data_matrix];
  };

  return VisualizeParser;

})();

Meteor.methods({
  print: function() {
    var c, data_dia, filter, sd, vp, x;

    sd = new SensorDictionary("all-pos.txt");
    c = new ConvertorTimelineFormat('raw-data-sh.txt', sd);
    filter = new DataFilter(c.getData());
    data_dia = filter.getAllActivitiesInSequencePair();
    vp = new VisualizeParser();
    x = vp.parseChordDiagram(data_dia);
    return x;
  }
});
