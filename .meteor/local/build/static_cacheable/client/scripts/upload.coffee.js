(function(){ Template.upload.data_files = function() {
  return FilesName.find({});
};

Template.upload.pos_files = function() {
  return PosFilesName.find({});
};

Template.upload.rendered = function() {};

Template.upload.events({
  'click #browse-file': function() {
    return $("#files").trigger('click');
  },
  'click #browse-file-pos': function() {
    return $("#files_position").trigger('click');
  },
  'click #uploadButton': function() {
    return MeteorFile.upload($('#files')[0].files[0], 'uploadData', {}, function(err, data) {
      if (err) {
        return alert('Cannot upload file: ' + err.reason);
      }
    });
  },
  'click #uploadButtonPosition': function() {
    return MeteorFile.upload($('#files_position')[0].files[0], 'uploadPosition', {}, function(err, data) {
      if (err) {
        return alert('Cannot upload file: ' + err.reason);
      }
    });
  },
  'click .deleted': function(event) {
    var file_id, file_type;

    file_id = $(event.target).attr('data-file');
    file_type = $(event.target).attr('data-type');
    return Meteor.call('deleteFile', file_id, file_type, function(err, result) {
      var div_name;

      if (file_type === 'data' && Session.equals("rendered-filename", name)) {
        Session.set("rendered-filename", null);
      } else if (file_type === 'pos' && Session.equals("rendered-posfile", name)) {
        Session.set("rendered-posfile", null);
      }
      div_name = 'file_' + file_id + '_div';
      return $('#' + div_name).remove();
    });
  },
  'click .view': function(event) {
    var file_id, file_type;

    file_id = $(event.target).attr('data-file');
    file_type = $(event.target).attr('data-type');
    return Meteor.call('getFileData', file_id, file_type, function(err, result) {
      var file, name;

      if (file_type === 'pos') {
        file = PosFilesName.findOne({
          _id: file_id
        });
        name = file.filename;
      } else if (file_type === 'data') {
        file = FilesName.findOne({
          _id: file_id
        });
        name = file.filename;
      }
      $('#view-header > h3').html('View Data From: ' + name);
      return $('#info-view').html(result);
    });
  }
});

}).call(this);
