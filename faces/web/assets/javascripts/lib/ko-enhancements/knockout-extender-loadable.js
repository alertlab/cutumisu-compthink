/**
 * For observables that get loaded from AJAX. This adds a isLoaded observable property to the target observable.
 *
 * isLoaded is true after the first assignment to the observable.
 *
 * shouldReload is true when it should be reloaded. This allows objects that share an observable to mark a dataset
 * for reloading.
 *
 * @param target
 * @param options
 * @returns {*}
 */
ko.extenders.loadable = function (target, options) {
   target.isLoaded = ko.observable(false);
   target.shouldReload = ko.observable(false);

   target.subscribe(function (newVal) {
      target.shouldReload(false);
      target.isLoaded(true);
   });

   return target;
};