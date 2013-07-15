Meteor.Router.add({
	'/': 'home',
	'/:go': function(go) {return go;}
});