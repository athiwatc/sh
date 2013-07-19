(function(){ /* global Template:false */
/* global d3:false */
/* global $:false */

// ## Render Pie Chart
Template.piechart.rendered = function() {
    'use strict';

    // Load up file
    d3.csv('piechart.txt', function(pie_data) {
        // Set the width and height of pie chart
        var width = 960,
        height = 500,
        radius = Math.min(width, height) / 2 - 10;
        // Generate Color
        var color = d3.scale.category20();
        // Compute data to represent it in text associated with unique color
        for (var i = pie_data.length - 1; i >= 0; i--) {
            $('#name').append('<font color="' + color(i) + '">' + pie_data[i].name + '</font>: ' + pie_data[i].data + '<br>');
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
            b.innerRadius = radius * 0.6;
            var i = d3.interpolate({
                innerRadius: 0
            }, b);
            return function(t) {
                return arc(i(t));
            };
        }
    });
};
}).call(this);
