/* global Template:false */
/* global d3:false */

// ## Chord Diagram
// # Credit: http://bost.ocks.org/mike/uberdata/

Template.chorddiagram.rendered = function() {
    'use strict';
    var render_file = Session.get("rendered-filename");
    var render_pos = Session.get("rendered-posfile");
    if(render_file != null && render_pos != null) {
        Meteor.call('getTimePeriod',render_file,render_pos, function(err,result){
            var begin = moment(parseInt(result.begin)).format('LLLL');
            var end = moment(parseInt(result.end)).format('LLLL');
            $('#time-section > h3').html('Begin: ' + begin + '</br> End: ' + end);
        });
        var data_path = '/data/chorddiagram/info/datafile=' + render_file + '&&posfile=' + render_pos;
        var matrix_path = '/data/chorddiagram/matrix/datafile=' + render_file + '&&posfile=' + render_pos;
        // Set the width and height of the diagram. Along with other factor
        var width = 720,
        height = 720,
        outerRadius = Math.min(width, height) / 2 - 10,
        innerRadius = outerRadius - 24;
        // NOT USED: Format the persentage to 1 place.
        //var formatPercent = d3.format('.1%');
        // Create the layout and d3 objects
        var arc = d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius);
        var layout = d3.layout.chord().padding(0.04).sortSubgroups(d3.descending).sortChords(d3.ascending);
        var path = d3.svg.chord().radius(innerRadius);
        var svg = d3.select('#chorddiagram').append('svg').attr('width', width).attr('height', height).append('g').attr('id', 'circle').attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');
        // Add the first circle if it doesn't exists, else change the properties.
        svg.append('circle').attr('r', outerRadius);
        // Generate Color
        var colors = d3.scale.category20();
        // Load up two files.
        d3.csv(data_path, function(v_data) {
            d3.json(matrix_path, function(matrix) {
                // Compute the chord layout.
                layout.matrix(matrix);
                // Add a group per neighborhood.
                var group = svg.selectAll('.group').data(layout.groups).enter().append('g').attr('class', 'group').on('mouseover', mouseover);
                // Add a mouseover title.
                group.append('title').text(function(d, i) {
                    return v_data[i].name; //+ ': ' + d.value + ' of origins';
                });
                // Add the group arc.
                var groupPath = group.append('path').attr('id', function(d, i) {
                    return 'group' + i;
                }).attr('d', arc).style('fill', function(d, i) {
                    return colors(v_data[i].color);
                });
                // Add a text label.
                var groupText = group.append('text').attr('x', 6).attr('dy', 15);
                groupText.append('textPath').attr('xlink:href', function(d, i) {
                    return '#group' + i;
                }).text(function(d, i) {
                    return v_data[i].name;
                });
                // Remove the labels that don't fit. :(
                    groupText.filter(function(d, i) {
                        return groupPath[0][i].getTotalLength() / 2 - 16 < this.getComputedTextLength();
                    }).remove();
                // Add the chords.
                var chord = svg.selectAll('.chord').data(layout.chords).enter().append('path').attr('class', 'chord').style('fill', function(d) {
                    return colors(v_data[d.source.index].color);
                }).attr('d', path);
                // Add an elaborate mouseover title for each chord.
                chord.append('title').text(function(d) {
                    return v_data[d.source.index].name + ' → ' + v_data[d.target.index].name + ': ' + d.source.value + ' times\n' + v_data[d.target.index].name + ' → ' + v_data[d.source.index].name + ': ' + d.target.value + ' times';
                });

                // This is the function that tracks the user mouse.
                function mouseover(d, i) {
                    chord.classed('fade', function(p) {
                        return p.source.index != i && p.target.index != i;
                    });
                }
            });
        });
    }
};