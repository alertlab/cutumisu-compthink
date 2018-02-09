/**
 * = require ./network
 */

// flashes
(function (window, undefined) {
   var cookie = eatCookie('flash');

   var preloaded = cookie ? JSON.parse(decodeURIComponent(cookie)) : {};

   window.notices = ko.observableArray();
   window.warnings = ko.observableArray();
   window.errors = ko.observableArray();

   // Top level should be killed after delay
   window.flash = function (listName, msgs) {
      var displayDuration = 5 * 1000; // 5s.
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

      for (var i = 0; i < msgs.length; i++) {
         list.unshift(msgs[i]);

         // TODO:  might be able to use CSS instead of timeout?
         // http://www.sitepoint.com/css3-animation-javascript-event-handlers/

         // destroy on a timer because otherwise it'll never go away.
         window.setTimeout(function () {
            list.pop();
         }, displayDuration);
      }
   };

   window.flash('notice', preloaded.notices);
   window.flash('warning', preloaded.warnings);
   window.flash('error', preloaded.errors);
}(window));