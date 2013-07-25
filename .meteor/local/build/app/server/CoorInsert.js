fs = Npm.require('fs');

Meteor.methods({
	'coor': function(filename, data) {
		fs.writeFile("public/uploaded-files~/position-files/" + filename, data, function(err) {
		    if(err) {
		        console.log(err);
		    } else {
		        console.log("The file was saved!");
		    }
		}); 
	}
});