Template.upload.data_files = () ->
  FilesName.find({})

Template.upload.pos_files = () ->
  PosFilesName.find({})

Template.upload.rendered = ()->

Template.upload.events({
  'click #browse-file': ()->
    $("#files").trigger('click');

  'click #browse-file-pos': ()->
    $("#files_position").trigger('click');

  'click #uploadButton': () ->
    MeteorFile.upload($('#files')[0].files[0], 'uploadData', {}, (err, data) ->
      if err
        alert 'Cannot upload file: ' + err.reason
    );
        
  'click #uploadButtonPosition': () ->
    MeteorFile.upload($('#files_position')[0].files[0], 'uploadPosition', {}, (err, data) ->
      if err
        alert 'Cannot upload file: ' + err.reason
    );

  'click .deleted': (event)->
    file_id = $(event.target).attr('data-file')
    file_type = $(event.target).attr('data-type')
    Meteor.call('deleteFile',file_id,file_type, (err,result)->
      if file_type == 'data' && Session.equals("rendered-filename", name)
        Session.set("rendered-filename", null)
      else if file_type == 'pos' && Session.equals("rendered-posfile", name)
        Session.set("rendered-posfile", null)
      div_name = 'file_' + file_id + '_div'
      $('#' + div_name).remove()
    )

  'click .view': (event)->
    file_id = $(event.target).attr('data-file')
    file_type = $(event.target).attr('data-type')
    Meteor.call('getFileData',file_id,file_type, (err,result)->
      if file_type == 'pos'
        file = PosFilesName.findOne({_id: file_id})
        name = file.filename
      else if file_type == 'data'
        file = FilesName.findOne({_id: file_id})
        name = file.filename
      $('#view-header > h3').html('View Data From: '+ name)
      $('#info-view').html(result)
    )
})