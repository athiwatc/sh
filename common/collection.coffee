@SensorPosition = new Meteor.Collection 'sp'
@SensorData = new Meteor.Collection 'sd'
@FilesName = new Meteor.Collection 'fs'
@PosFilesName = new Meteor.Collection 'pfs'
@MapFilesName = new Meteor.Collection 'mfn'

@PieChartFS = new CollectionFS('pc', { autopublish: false });
@ChordDiagramFS = new CollectionFS('cd', { autopublish: false });
@TimelineFS = new CollectionFS('tl', { autopublish: false });
@UploadFS = new CollectionFS('u', { autopublish: false });