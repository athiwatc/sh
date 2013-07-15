fs = Npm.require('fs')


#Meteor.method

#Remove old data
#SensorPosition.remove({})
#SensorData.remove({})

Meteor.methods {
  #Call everything the user wants to load a new data set
  update: (filename) ->
    #Check if the filename is a string
    check(filename, String)
    #SensorPosition.remove({})
    (->
      #Result if the result is already in the database to save time
      return if SensorPosition.findOne({file: filename})
      #Read out the file to memory
      data = fs.readFileSync('public/' + filename + '-pos.txt')
      #Split it into pieces for processing
      pos = data.toString().split(/\r\n|\r|\n/g);
      for x in pos
        p = x.split(' ')
        #Inserting it into the database one by one
        SensorPosition.insert({file: filename, name: p[0], x: parseInt(p[1]), y: parseInt(p[2])})
    )()
    


    #SensorData.remove({})
    (->
      return if SensorData.findOne({file: filename})
      data = fs.readFileSync('public/' + filename + '-data.txt')
      events  = data.toString().split(/\r\n|\r|\n/g);
      for event in events
        x = event.split(' ')
        if x[0] == '0'
          SensorData.insert({file: filename, type: 0, time: parseInt(x[1]), event: x[2], status: x[3]})
        else
          SensorData.insert({file: filename, type: 1, time: parseInt(x[1]), sensor: x.splice(2)})
    )()
    
}

