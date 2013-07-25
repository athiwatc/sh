this.SensorPosition = new Meteor.Collection('sp');

this.SensorData = new Meteor.Collection('sd');

this.FilesName = new Meteor.Collection('fs');

this.PosFilesName = new Meteor.Collection('pfs');

this.MapFilesName = new Meteor.Collection('mfn');

this.PieChartFS = new CollectionFS('pc', {
  autopublish: false
});

this.ChordDiagramFS = new CollectionFS('cd', {
  autopublish: false
});

this.TimelineFS = new CollectionFS('tl', {
  autopublish: false
});

this.UploadFS = new CollectionFS('u', {
  autopublish: false
});
