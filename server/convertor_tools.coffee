this.fs = Npm.require('fs')

class SensorDictionary
	constructor: (path)->
		@_dict = [] #format {key:"xx", x: "00",y: "23"}
		@_init(path)

	_init: (path)->
		data = fs.readFileSync('./public/' + path, 'utf8')
		lines = data.toString().split('\r\n')
		for l in lines
			if l[0] != '#'
				tmp = l.split(' ')
				@_dict[tmp[0]] = {x: tmp[1], y: tmp[2]}



	containsKey: (key)->
		return @_dict[key] != undefined
	
	getXPOS: (key)->
		if @containsKey(key)
			return @_dict[key].x;
		return undefined

	getYPOS: (key)->
		if @containsKey(key)
			return @_dict[key].y;
		return undefined

class Convertor

	constructor: (@_path, @_sensor_dict)->
		@_data = []		
		@_preProcessingData()
	
	getData: ()->
		result = []
		for s in @_data
			result.push(s)
		return result

	_preProcessingData: ()->
		tmp_data = fs.readFileSync('./public/' + @_path, 'utf8')
		lines = tmp_data.toString().split('\n')
		for l in lines
			@_data.push(l)
		@_cleanData()
	
	
	#Determine 0,1 to be prefix on data
	_cleanData: ()->
		output = []
		for line in @_data
			#clear indent and space
			#buffer = line.replace("(\s+)", " ")
			temp = line.split(/[\s]/)
			is_zero = true
			for s in temp
				if @_sensor_dict.containsKey(s)
					result = @_processArrayForPrefixOne(temp)
					output.push(@_parseString(result))
					is_zero = false
					if temp.length > 4
						addition = [temp[0],temp[1],temp[4],temp[5]]
						result = @_processArrayForPrefixZero(addition)
						output.push(@_parseString(result))
					break
			if is_zero && temp.length > 2
				result = @_processArrayForPrefixZero(temp)
				output.push(@_parseString(result))
		@_data = output


	_parseString: (arr)->
		s = ''
		for a in arr
			s += ' ' + a
		return s
	
	_processArrayForPrefixZero: (arr)->
		result = []
		result[0] = "0"
		result[1] = @convertStringDateToUnix(arr[0],arr[1]) + ""
		result[2] = arr[arr.length - 2]
		result[3] = arr[arr.length - 1]
		return result
	
	_processArrayForPrefixOne: (arr)->
		result = []
		result[0] = "1"
		#date to unix
		result[1] = @convertStringDateToUnix(arr[0],arr[1]) + ""
		result[2] = @_sensor_dict.getXPOS(arr[2]) + ""
		result[3] = @_sensor_dict.getYPOS(arr[2]) + ""
		result[4] = arr[2]
		result[5] = arr[3]
		return result
	
	convertStringDateToUnix: (ymd, time)->
		t = time
		s = ymd + "," + t
		result = moment(s, "YYYY-MM-DD,HH:mm:ss")
		return result


class ConvertorTimelineFormat extends Convertor
	
	_preProcessingData: () ->
		super
		@_check_on = ["ON", "OPEN", "PRESENT"]
		@_check_off = ["OFF", "CLOSE", "ABSENT"]
		@_convertToTimeline()

	
	_convertToTimeline: ()->
		on_sensor = new Set()
		result = []
		time = -1
		i = 0
		while i < @_data.length
			tmp = @_data[i].trim().split(/[\s]/)
			prefix = parseInt(tmp[0])
			element = ""
			if prefix == 0
				result.push(@_data[i].trim())
			else if prefix == 1
				time = parseInt(tmp[1])
				sensor_name = tmp[4]
				sensor_status = tmp[5]
				if @_isIn(sensor_status, @_check_on)
					on_sensor.add(sensor_name)
				else if @_isIn(sensor_status, @_check_off)
					on_sensor.remove(sensor_name)
				element = @_buildStringPrefixOne(time, on_sensor.toList())
				if i == @_data.length - 1
					result.push(element)
				else
					next_data = @_data[i + 1].trim().split(/[\s]/)
					next_data_prefix = parseInt(next_data[0])
					next_data_time = parseInt(next_data[1])
					if next_data_prefix == 0 || next_data_time != time || @_isSameSensorChangeAtTheSameTime(@_data[i].trim(),@_data[i + 1].trim())
						result.push(element)
			i += 1
		@_data = result
	
	_isIn: (s1, set)->
		for i in set
			if i.toLowerCase() == s1.toLowerCase()
				return true
		return false

	_buildStringPrefixOne: (time, set)->
		output = " " + "1 " + time
		for s in set
			output += " " + s
		return output.trim()
	
	_isSameSensorChangeAtTheSameTime: (s1, s2)->
		first = s1.split(/[\s]/)
		second = s2.split(/[\s]/)
		if parseInt(first[1]) != parseInt(second[1])
			return false
		else if !first[4].toLowerCase() == second[4].toLowerCase()
			return false
		else if @_isIn(first[5], @_check_on) || @_isIn(first[5], @_check_off)
			return !first[5].toLowerCase() == second[5].toLowerCase()
		return false
	

class Set
	constructor: ()->
		@_storage = []

	add: (element)->
		isThere = false
		for e in @_storage
			if e == element
				isThere = true
				break
		if !isThere
			@_storage.push(element)

	remove: (element)->
		arr = []
		for e in @_storage
			if e != element
				arr.push(e)
		@_storage = arr

	toList: ()->
		result = []
		for i in @_storage
			result.push(i)
		return result

	size: ()->
		return @_storage.length


