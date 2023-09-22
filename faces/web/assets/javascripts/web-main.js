/**
 * = require knockoutjs-widgets/manifests/sprockets
 * = require_tree ./lib/ko-enhancements
 * = require_directory .
 * = require_tree ./components
 */

/**
 * Stores basic display data for the currently signed in user.
 * Its value should be a raw JS object hash (ie. no observables)
 *
 * Note, these values are for display purposes only and should never be trusted used by the server.
 */
window.currentUser = ko.observable().extend({
   storage: {
      key: 'user_data',
      type: 'cookie'
   }
})

// useful for in-line throwing
window.explode = function (msg) {
   throw msg;
};

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

window.addEventListener('error', function (msg, url, line, col, error) {
   // Try-catch is needed to avoid infinite loops.
   try {
      window.flash('error', 'The system had an internal problem.');
   } catch (e) {
      return false;
   }
});
