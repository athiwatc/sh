(function(){ /* global Session:false */
/* global Meteor:false */

// ##Subscription

// Set the session variable file to null. So on load the server won't be sending us data.
//Session.set('file', null);
// Autosubscript to the file session variable so that when we want to request a different file the data will be sent to us.
Meteor.autosubscribe(function() {
	'use strict';

	// Request for the file data. Position
	Meteor.subscribe('sensorposition', Session.get('rendered-posfile'));
	console.log(Session.get('rendered-filename'));
	Meteor.subscribe('sensordata', Session.get('rendered-filename'));
});
}).call(this);
