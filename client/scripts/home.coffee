Template.home.rendered = ()->
	Meteor.call('print', (err,result)->
		console.log 'TEST'
		console.log result
	)


