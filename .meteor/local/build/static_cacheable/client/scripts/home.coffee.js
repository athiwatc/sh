(function(){ Template.home.rendered = function() {
  var file_name, map_url, pos_name;

  file_name = "NONE";
  pos_name = "NONE";
  map_url = "NONE";
  if (Session.get("rendered-filename") !== void 0 && Session.get("rendered-filename") !== null) {
    file_name = Session.get("rendered-filename");
  }
  if (Session.get("rendered-posfile") !== void 0 && Session.get("rendered-posfile") !== null) {
    pos_name = Session.get("rendered-posfile");
  }
  if (Session.get("rendered-mapurl") !== void 0 && Session.get("rendered-mapurl") !== null) {
    map_url = Session.get("rendered-mapurl");
  }
  return $('#current-render').html('Data File: ' + file_name + '</br>Position File: ' + pos_name + '</br>Map URL: ' + map_url);
};

Template.home.data_files = function() {
  return FilesName.find({});
};

Template.home.pos_files = function() {
  return PosFilesName.find({});
};

Template.home.events({
  'click #render-file': function() {
    var file_name, map_url, pos_name;

    file_name = $('select#render-list option:selected').val();
    pos_name = $('select#pos-list option:selected').val();
    map_url = $('#map-url').val();
    Session.set("rendered-filename", file_name);
    Session.set("rendered-posfile", pos_name);
    Session.set("rendered-mapurl", map_url);
    return $('#current-render').html('Rendered Data File: ' + file_name + '</br>Rendered Position File: ' + pos_name + '</br>Rendered Map URL: ' + map_url);
  }
});

}).call(this);
