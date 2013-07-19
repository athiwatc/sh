this.fs = Npm.require('fs')

# ## Sensor Dictionary Class

# Overview

# Storage sensor information from text file, which is contained
# sensor name and sensor position x and y correlate to visual map
class SensorDictionary

	# Build SensorDictionary object 
	constructor: (path)->
		@_dict = [] 
		@_init(path)

	_init: (path)->
		# Read file from specific path, actually path is a file name because
		# all read file must be in ./public/
		data = fs.readFileSync('./public/' + path, 'utf8')
		lines = data.toString().split('\r\n')
		for l in lines
			if l[0] != '#'
				tmp = l.split(' ')
				# Format dict['sensor name'] = {x: "x position", y: "y position"}
				@_dict[tmp[0]] = {x: tmp[1], y: tmp[2]}


	# Check a key that is in this dictionary or not
	containsKey: (key)->
		return @_dict[key] != undefined
	
	# Get x position of key
	getXPOS: (key)->
		if @containsKey(key)
			return @_dict[key].x;
		return undefined

	# Get y position of key
	getYPOS: (key)->
		if @containsKey(key)
			return @_dict[key].y;
		return undefined

# ## Convertor Class

# Overview

# To convert data
# From format: 
# Date Time Sensor_Name Status
# or
# Date Time Activity_Name Status
#
# 2008-02-27	12:45:14.498824	M13	OFF
# 2008-02-27	12:49:15 asterisk END
# To:
# 1 Unixtime xPos yPos sensor_name sensor_status
# 0 Unixtime event_name event_status
#
# 1 1204112862 683 123 M13 OFF
# 0 1204116555 asterisk START 
# Line of data that is a sensor activation, its converted format data would put prefix '1' in the front
# List of data that is a activity, convert, its converted format data would put prefix '0' in the front
class Convertor

	
	# Initial path file to convert and sensor dictionary
	constructor: (@_path, @_sensor_dict)->
		@_data = []		
		@_preProcessingData()
	
	# Get list of converted data
	getData: ()->
		result = []
		for s in @_data
			result.push(s)
		return result

	# Preprocessing data by read and convert data
	_preProcessingData: ()->
		tmp_data = fs.readFileSync('./public/' + @_path, 'utf8')
		lines = tmp_data.toString().split('\n')
		for l in lines
			@_data.push(l)
		@_convertData()
	
	
	# Convert data using in preprocessing
	_convertData: ()->
		output = []
		for line in @_data
			temp = line.split(/[\s]/)
			is_zero = true
			for s in temp
				# To check each line of data is a sensor data
				# or an activity data
				if @_sensor_dict.containsKey(s)
					# If it is a sensor data, it will transform data
					# with prefix 1
					result = @_processArrayForPrefixOne(temp)
					output.push(@_parseString(result))
					is_zero = false
					# For some data that has both sensor and activity data
					if temp.length > 4
						addition = [temp[0],temp[1],temp[4],temp[5]]
						result = @_processArrayForPrefixZero(addition)
						output.push(@_parseString(result))
					break
			# If it is an activity data, it will transform data
			# with prefix 0
			if is_zero && temp.length > 2
				result = @_processArrayForPrefixZero(temp)
				output.push(@_parseString(result))
		@_data = output

	# Convert data array to one string. Use for computing
	# represented it to simple string
	_parseString: (arr)->
		s = ''
		for a in arr
			s += ' ' + a
		return s
	
	# Convert data array of activity
	_processArrayForPrefixZero: (arr)->
		result = []
		result[0] = "0"
		result[1] = @_convertStringDateToUnix(arr[0],arr[1]) + ""
		result[2] = arr[arr.length - 2]
		result[3] = arr[arr.length - 1]
		return result
	
	# Convert data array of sensor activation
	_processArrayForPrefixOne: (arr)->
		result = []
		result[0] = "1"
		#date to unix
		result[1] = @_convertStringDateToUnix(arr[0],arr[1]) + ""
		result[2] = @_sensor_dict.getXPOS(arr[2]) + ""
		result[3] = @_sensor_dict.getYPOS(arr[2]) + ""
		result[4] = arr[2]
		result[5] = arr[3]
		return result
	
	# Convert date and time to Unixtime
	_convertStringDateToUnix: (ymd, time)->
		t = time
		s = ymd + "," + t
		result = moment(s, "YYYY-MM-DD,HH:mm:ss")
		return result

