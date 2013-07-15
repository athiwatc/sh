Template.home.rendered = ()->
	Meteor.call('print', (err,result)->
		console.log 'TEST X'
		console.log result
		#for r in result
		#	$('body').append(r + '</br>')
	)


