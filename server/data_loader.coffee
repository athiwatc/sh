fs = Npm.require('fs')


#Meteor.method

#Remove old data
#SensorPosition.remove({})
#SensorData.remove({})

Meteor.methods {
  #Call everything the user wants to load a new data set
  update: (pos_file, data_file) ->
    #Check if the filename is a string
    ##check(data_file, String)
    #SensorPosition.remove({})
    (->
      #Result if the result is already in the database to save time
      return if SensorPosition.findOne({file: pos_file})
      #Read out the file to memory
      data = fs.readFileSync('public/uploaded-files~/position-files/' + pos_file)
      #Split it into pieces for processing
      pos = data.toString().split(/\r\n|\r|\n/g);
      for x in pos
        p = x.split(' ')
        #Inserting it into the database one by one
        SensorPosition.insert({file: pos_file, name: p[0], x: parseInt(p[1]), y: parseInt(p[2])})
    )()
    


    #SensorData.remove({})
    (->
      return if SensorData.findOne({file: data_file})
      sd = new SensorDictionary(pos_file)
      c = new ConvertorTimelineFormat('uploaded-files~/' + data_file, sd)
      data =  c.getData()
      events  = data
      for event in events
        x = event.split(' ')
        if x[0] == '0'
          SensorData.insert({file: data_file, type: 0, time: parseInt(x[1]), event: x[2], status: x[3]})
        else
          SensorData.insert({file: data_file, type: 1, time: parseInt(x[1]), sensor: x.splice(2)})
    )() 
     
}

