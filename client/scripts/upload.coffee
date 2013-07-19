Template.upload.files = () ->
	FilesName.find({})

Template.upload.rendered = ()->

Template.upload.events({
	'click #uploadButton': () ->
		MeteorFile.upload($('#files')[0].files[0], 'upload', {}, (err, data) ->
			if err
				alert 'Bad!'
		);

	'click .deleted': (event)->
		file_id = event.target.getAttribute('data-file')
		Meteor.call('deleteFile',file_id, (err,result)->
			if result == true
				div_name = 'file_' + file_id + '_div'
				$('#' + div_name).remove()
			else
				console.log 'ERROR: Delete file ' + file_id
		)

	'click .view': (event)->
		console.log event.target
		file_id = event.target.getAttribute('data-file')
		Meteor.call('getFileData',file_id, (err,result)->
			name = FilesName.find({_id: file_id}).filename
			$('#view-header').html('View Data From: '+ name)
			$('#info-view').html(result)
		)
})