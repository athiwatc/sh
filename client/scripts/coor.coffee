# ## Coorninate picker

Template.coor.events {
  # On click the generate button
  'click #copyoutput': (e) ->
    #Prevent the default form action
    e.preventDefault()
    i = 0
    result = ''
    max = $('#data_div').attr("max-counter")
    # Loop while the sensor still exists
    while i <= max
      if $('#sensor'+i).length != 0
      #Store the result from the sensor
        result += $('#sensor'+i+' [name=sensor]').val() + " " + $('#sensor'+i+' [name=form_x]').val() + " " + $('#sensor'+i+' [name=form_y]').val() + '\n'
      i += 1
    # Set the output textarea box
    if (PosFilesName.findOne({filename: $('#filename').val()})?)
      alert('Duplicated File')
    else
      Meteor.call('coor', $('#filename').val(), result, () ->
        PosFilesName.insert({filename: $('#filename').val()})
        alert('File added')
      )
  'click #loadcoor': ->
    # Load the image file to the field
    $('#picture').attr('src', $('#filecoor').val())

}

# Add data to the form.
@addSensorForm = (x,y)->
  # Ask the user for the name of the point.
  p = window.prompt("Input a name for the point","NoName")
  # Check if the user input any data or not.
  if (p!=null && p!="")
    # Set the counter data...
    counter = $('#data_div').attr("counter")
    max_counter = $('#data_div').attr("max-counter")
    # Adding them so the user can see it.
    added = "<div id='sensor#{counter}'>Sensor name = <input type='text' name='sensor' value='#{p}' size='10'/> x = <input type='text' name='form_x' size='4' value='#{x}'/>, y = <input type='text' name='form_y' size='4' value='#{y}'/>"
    deleted = " <button type='button' class='btn btn-primary' id='remove#{counter}'>Remove</button> </br></div>"
    $("#data_div").append(added + deleted)
    $("#remove#{counter}").click(()->
      $("#sensor#{counter}").remove()
    )
    $("#data_div").attr("max-counter", parseInt(max_counter) + 1)
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