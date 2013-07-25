Template.home.rendered = ()->
	file_name = "NONE"
	pos_name = "NONE"
	map_url = "NONE"
	if Session.get("rendered-filename") != undefined &&  Session.get("rendered-filename") != null
		file_name = Session.get("rendered-filename")
	if Session.get("rendered-posfile") != undefined &&  Session.get("rendered-posfile") != null
		pos_name = Session.get("rendered-posfile")
	if Session.get("rendered-mapurl") != undefined &&  Session.get("rendered-mapurl") != null
		map_url = Session.get("rendered-mapurl")
	$('#current-render').html('Data File: ' + file_name + '</br>Position File: '+ pos_name + '</br>Map URL: ' +map_url)


Template.home.data_files = () ->
	FilesName.find({})

Template.home.pos_files = () ->
	PosFilesName.find({})


Template.home.events({
	'click #render-file': () ->
		file_name = $('select#render-list option:selected').val()
		pos_name = $('select#pos-list option:selected').val()
		map_url = $('#map-url').val()
		Session.set("rendered-filename", file_name)
		Session.set("rendered-posfile", pos_name)
		Session.set("rendered-mapurl", map_url)
		$('#current-render').html('Rendered Data File: ' + file_name + '</br>Rendered Position File: '+ pos_name + '</br>Rendered Map URL: ' +map_url)
})

