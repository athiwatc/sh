(function(){ Template.visualize.rendered = function() {
  window.canvasObject = [];
  window.position = {};
  window.sensors = null;
  window.canvas = oCanvas.create({
    canvas: "#canvas",
    fps: 1
  });
  $('#canvas').attr('width', 0);
  $('#canvas').attr('height', 0);
  window.ellipse = window.canvas.display.ellipse({
    x: 100,
    y: 100,
    radius: 15,
    fill: "rgba(0,0,0,0.1)"
  });
  return window.canvas.setLoop(function() {
    var e, pos, sensor, temp, _i, _len, _ref;

    temp = SensorData.findOne({
      type: 1,
      time: window.currentTime.unix()
    });
    if (temp != null) {
      window.sensors = temp;
    }
    _ref = window.sensors.sensor;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sensor = _ref[_i];
      pos = SensorPosition.findOne({
        name: sensor
      });
      if (pos != null) {
        e = window.ellipse.clone();
        e.x = pos.x;
        e.y = pos.y;
        window.canvasObject.push({
          e: e,
          count: 0
        });
        window.canvas.addChild(e);
      }
    }
    while (window.canvasObject.length >= 60) {
      window.canvas.removeChild(window.canvasObject.shift().e);
    }
    window.canvasObject = _.filter(window.canvasObject, function(canvasObject, index) {
      window.canvasObject[index].count += 1;
      if (canvasObject.count >= window.keep) {
        window.canvas.removeChild(canvasObject.e);
        return false;
      } else {
        return true;
      }
    });
    window.currentTime.add('s', 1);
    return $('#currentTime').val(window.currentTime.toString());
  });
};

Template.visualize.events({
  'click .start': function() {
    $('.start').attr("disabled", true);
    $('.stop').removeAttr("disabled");
    window.canvas.settings.fps = parseInt($('#speed').val());
    window.currentTime = moment($('#currentTime').val());
    window.keep = parseInt($('#keep').val());
    return window.canvas.timeline.start();
  },
  'click .stop': function() {
    $('.stop').attr("disabled", true);
    $('.start').removeAttr("disabled");
    return window.canvas.timeline.stop();
  },
  'click .reset': function() {
    return window.canvas.reset();
  },
  'click #loadButton': function() {
    var filename, l;

    $('#canvas').css('background', 'url()');
    l = Ladda.create(document.querySelector('#loadButton'));
    l.start();
    filename = $('#file').val();
    Session.set('file', filename);
    return Meteor.call('update', filename, function() {
      var img;

      $('#canvas').css('background', 'url(/' + filename + '-pic.png)');
      img = new Image();
      img.onload = function() {
        $('#canvas').attr('width', this.width);
        return $('#canvas').attr('height', this.height);
      };
      img.src = '/' + filename + '-pic.png';
      return l.stop();
    });
  }
});

}).call(this);
