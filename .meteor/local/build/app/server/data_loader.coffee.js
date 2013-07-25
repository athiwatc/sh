var fs;

fs = Npm.require('fs');

Meteor.methods({
  update: function(pos_file, data_file) {
    (function() {
      var data, p, pos, x, _i, _len, _results;

      if (SensorPosition.findOne({
        file: pos_file
      })) {
        return;
      }
      data = fs.readFileSync('public/uploaded-files~/position-files/' + pos_file);
      pos = data.toString().split(/\r\n|\r|\n/g);
      _results = [];
      for (_i = 0, _len = pos.length; _i < _len; _i++) {
        x = pos[_i];
        p = x.split(' ');
        _results.push(SensorPosition.insert({
          file: pos_file,
          name: p[0],
          x: parseInt(p[1]),
          y: parseInt(p[2])
        }));
      }
      return _results;
    })();
    return (function() {
      var c, data, event, events, sd, x, _i, _len, _results;

      if (SensorData.findOne({
        file: data_file
      })) {
        return;
      }
      sd = new SensorDictionary(pos_file);
      c = new ConvertorTimelineFormat('uploaded-files~/' + data_file, sd);
      data = c.getData();
      events = data;
      _results = [];
      for (_i = 0, _len = events.length; _i < _len; _i++) {
        event = events[_i];
        x = event.split(' ');
        if (x[0] === '0') {
          _results.push(SensorData.insert({
            file: data_file,
            type: 0,
            time: parseInt(x[1]),
            event: x[2],
            status: x[3]
          }));
        } else {
          _results.push(SensorData.insert({
            file: data_file,
            type: 1,
            time: parseInt(x[1]),
            sensor: x.splice(2)
          }));
        }
      }
      return _results;
    })();
  }
});
