Session.set('file', null)

Meteor.autosubscribe ->
	Meteor.subscribe 'sensorposition', Session.get('file')
	Meteor.subscribe 'sensordata', Session.get('file')