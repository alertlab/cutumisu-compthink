/**
 * From mbest: https://github.com/knockout/knockout/issues/914
 *
 * @param callback
 * @returns {*}
 */
ko.subscribable.fn.subscribeChanged = function (callback) {
   var savedValue = this.peek();

   return this.subscribe(function (latestValue) {
      var oldValue = savedValue;
      savedValue = latestValue;
      callback(latestValue, oldValue);
   });
};