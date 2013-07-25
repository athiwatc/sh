
Meteor.publish('sensordata', function(file) {
  console.log(file);
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
Meteor.publish(null, function() {
  return PosFilesName.find({});
});
Meteor.publish(null, function() {
  return MapFilesName.find({});
});



//Files

Meteor.publish('piechart', function(filename) {
    return PieChartFS.find({ filename: filename });
});

Meteor.publish('chorddiagram', function(filename) {
    return ChordDiagramFS.find({ filename: filename });
});

Meteor.publish('timeline', function(filename) {
    return TimelineFS.find({ filename: filename });
});

Meteor.publish(null, function() {
  return UploadFS.find({});
})