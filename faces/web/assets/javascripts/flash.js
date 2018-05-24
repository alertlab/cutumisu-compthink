/**
 * = require ./network
 */

// flashes
(function (window, undefined) {
   var DISPLAY_DURATION = 5 * 1000; // in ms.

   window.notices = ko.observableArray().extend({
      temporaryValue: DISPLAY_DURATION,
      cookie: {
         key: 'compthink.flash_notices',
         duration: DISPLAY_DURATION - 1
      }
   });
   window.warnings = ko.observableArray().extend({
      temporaryValue: DISPLAY_DURATION,
      cookie: {
         key: 'compthink.flash_warnings',
         duration: DISPLAY_DURATION - 1
      }
   });
   window.errors = ko.observableArray().extend({
      temporaryValue: DISPLAY_DURATION,
      cookie: {
         key: 'compthink.flash_errors',
         duration: DISPLAY_DURATION - 1
      }
   });

   // Top level should be killed after delay
   window.flash = function (listName, msgs) {
      var list;

      if (!msgs)
         return;

      if (!(msgs instanceof Array))
         msgs = [msgs];

      if (listName.match(/notices?|messages?/))
         list = window.notices;
      else if (listName.match(/warnings?/)) {
         list = window.warnings;
         msgs.forEach(function (msg) {
            console.warn(msg);
         })
      } else if (listName.match(/errors?/)) {
         list = window.errors;
         msgs.forEach(function (msg) {
            console.error(msg);
         })
      } else {
         throw 'Unknown flash notification list name: ' + listName;
      }

      msgs.forEach(function (msg) {
         list.unshift(msg);
      });
   }
}(window));