class Map
	constructor: ()->
		@_keys = []
		@_values = []

	containsKey: (key)->
		if @_keys.indexOf(key) == -1
			return false
		return true

	put: (key, value)->
		index = @_keys.indexOf(key)
		if index == -1
			@_keys.push(key)
			@_values.push(value)
		else
			@_values[index] = value

	size: ()->
		return @_keys.length

	get: (key)->
		index = @_keys.indexOf(key)
		return @_values[index]

	toObjectList: ()->
		result = []
		i = 0
		while i < @_keys.length
			result.push({key: @_keys[i], value: @_values[i]})
			i += 1
		return result

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

class DataFilter
	constructor: (@_data)->

	getData: ()->
		result = []
		for s in @_data
			result.push(s)
		return result

	setData: (data)->
		@_data = data

	#get all activities and number of times
	#format {activity: 'xxx', count: '000'}
	getAllActivities: ()->
		storage = new Map()
		for d in @_data
			tmp = d.trim().split(/[\s]/)
			prefix = parseInt(tmp[0])
			if prefix == 0 && tmp[3].toLowerCase() != 'end'
				activity = tmp[2]
				if !storage.containsKey(activity)
					storage.put(activity, 1)
				else
					count = storage.get(activity)
					storage.put(activity, count + 1)
		return storage.toObjectList()

	#get all sequence activities pair
	#format {activity: 'xxx', next_activities: '000'}
	#next_activities that are possible happened next activities 
	getAllActivitiesInSequencePair: ()->
		@_data = ['0 1 Phone_Call begin'
		,'0 1 Asterick begin'
		,'0 1 Asterick end'
		,'0 1 Phone_Call end'
		,'0 1 Eat begin'
		,'1 1 Asterick end'
		,'0 1 Eat end'
		,'1 1 Asterick end'
		,'0 1 Phone_Call begin'
		,'0 1 Phone_Call end'
		,'1 1 Asterick end'
		,'0 1 Cook begin'
		,'0 1 Cook end'
		,'0 1 Eat begin'
		,'1 1 Asterick end'
		,'0 1 Eat end'
		,'1 1 Asterick end'
		,'1 1 Asterick end'
		,'0 1 Phone_Call begin'
		,'1 1 Asterick end'
		,'0 1 Phone_Call end'
		,'0 1 Eat begin'
		,'1 1 Asterick end'
		,'0 1 Eat end'
		,'1 1 Asterick end'
		,'0 1 Sleep begin'
		,'0 1 Sleep end'
		]
		storage = new Map()
		#to find first event
		state_find_first = 1
		#to find second event that happened next to first event
		state_find_second = 2
		state_none = -1
		state = state_none
		first_activity = ''
		second_activity = ''
		for d in @_data
			tmp = d.trim().split(/[\s]/)
			prefix = parseInt(tmp[0])
			if prefix == 0 #&& tmp[3].toLowerCase() != 'end'
				if state == state_none
					if tmp[3].toLowerCase() == 'begin'
						first_activity = tmp[2]
						state = state_find_first
				else if state == state_find_first
					if first_activity == tmp[2] && tmp[3].toLowerCase() == 'end'
						state = state_find_second
				else if state == state_find_second
					if tmp[3].toLowerCase() == 'begin'
						second_activity = tmp[2]
						second_map = ''
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
						first_activity = second_activity
						state = state_find_first
		return storage.toObjectList()



class VisualizeParser
	constructor: ()->

	#data must be list of {key: 'text', value: 'number'}
	parsePieChart: (data)->
		path = 'piechart.txt'
		text = 'name,data'
		for obj in data
			text += '\r\n' + obj.key + ',' + obj.value
		fs.writeFileSync('./public/' + path, text)

###
	#data must be list Map< activity, Map<next_activity,count> >
	parseChordDiagram: (data)->
		path_data = 'chorddiagram.csv'
		path_matrix = 'matrix.json'
		data_text = 'name,color'
		data_matrix = []
		matrix_map = new Map()
		unique_index = 0
		for obj in data
			random_color = '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6)
			#random_color = d3.scale.category20(number 1-20)
			data_text += '\r\n' + obj.key + ',' + random_color

			##for making matrix
			matrix_map.put(obj.key, unique_index)
			data_matrix.push([])
			unique_index += 1
		#gen matrix
		for d in data_matrix
			i = 0
			while i < unique_index
				data_matrix[i].push(0)
		
		#determine val in matrix
		for obj in data
			val_list = obj.value.toObjectList()
			for d in val_list
				index_val = matrix_map.get(d.key)
				index_key = matrix_map.get(obj.key)
				data_matrix[index_key][index_val] = d.value
		fs.writeFileSync('./public/' + path_matrix, JSON.stringify(data_matrix))
		fs.writeFileSync('./public/' + path_data, data_text)
###

Meteor.methods({
	print: ()->
		sd = new SensorDictionary("all-pos.txt")
		c = new ConvertorTimelineFormat('raw-data-sh.txt',sd)
		filter = new DataFilter(c.getData())
		data_dia = filter.getAllActivitiesInSequencePair()
		vp = new VisualizeParser()
		#vp.parseChordDiagram(data_dia)
		return data_dia
})

