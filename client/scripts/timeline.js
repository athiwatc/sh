// ## Timeline

Template.timeline.rendered = function() {
	// Read the file
	d3.csv('timeline.csv', function(colors) {

		console.log(colors);
		// Settings
		var data = colors;
		var gap = 1;
		var width = 12;
		var height = 12;
		var interval = 60;
		var svg_id = '#test';
		var shape = 'rect';

		// Implementation
		// Select the svg
		var svg = d3.select(svg_id);
		// Select none existing elements
		var circles = svg.selectAll(shape).data(data);
		// Append the shape
		var enter = circles.enter().append(shape);
		// Generate colors
		var colors = d3.scale.category20();
		// Set the position
		enter.attr("y", function (d, i) {
		    return Math.floor(i / interval) * (height + gap);
		});
		enter.attr("x", function (d, i) {
		    return (i % interval) * (width + gap);
		});
		// Set the width and height
		enter.attr('width', width);
		enter.attr('height', height);
		// Fill in the colors
		enter.attr('fill', function (d, i) {
		    return colors(d.color);
		});
		// Event listener for displaying addition information
		enter.on('mouseover', function (d, i) {
		    $('#info').html('At time: ' + i % interval + ' Activity: ' + d.name);
		});
	});
};