var fs;

fs = Npm.require('fs');

Meteor.methods({
  update: function(filename) {
    check(filename, String);
    (function() {
      var data, p, pos, x, _i, _len, _results;

      if (SensorPosition.findOne({
        file: filename
      })) {
        return;
      }
      data = fs.readFileSync('public/' + filename + '-pos.txt');
      pos = data.toString().split(/\r\n|\r|\n/g);
      _results = [];
      for (_i = 0, _len = pos.length; _i < _len; _i++) {
        x = pos[_i];
        p = x.split(' ');
        _results.push(SensorPosition.insert({
          file: filename,
          name: p[0],
          x: parseInt(p[1]),
          y: parseInt(p[2])
        }));
      }
      return _results;
    })();
    return (function() {
      var data, event, events, x, _i, _len, _results;

      if (SensorData.findOne({
        file: filename
      })) {
        return;
      }
      data = fs.readFileSync('public/' + filename + '-data.txt');
      events = data.toString().split(/\r\n|\r|\n/g);
      _results = [];
      for (_i = 0, _len = events.length; _i < _len; _i++) {
        event = events[_i];
        x = event.split(' ');
        if (x[0] === '0') {
          _results.push(SensorData.insert({
            file: filename,
            type: 0,
            time: parseInt(x[1]),
            event: x[2],
            status: x[3]
          }));
        } else {
          _results.push(SensorData.insert({
            file: filename,
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
