(function(){ /* global Template:false */
/* global d3:false */
/* global $:false */

// ## Timeline
Template.timeline.rendered = function() {
    'use strict';
    var render_file = Session.get("rendered-filename");
    var render_pos = Session.get("rendered-posfile");
    if(render_file != null && render_pos != null) {
        var path =  '/data/timeline/datafile=' + render_file + '&&posfile=' + render_pos;
        // Read the file
        d3.csv(path, function(datas) {
            var data_info_color = [];
            var data_info_txt = [];
            for (var i = datas.length - 1; i >= 0; i--) {
                // Getting unique data with unique color
                var isIn = false;
                for(var j = 0; j < data_info_color.length; j++){
                    if(data_info_color[j] == datas[i].color){
                        isIn = true;
                        break;
                    }
                }
                if(isIn == false){
                    data_info_color.push(datas[i].color);
                    data_info_txt.push(datas[i].name);
                }
            }

            // Generate colors
            var colors = d3.scale.category20();

        
            // Settings
            var data = datas;
            var gap = 1;
            var width = 15;
            var height = 15;
            var interval = 60;
            var svg_id = '#timeline-canvas';
            var shape = 'rect';
            var svg_datainfo = d3.select("#data-info").attr('height', height * 2 * data_info_color.length);

                        // Implementation
            // Select the svg
            var svg = d3.select(svg_id);
            // Select none existing elements
            var circles = svg.selectAll(shape).data(data);
            // Append the shape
            var enter = circles.enter().append(shape);
            
            // Set the position
            enter.attr('y', function (d, i) {
                return Math.floor(i / interval) * (height + gap);
            });
            enter.attr('x', function (d, i) {
                return (i % interval) * (width + gap);
            });
            // Set the width and height
            enter.attr('width', width);
            enter.attr('height', height);
            // Fill in the colors
            enter.attr('fill', function (d) {
                return colors(d.color);
            });

            // Show mapping of each unique data
            var x_pos = 0
            var y_pos = 0
            for (var i = 0;i < data_info_color.length;i++){
                //var color = d3.scale.category20();
                var chosen_color = parseInt(data_info_color[i]);
                //console.log(chosen_color);
                svg_datainfo.append('rect').attr('x', x_pos).attr('y', y_pos).attr('width',width).attr('height',height).attr('fill', function(d, i) {
                    return colors(chosen_color);
                });
                svg_datainfo.append('foreignObject').attr('x', x_pos + (width * 2)).attr('y', y_pos).attr('width',width + 150).attr('height',height).append('xhtml').html('<div>' + data_info_txt[i] + '</div>');
                y_pos += height * 2;
            }


            // Event listener for displaying addition information
            enter.on('mouseover', function (d, i) {
                $('#info').html('At time: ' + moment(parseInt(d.time)).format('LLLL') + '</br>Activity: ' + d.name);
            });
        });
    }
};
}).call(this);