# ## Convertor Timeline Format Class

# Overview

# Use to convert data to timeline format (Standard format for this application)
# From format: (Converted data format from Convertor Class)
# 1 1204112607 568 231 M08 ON 
# 1 1204112607 503 197 M07 ON 
# 1 1204112608 592 197 M09 ON 
# 1 1204112609 683 197 M14 ON 
# 1 1204112609 484 291 M23 OFF 
# 1 1204112610 484 261 M01 OFF 
# 1 1204112610 503 197 M07 OFF 
# 1 1204112611 683 123 M13 ON 
# 1 1204112611 568 231 M08 OFF 
# 1 1204112612 592 197 M09 OFF 
# 1 1204112613 683 197 M14 OFF
# 0 1204112620 Phone_call begin
# To:
# Prefix Unixtime [Active Sensors or Activity] [Activity status if it is activity]
# 1 1204112607 M07 M08 
# 1 1204112608 M07 M08 M09 
# 1 1204112609 M07 M08 M09 M14 
# 1 1204112610 M08 M09 M14
# 0 1204112620 Phone_call begin
class ConvertorTimelineFormat extends Convertor
	
	# Override to super class (Convertor Class)
	_preProcessingData: () ->
		# Call _preProcessingData from Super class
		super
		# Array of sensor status for checking data in convert process
		@_check_on = ["ON", "OPEN", "PRESENT"]
		@_check_off = ["OFF", "CLOSE", "ABSENT"]
		@_convertToTimeline()

	# Convert to timeline data
	_convertToTimeline: ()->
		# Init empty Set of sensor, which status is on
		on_sensor = new Set()
		result = []
		time = -1
		i = 0
		while i < @_data.length
			tmp = @_data[i].trim().split(/[\s]/)
			prefix = parseInt(tmp[0])
			element = ""
			# Activity data is unnecessary to convert
			if prefix == 0
				result.push(@_data[i].trim())
			# Sensor data needs to convert
			else if prefix == 1
				time = parseInt(tmp[1])
				sensor_name = tmp[4]
				sensor_status = tmp[5]
				# Add sensor that status is on to Set
				if @_isIn(sensor_status, @_check_on)
					on_sensor.add(sensor_name)
				# Remove sensor that status is off from Set
				else if @_isIn(sensor_status, @_check_off)
					on_sensor.remove(sensor_name)
				# Build a string, which is time correlate with Set of on status sensor
				element = @_buildStringPrefixOne(time, on_sensor.toList())
				if i == @_data.length - 1
					result.push(element)
				else
				# A method to check a same sensor changes status at same time or not
				# to check this, it must use the next line of data and current line of data
					next_data = @_data[i + 1].trim().split(/[\s]/)
					next_data_prefix = parseInt(next_data[0])
					next_data_time = parseInt(next_data[1])
					if next_data_prefix == 0 || next_data_time != time || @_isSameSensorChangeAtTheSameTime(@_data[i].trim(),@_data[i + 1].trim())
						result.push(element)
			i += 1
		@_data = result
	
	# Checking element in array
	_isIn: (s1, set)->
		for i in set
			if i.toLowerCase() == s1.toLowerCase()
				return true
		return false

	# Convert data array to one string for sensor activation
	_buildStringPrefixOne: (time, set)->
		output = " " + "1 " + time
		for s in set
			output += " " + s
		return output.trim()
	
	# To check a sensor is changed status at the same time or not
	_isSameSensorChangeAtTheSameTime: (s1, s2)->
		# s1 is a first data, s2 is a second data in next line of data
		first = s1.split(/[\s]/)
		second = s2.split(/[\s]/)
		# To check is a same time or not
		if parseInt(first[1]) != parseInt(second[1])
			return false
		# To check is a same sensor or not
		else if !first[4] == second[4]
			return false
		# To check sensor status is change in the same time or not
		else if @_isIn(first[5], @_check_on) || @_isIn(first[5], @_check_off)
			return !first[5].toLowerCase() == second[5].toLowerCase()
		return false
	
