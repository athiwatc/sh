(function(){ Template.coor.events({
  'click #copyoutput': function(e) {
    var i, result;

    e.preventDefault();
    i = 0;
    result = '';
    while (true) {
      if ($('#sensor' + i).length === 0) {
        break;
      }
      result += $('#sensor' + i + ' [name=sensor]').val() + " " + $('#sensor' + i + ' [name=form_x]').val() + " " + $('#sensor' + i + ' [name=form_y]').val() + '\n';
      i += 1;
    }
    return $('#output').text(result);
  },
  'click #loadcoor': function() {
    return $('#picture').attr('src', $('#filecoor').val());
  }
});

this.addSensorForm = function(x, y) {
  var added, counter, deleted, p;

  p = window.prompt("Input a name for the point", "NoName");
  if (p !== null && p !== "") {
    counter = $('#data_div').attr("counter");
    added = "<div id='sensor" + counter + "'>Sensor name = <input type='text' name='sensor' value='" + p + "' size='10'/> x = <input type='text' name='form_x' size='4' value='" + x + "'/>, y = <input type='text' name='form_y' size='4' value='" + y + "'/>";
    deleted = " <button type='button' class='btn btn-primary' id='remove" + counter + "'>Remove</button> </br></div>";
    $("#data_div").append(added + deleted);
    $("#remove" + counter).click(function() {
      return $("#sensor" + counter).remove();
    });
    return $("#data_div").attr("counter", parseInt(counter) + 1);
  }
};

this.pointIt = function(event) {
  var pos_x, pos_y;

  if (event.offsetY) {
    pos_x = event.offsetX;
  } else {
    pos_x = event.pageX - $("#pointer_div").offsetLeft;
  }
  if (event.offsetY) {
    pos_y = event.offsetY;
  } else {
    pos_y = event.pageY - $("#pointer_div").offsetTop;
  }
  /*$("#cross").css("left", parseInt(pos_x) - 1)
  	$("#cross").css("top", parseInt(pos_y) - 1)
  	$("#cross").css("visibility", "visible")
  */

  return addSensorForm(pos_x, pos_y);
};

}).call(this);
