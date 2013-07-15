(function(){ Template.home.rendered = function() {
  return Meteor.call('print', function(err, result) {
    console.log('TEST');
    return console.log(result);
  });
};

}).call(this);