# ## Set Class

# Overview

# Data structure that is storage any type of element
# it is a collection that contains no duplicate elements
class Set

	# Initial list to storage data
	constructor: ()->
		@_storage = []

	# Add new element to Set, but it always check that
	# new element duplicates to element in Set or not;
	# it uses to prevent duplicated data in Set
	add: (element)->
		isThere = false
		for e in @_storage
			if e == element
				isThere = true
				break
		if !isThere
			@_storage.push(element)

	# Remove specific element from Set
	remove: (element)->
		arr = []
		for e in @_storage
			if e != element
				arr.push(e)
		@_storage = arr

	# Return list of element
	toList: ()->
		result = []
		for i in @_storage
			result.push(i)
		return result

	# Get current Set length
	size: ()->
		return @_storage.length

# ## Map Class

# Overview

# Data structure that is storage pairing data (key,value)
# An object that maps keys to values. 
# A map cannot contain duplicate keys; each key can map to at most one value.
class Map

	# Initial keys and values list
	constructor: ()->
		@_keys = []
		@_values = []

	# To check it has this key or not
	containsKey: (key)->
		if @_keys.indexOf(key) == -1
			return false
		return true

	# Associated specified value with the specified key in this map
	# if it has a key previously, the associated value to the key will
	# be replaced by new one.
	put: (key, value)->
		index = @_keys.indexOf(key)
		if index == -1
			@_keys.push(key)
			@_values.push(value)
		else
			@_values[index] = value

	# Return length of this Map
	size: ()->
		return @_keys.length

	# Get value with specific key
	get: (key)->
		index = @_keys.indexOf(key)
		return @_values[index]

	# Return data to object list with element format as follow
	# {key: '', value: ''}
	toObjectList: ()->
		result = []
		i = 0
		while i < @_keys.length
			result.push({key: @_keys[i], value: @_values[i]})
			i += 1
		return result

	# Remove key from Map, including associated value
	remove: (key)->
		except_index = @_keys.indexOf(key)
		i = 0
		new_keys = []
		new_values = []
		while i < @_keys.length
			if i != except_index
				new_keys.push(@_keys[i])
				new_values.push(@_values[i])
			i += 1
		@_keys = new_keys
		@_values = new_values

# ## Data Processor Class

# Overview

