/* global Meteor:false */

// ##Router

// Add the router path
Meteor.Router.add({

  // Home root path, display the home page.
  '/': 'home',
    // Else just go to the path with the same template names.
    '/:go': function(go) {
      'use strict';
      return go;
    },
    // Other directory will be given a not found status.
    '*': 'not_found'
  });