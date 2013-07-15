Meteor.Router.add({
    '/': 'home',
    '/:go': function(go) {
        return go;
    },
    "/visualize": function() {
        return "visualize";
    },
    "/coor": function() {
        return "coor";
    },
    "*": "not_found"
});