current_files = []
unique_id = 0

isInCurrentPage = (file)->
	for f in current_files
		if file == f
			return true
	return false

removeFromCurrentPage = (removed_file)->
	result = []
	for f in current_files
		if f != removed_file
			result.push(f)
	current_files = result

addedFileToCurrentPage = (new_file)->
	if !isInCurrentPage(new_file)
		current_files.push(new_file)
		return true
	return false

Template.upload.rendered = ()->
	updateFilesList()

Template.upload.events({
	'click #uploadButton': () ->
		MeteorFile.upload($('#files')[0].files[0], 'upload', {}, (err, data) ->
			updateFilesList()
		);
})

updateFilesList = ()->
	Meteor.call('getAllUploadedFilesName', (err,result)->
		for r in result
			if addedFileToCurrentPage(r)
				div_name = 'file_' + unique_id + '_div'
				$('#files-list').append("<div id=#{div_name}>" + "<h2>#{r}</h2> <button class='deleted' unique_id='#{unique_id}' type='button' file='#{r}'>Click Me!</button>" + '</div>')
				unique_id += 1
		$('.deleted').click( ()->
			f = $('.deleted').attr('file')
			removeFromCurrentPage(f)
			unique_id = $('.deleted').attr('unique_id')
			Meteor.call('deleteFile',f, (err,result)->
				if result == true
					div_name = 'file_' + unique_id + '_div'
					$('#' + div_name).remove()
				else
					console.log 'ERROR: Delete file ' + f
			)
		)
	)