Meteor.methods({
	'upload': function(data) {
		data.save('public/uploaded-files~/');
		filename = data.name;
	}
});