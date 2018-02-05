/**
 * Extends the observable to toggle itself when another provided observable is set to the same value twice.
 * It will default to true when the source changes, and then switch to false when the source receives the same value;
 * The source is watched for *all* updates, including when the value is identical (ie you don't need to apply a always notify extender).
 *
 * @param target
 * @param options
 *          - source: the other observable to watch and toggle after repeat changes
 * @returns {*}
 */
ko.extenders.doubleToggle = function (target, options) {
   var source = options.source.extend({
      notify: 'always'
   });

   source.subscribeChanged(function (newVal, oldVal) {
      if (oldVal != newVal || !target())
         target(true);
      else
         target(false);
   });

   return target;
};