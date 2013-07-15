Meteor.Router.add
  "/": "home"
  "/visualize": -> "visualize"
  "/coor": -> "coor"

  "*": "not_found"
