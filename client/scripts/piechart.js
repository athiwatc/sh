/* global Template:false */
/* global d3:false */
/* global $:false */

// ## Render Pie Chart
Template.piechart.rendered = function() {
    'use strict';
    var render_file = Session.get("rendered-filename");
    var render_pos = Session.get("rendered-posfile");
    if(render_file != null && render_pos != null) {
        var path = '/data/piechart/datafile=' + render_file + '&&posfile=' + render_pos;
        Meteor.call('getTimePeriod',render_file,render_pos, function(err,result){
            var begin = moment(parseInt(result.begin)).format('LLLL');
            var end = moment(parseInt(result.end)).format('LLLL');
            $('#time-section > h3').html('Begin: ' + begin + '</br> End: ' + end);
        });

        // Load up file
        d3.csv(path, function(pie_data) {
            // Set the width and height of pie chart
            var width = 960,
            height = 500,
            radius = Math.min(width, height) / 2 - 10;
            // Generate Color
            var color = d3.scale.category20();
            // Compute data to represent it in text associated with unique color
            for (var i = pie_data.length - 1; i >= 0; i--) {
                $('#name').append('<div style="width:15px;height:15px;background-color:'+color(i)+';float: left;overflow:hidden;"></div>' +' '+ pie_data[i].name + ': ' + pie_data[i].data + ' times<br><br>');
            }
            // Add data to pie chart
            var arc = d3.svg.arc().outerRadius(radius);
            var data = [];
            for (i = 0; i < pie_data.length; i++) {
                data.push(pie_data[i].data);
            }
            // Create layout and d3 object
            var pie = d3.layout.pie();
            var svg = d3.select('#piechart').append('svg').datum(data).attr('width', width).attr('height', height).append('g').attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');
            var arcs = svg.selectAll('g.arc').data(pie).enter().append('g').attr('class', 'arc');
            // Fill color and make it be dynamic
            arcs.append('path').attr('fill', function(d, i) {
                return color(i);
            }).transition().ease('bounce').duration(2000).attrTween('d', tweenPie).transition().ease('elastic').delay(function(d, i) {
                return 2000 + i * 50;
            }).duration(750).attrTween('d', tweenDonut);
            // Dynamic function for tween pie
            function tweenPie(b) {
                b.innerRadius = 0;
                var i = d3.interpolate({
                    startAngle: 0,
                    endAngle: 0
                }, b);
                return function(t) {
                    return arc(i(t));
                };
            }
            // Dynamic function for tween donut
            function tweenDonut(b) {
                // Set the inner radius
                b.innerRadius = radius * 0.6;
                var i = d3.interpolate({
                    innerRadius: 0
                }, b);
                return function(t) {
                    return arc(i(t));
                };
            }
        });
    }
};