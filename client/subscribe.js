Session.set('file', null);
Meteor.autosubscribe(function() {
    return Meteor.subscribe('sensorposition', Session.get('file'));
});
Meteor.subscribe('sensordata', Session.get('file'));