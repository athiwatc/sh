/* global Meteor:false */
/* global FilesName:false */

Meteor.methods({
	// Upload methods
	'upload': function(data) {
		'use strict';

		data.save('public/uploaded-files~/');
		var filename = data.name;
		// Insert into the database.
		//console.log('asd');
		FilesName.insert({filename: filename});
		//FilesName.find({}) // Get all files
		//FilesName.find({}).fetch() // Get all files as an array.
		//FilesName.remove({filename: 'XXX'}) // to remove
	}
});