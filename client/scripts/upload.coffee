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

	'click .view': ()->
		f = this.getAttribute('file')
		###Meteor.call('getFileData',f, (err,result)->
			$('#view-header').html('View Data From: '+ f)
			$('#info-view').html(result)
		)###
})