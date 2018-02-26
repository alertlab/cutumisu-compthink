// transformations
(function (window, undefined) {
   // TODO: modularize these all to depollute the global namespace

   window.twoDigit = function (string) {
      return ('0' + string).slice(-2);
   };

   window.padDigitLeft = function (numberToPad, n) {
      return ((new Array(n)).join('0') + numberToPad).slice(-n);
   };

   window.humanDate = function (stamp) {
      if (!stamp)
         return null;

      var date = new Date(typeof stamp === 'number' ? stamp * 1000 : stamp);

      // IE8 doesn't suppport:
      // date.toLocaleDateString(navigator.language, {month: 'short'});
      if (date.toLocaleDateString) {
         return date.toLocaleDateString(navigator.locale, {month: 'short', day: 'numeric', year: 'numeric'});
      } else {
         return date.toLocaleDateString();
      }
   };

   window.humanDateTime = function (stamp) {
      if (!stamp)
         return null;

      var date = new Date(stamp * 1000);
      var now = new Date();

      if (date.toLocaleDateString() == now.toLocaleDateString()) { // same day?
         // IE8 doesn't suppport:
         // date.toLocaleTimeString(navigator.language, {hour: '2-digit', minute:'2-digit'});
         return 'Today, ' + date.getHours() + ":" + twoDigit(date.getMinutes())
      } else {
         return date.toLocaleString();
      }
   };

   window.humanDuration = function (ms_duration) {
      var in_hours = ms_duration / (3600 * 1000);

      return in_hours.toFixed(1) + (in_hours > 1 ? ' hours' : ' hour');
   };

   //window.dateString = function (shift) {
   //    var date = new Date(shift.time * 1000);
   //    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
   //
   //    return months[date.getMonth()] + '-' + window.twoDigit(date.getDate()) + '-' + date.getFullYear();
   //};

   window.humanTime = function (stamp) {
      var date = new Date(stamp * 1000);

      return window.twoDigit(date.getHours()) + ':' + window.twoDigit(date.getMinutes());
   };

   window.desymbol = function (sym) {
      return sym.replace('_', ' ');
   };

   window.toYesNo = function (value) {
      if (value)
         return "Yes";
      else
         return "No";
   };

   window.deserializeSearch = function () {
      var pairs = location.search.substring(1, location.search.length).split("&");
      var params = {};

      for (var i = 0; i < pairs.length; i++) {
         if (pairs[i]) {
            var p = pairs[i].split("=");

            params[p[0]] = decodeURIComponent(p[1]);
         }
      }

      return params
   };

   window.serializeSearch = function (paramHash) {
      var params = [];

      for (param in paramHash) {
         if (paramHash.hasOwnProperty(param)) {
            params.push(param + "=" + paramHash[param]);
         }
      }

      var serialized = params.join('&');

      return (serialized ? "?" : "") + serialized;
   };

   window.titlecase = function (string) {
      return string.replace(/\w\S*/g, function (txt) {
         return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
      });
   };
}(window));
