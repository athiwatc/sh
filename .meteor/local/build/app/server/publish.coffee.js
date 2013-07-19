Meteor.publish('sensordata', function(file) {
  return SensorData.find({
    file: file
  });
});

Meteor.publish('sensorposition', function(file) {
  return SensorPosition.find({
    file: file
  });
});

Meteor.publish(null, function() {
  return FilesName.find({});
});