# Use to derive specific data from the input data.
# It gets data that will use in parsing visualization section 
class DataProcessor

	# Initial input data
	constructor: (@_data)->

	# Get current input data
	getData: ()->
		result = []
		for s in @_data
			result.push(s)
		return result

	# Set new input data
	setData: (data)->
		@_data = data

	# Get all activities and number of times from input data
	# format {key: activity, value: number of times} in returned object list
	getAllActivities: ()->
		storage = new Map()
		for d in @_data
			tmp = d.trim().split(/[\s]/)
			prefix = parseInt(tmp[0])
			# All activity data have prefix 0
			# and count occuring times by count 'end' of activity
			if prefix == 0 && tmp[3].toLowerCase() != 'end'
				activity = tmp[2]
				if !storage.containsKey(activity)
					storage.put(activity, 1)
				else
					count = storage.get(activity)
					storage.put(activity, count + 1)
		return storage.toObjectList()

	# Get all sequence activities pair
	# finding main activity and then finding all what activity is possible happened next to main activity
	# it's called 'next_activity'
	# format {key: main_activity, value: Map(next_activity, number of times) } in returned object list
	getAllActivitiesInSequencePair: ()->
		# This method is based on finite-state machine to compute
		storage = new Map()
		# State to find first event (main activity)
		state_find_first = 1
		# State to find second event (next activity)
		state_find_second = 2
		# State that nothing happened
		state_none = -1
		# State variable
		state = state_none
		# Main activity
		first_activity = ''
		# Next activity
		second_activity = ''
		for d in @_data
			tmp = d.trim().split(/[\s]/)
			prefix = parseInt(tmp[0])
			if prefix == 0
				switch state
					# In state_none is used to find main activity happened
					# and then it will change state to state_find_first
					when state_none
						if tmp[3].toLowerCase() == 'begin'
							first_activity = tmp[2]
							state = state_find_first
					# In state_find_first is used to find end of main activity
					# and then it will change state to state_find_second
					when state_find_first
						if first_activity == tmp[2] && tmp[3].toLowerCase() == 'end'
							state = state_find_second
					# In state_find_second is used to find next activity
					# and then it will change state to state_find_first
					when state_find_second
						if tmp[3].toLowerCase() == 'begin'
							second_activity = tmp[2]
							second_map = ''
							# Use map to collect next activity and
							# number of times that happened
							if !storage.containsKey(first_activity)
								second_map = new Map()
								second_map.put(second_activity, 1)
							else
								second_map = storage.get(first_activity)
								if !second_map.containsKey(second_activity)
									second_map.put(second_activity, 1)
								else
									second_map.put(second_activity, second_map.get(second_activity) + 1)
							if !storage.containsKey(second_activity)
								storage.put(second_activity, new Map())
							storage.put(first_activity, second_map)
							# The next activity is changed to main activity
							# to find its next activity
							first_activity = second_activity
							state = state_find_first
		return storage.toObjectList()

	# Get all activities with unixtime format (Each line of data unixtime is different 1 minute).
	# Returned object list is contained activity that happened in each minutes
	# format {name: activity name, color: unique color associated with activity, time: unixtime that activity happened} in returned object list
	getAllActivitiesInUnixTime: ()->
		# This method is based on finite-state machine to compute
		activity_color_map = new Map()
		time_stack = []
		# State that nothing happened
		state_none = -1
		# State to inform that activity is happening
		state_on_activity = 0
		# state variable
		state = state_none
		activity_name = ''
		activity_color = ''
		activity_time = 0
		current_time = 0
		color_id = 2
		for d in @_data
			tmp = d.trim().split(/[\s]/)
			prefix = parseInt(tmp[0])
			if prefix == 0
				# In state_none is used to find activity
				# and then it will change state to state_on_activity
				switch state
					when state_none
						if tmp[3].toLowerCase() == 'begin'
							state = state_on_activity
							activity_name = tmp[2]
							# Defined unique color code
							if !activity_color_map.containsKey(activity_name)
								activity_color_map.put(activity_name, color_id)
								color_id += 1
							activity_color = activity_color_map.get(activity_name)
							# Parse unixtime by floor original unixtime in HH:mm:ss to HH:mm
							# Activity_time is a time that activity happened
							activity_time = @_cutOffSecondFromUnixTime(parseInt(tmp[1]))
						# If nothing happened, it push 'none' event to stack
						else
							time_stack.push({name: 'none',color: 1, time: activity_time})
					# In state_on_activity is used to find the end of activity
					# and generate data in every minute push them to stack
					# and then it will change state to state_none
					when state_on_activity
						if tmp[3].toLowerCase() == 'end' && tmp[2] == activity_name
							# Time of the end activity
							current_time = @_cutOffSecondFromUnixTime(parseInt(tmp[1]))
							if current_time - activity_time >= 60
								# Push time in every minute per event
								while activity_time <= current_time
									time_stack.push({name: activity_name, color: activity_color, time: activity_time})
									activity_time += 60
							else
								time_stack.push({name: activity_name, color: activity_color, time: activity_time})
							# Reset activity and state
							activity_name = ''
							activity_color = 0
							activity_time = 0
							state = state_none
		return time_stack

	# To floor unixtime by cut off second from unixtime
	# HH:mm:ss to HH:mm
	_cutOffSecondFromUnixTime: (unixtime)->
		raw = moment(unixtime)
		cut_off_second = raw.format("YYYY-MM-DD,HH:mm")
		convert_to_unix = moment(cut_off_second, "YYYY-MM-DD,HH:mm")
		return convert_to_unix.unix()

