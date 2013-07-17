Template.upload.rendered = ()->
	Meteor.call('getAllUploadedFilesName', (err,result)->
		console.log result
		unique_id = 0
		for r in result
			div_name = 'file_' + unique_id + '_div'
			$('#files-list').append("<div id=#{div_name}>" + "<h2>#{r}</h2> <button class='deleted' unique_id='#{unique_id}' type='button' file='#{r}'>Click Me!</button>" + '</div>')
			unique_id += 1
		$('.deleted').click( ()->
			f = $('.deleted').attr('file')
			unique_id = $('.deleted').attr('unique_id')
			Meteor.call('deleteFile',f, (err,result)->
				console.log result
				if result == true
					div_name = 'file_' + unique_id + '_div'
					$('#' + div_name).remove()
				else
					console.log 'ERROR: Delete file ' + f
			)
			
		)
	)