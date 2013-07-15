# ## Coorninate picker

Template.coor.events {
	# On click the generate button
	'click #copyoutput': (e) ->
		#Prevent the default form action
		e.preventDefault()
		i = 0
		result = ''
		# Loop while the sensor still exists
		while true
			# Get OUT!!!@!@!
			break if $('#sensor'+i).length == 0
			#Store the result from the sensor
			result += $('#sensor'+i+' [name=sensor]').val() + " " + $('#sensor'+i+' [name=form_x]').val() + " " + $('#sensor'+i+' [name=form_y]').val() + '\n'
			i += 1
		# Set the output textarea box
		$('#output').text(result)
	'click #loadcoor': ->
		# Load the image file to the field
		$('#picture').attr('src', $('#filecoor').val())

}

# Add data to the form.
@addSensorForm = (x,y)->
	p = window.prompt("Input a name for the point","NoName");
	if (p!=null && p!="")
		counter = $('#data_div').attr("counter")
		added = "<div id='sensor#{counter}'>Sensor name = <input type='text' name='sensor' value='#{p}' size='10'/> x = <input type='text' name='form_x' size='4' value='#{x}'/>, y = <input type='text' name='form_y' size='4' value='#{y}'/>"
		deleted = " <button type='button' class='btn btn-primary' id='remove#{counter}'>Remove</button> </br></div>"
		$("#data_div").append(added + deleted)
		$("#remove#{counter}").click(()->
			$("#sensor#{counter}").remove()
		)
		$("#data_div").attr("counter", parseInt(counter) + 1)

# Call when the user clicks on the image.
@pointIt = (event)->
	if event.offsetY
		pos_x = event.offsetX
	else
		pos_x = event.pageX - $("#pointer_div").offsetLeft
	if event.offsetY
		pos_y = event.offsetY
	else
		pos_y = event.pageY - $("#pointer_div").offsetTop
	###$("#cross").css("left", parseInt(pos_x) - 1)
	$("#cross").css("top", parseInt(pos_y) - 1)
	$("#cross").css("visibility", "visible")###
	addSensorForm(pos_x,pos_y)