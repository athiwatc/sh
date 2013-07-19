Meteor.publish 'sensordata', (file) ->
  SensorData.find({file: file})

Meteor.publish 'sensorposition', (file) ->
  SensorPosition.find({file: file})

Meteor.publish null, () ->
  FilesName.find({})