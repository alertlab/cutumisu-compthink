/**
 * For observableArrays that should remove elements after a delay.
 *
 * Note: this does remove duplicates at the time of the first instance.
 *
 * @param targetObs the observable being modified
 * @param duration: the number of milliseconds for the value to remain in targetObs. Default: 1000
 * @returns {*}
 */
ko.extenders.temporaryValue = function (targetObs, duration) {
   duration = duration || 1000;

   targetObs.subscribe(function (newValueMetas) {
      var newValues = newValueMetas.filter(function (newValueMeta) {
         return newValueMeta.status === 'added';
      }).map(function (newValueMeta) {
         return newValueMeta.value;
      });

      if (!newValues.length)
         return;

      window.setTimeout(function () {
         targetObs.removeAll(newValues);
      }, duration);
   }, null, "arrayChange");

   return targetObs;
};