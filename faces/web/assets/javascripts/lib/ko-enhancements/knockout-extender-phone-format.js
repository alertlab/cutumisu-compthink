ko.extenders.phoneFormat = function (target, options) {
   var formattedTarget;

   formattedTarget = ko.computed({
      read: function () {
         var value, length, nxxSize, numberSize, areaSize, nxx, number, area, country;

         value = target();

         numberSize = 4; // back half of the actual "number" portion
         nxxSize = 3; // first half of the actual "number" portion
         areaSize = 3;

         if (value && value.length >= nxxSize + numberSize) {
            length = value.length;
            number = value.substring(length - numberSize);
            nxx = value.substring(length - (nxxSize + numberSize), length - numberSize);
            area = value.substring(length - (areaSize + nxxSize + numberSize), length - (nxxSize + numberSize));
            country = value.substring(0, length - (areaSize + nxxSize + numberSize));

            // padding in defaults is easiest
            area = ('780' + area).slice(-areaSize);
            country = country || '1';

            return [country, area, nxx, number].join(options.separator);
         } else {
            return value;
         }
      }, write: function (newVal) {
         var val;

         val = newVal;

         if (val) {
            val = val.replace(/[abc]/g, '2');
            val = val.replace(/[def]/g, '3');
            val = val.replace(/[ghi]/g, '4');
            val = val.replace(/[jkl]/g, '5');
            val = val.replace(/[mno]/g, '6');
            val = val.replace(/[pqrs]/g, '7');
            val = val.replace(/[tuv]/g, '8');
            val = val.replace(/[wxyz]/g, '9');
            val = val.replace(/\D|\./g, '');
         }

         target(val);
      }
   });

   return formattedTarget;
};