/**
 * For simple boolean observables that toggle on and off on click.
 *
 * @param target
 * @param options
 * @returns {*}
 */
ko.observable.fn.toggleable = function () {
   var self = this;
   self.toggle = function () {
      self(!self());
   };

   return self;
};