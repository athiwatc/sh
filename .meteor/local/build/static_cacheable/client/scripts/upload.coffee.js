(function(){ Template.upload.rendered = function() {
  return Meteor.call('getAllUploadedFilesName', function(err, result) {
    var div_name, r, unique_id, _i, _len;

    console.log(result);
    unique_id = 0;
    for (_i = 0, _len = result.length; _i < _len; _i++) {
      r = result[_i];
      div_name = 'file_' + unique_id + '_div';
      $('#files-list').append(("<div id=" + div_name + ">") + ("<h2>" + r + "</h2> <button class='deleted' unique_id='" + unique_id + "' type='button' file='" + r + "'>Click Me!</button>") + '</div>');
      unique_id += 1;
    }
    return $('.deleted').click(function() {
      var f;

      f = $('.deleted').attr('file');
      unique_id = $('.deleted').attr('unique_id');
      return Meteor.call('deleteFile', f, function(err, result) {
        console.log(result);
        if (result === true) {
          div_name = 'file_' + unique_id + '_div';
          return $('#' + div_name).remove();
        } else {
          return console.log('ERROR: Delete file ' + f);
        }
      });
    });
  });
};

}).call(this);
