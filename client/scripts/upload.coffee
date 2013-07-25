# ## Template data section
Template.upload.data_files = () ->
  FilesName.find({})

Template.upload.pos_files = () ->
  PosFilesName.find({})

Template.upload.rendered = ()->

# ## Events Handler
Template.upload.events({
  'click #browse-file': ()->
    $("#files").trigger('click');

  'click #browse-file-pos': ()->
    $("#files_position").trigger('click');

  'click #uploadButton': () ->
    # Calling upload services
    MeteorFile.upload($('#files')[0].files[0], 'uploadData', {}, (err, data) ->
      if err
        # Error
        alert 'Cannot upload file: ' + err.reason
    );
        
  'click #uploadButtonPosition': () ->
    # Calling upload services
    MeteorFile.upload($('#files_position')[0].files[0], 'uploadPosition', {}, (err, data) ->
      if err
        alert 'Cannot upload file: ' + err.reason
    );

  'click .deleted': (event)->
    # Delete the files
    file_id = $(event.target).attr('data-file')
    file_type = $(event.target).attr('data-type')
    # Call delete file event
    Meteor.call('deleteFile',file_id,file_type, (err,result)->
      if file_type == 'data' && Session.equals("rendered-filename", name)
        Session.set("rendered-filename", null)
      else if file_type == 'pos' && Session.equals("rendered-posfile", name)
        Session.set("rendered-posfile", null)
      div_name = 'file_' + file_id + '_div'
      $('#' + div_name).remove()
    )

  # View the content of the files
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