# ## Visualization Parser Class

# Overview

# Use to parse data to visualization
# it will parse any data and save to specific file, and when
# it was changed, visualizations on web application are also changed
# in real-time
class VisualizationParser
	constructor: ()->

	# Data must be list of {key: activity, value: number of times}
	parsePieChart: (data)->
		# Specific file that associates with pie chart visualization
		path = 'piechart.txt'
		text = 'name,data'
		for obj in data
			text += '\r\n' + obj.key + ',' + obj.value
		fs.writeFileSync('./public/' + path, text)


	# Data must be list of {key: main_activity, value: Map(next_activity, number of times) }
	parseChordDiagram: (data)->
		# Specific file that associates with chord diagram visualization
		# for major data (name,color)
		path_data = 'chorddiagram.csv'
		# Specific file that associates with chord diagram visualization
		# for minor data (matrix of visualizing size of each data)
		path_matrix = 'matrix.json'
		data_text = 'name,color'
		data_matrix = []
		matrix_map = new Map()
		unique_index = 0
		color_code = 1
		for obj in data
			# Color is associated with data
			data_text += '\r\n' + obj.key + ',' + color_code
			# For making matrix
			matrix_map.put(obj.key, unique_index)
			data_matrix.push([])
			unique_index += 1
			color_code += 1
		# Generate matrix
		i = 0
		while i < unique_index
			j = 0
			while j < unique_index
				data_matrix[i].push(0)
				j += 1
			i += 1
		
		# Determine value in matrix
		for obj in data
			val_list = obj.value.toObjectList()
			for d in val_list
				index_val = matrix_map.get(d.key)
				index_key = matrix_map.get(obj.key)
				data_matrix[index_key][index_val] = d.value
		fs.writeFileSync('./public/' + path_data, data_text)
		fs.writeFileSync('./public/' + path_matrix, JSON.stringify(data_matrix))
	
	# Data must be list of {name: activity name, color: unique color associated with activity, time: unixtime that activity happened}
	parseTimeLineMatrix: (data)->
		# Specific file that associates with timeline visualization
		path = 'timeline.csv'
		text = 'name,color,time'
		for obj in data
			text += '\r\n' + obj.name + ',' + obj.color + ',' + obj.time
		fs.writeFileSync('./public/' + path, text)

Meteor.methods({
	print: ()->
		#sd = new SensorDictionary("all-pos.txt")
		#c = new ConvertorTimelineFormat('raw-data-sh.txt',sd)
		#processor = new DataProcessor(c.getData())
		# data_dia = processor.getAllActivitiesInSequencePair()
		#vp = new VisualizationParser()
		# x = vp.parseChordDiagram(data_dia)
		#data_timeline = processor.getAllActivitiesInUnixTime()
		#vp.parseTimeLineMatrix(data_timeline)
		#return data_timeline

	getAllUploadedFilesName: ()->
		return fs.readdirSync('./public/uploaded-files~')

	deleteFile: (name)->
		fs.unlinkSync('./public/uploaded-files~/' + name)
		return true

	uploadFile: ()->
		
})

