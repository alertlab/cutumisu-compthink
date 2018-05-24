/**
 * = require ./lib/knockout-3.4.2.min
 * = require ./lib/knockout.mapping-2.0.min
 * = require_tree ./lib/ko-enhancements
 * = require_directory .
 * = require_tree ./components
 */
function compthink() {
   window.currentUser = ko.observable(null);

   // useful for in-line throwing
   window.explode = function (msg) {
      throw msg;
   };

   // Try to remember session from last time, if any
   var data = readCookie('compthink.user_data');
   if (data) {
      data = JSON.parse(decodeURIComponent(data));

      window.currentUser(ko.mapping.fromJS(data));
   }

   ko.applyBindings();
}

/**
 * Array#find polyfill for ancient browsers
 */
if (!Array.prototype.find) {
   Array.prototype.find = function (predicate) {
      if (this === null) {
         throw new TypeError('Array.prototype.find called on null or undefined');
      }
      if (typeof predicate !== 'function') {
         throw new TypeError('predicate must be a function');
      }
      var list = Object(this);
      var length = list.length >>> 0;
      var thisArg = arguments[1];
      var value;

      for (var i = 0; i < length; i++) {
         value = list[i];
         if (predicate.call(thisArg, value, i, list)) {
            return value;
         }
      }
      return undefined;
   };
}

window.addEventListener('load', compthink);

window.addEventListener('error', function (msg, url, line, col, error) {
   // Try-catch is needed to avoid infinite loops.
   try {
      window.flash('error', 'The system had an internal problem.');
   } catch (e) {
      return false;
   }
});
