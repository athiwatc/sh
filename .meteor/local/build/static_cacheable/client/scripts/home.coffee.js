(function(){ Template.home.rendered = function() {
  return Meteor.call('print', function(err, result) {
    console.log('TEST X');
    return console.log(result);
  });
};

}).call(this);
