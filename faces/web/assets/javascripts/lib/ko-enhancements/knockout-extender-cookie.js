/**
 * For observables that should persist their content into a cookie, so that it is retained between pages.
 *
 * @param targetObs the observable being modified
 * @param options hash of options including:
 *                  - key: the cookie name
 *                  - duration: the number of milliseconds to until the cookie expiry. Default: 0
 * @returns {*}
 */
ko.extenders.cookie = function (targetObs, options) {
   var readCookie, writeCookie, cookieRawValue;
   readCookie = function (cookieKey) {
      // src: https://stackoverflow.com/a/25490531/1483247
      var match = document.cookie.match('(^|;)\\s*' + cookieKey + '\\s*=\\s*([^;]+)');

      return match ? match.pop() : null;
   };

   writeCookie = function (name, value) {
      var date, expires;

      date = new Date();
      date.setTime(options.duration ? date.getTime() + options.duration : 0);

      expires = "; expires=" + date.toUTCString();

      document.cookie = name + "=" + (value || "") + expires + "; path=/";
   };

   if (!options.key)
      throw 'Must provide a "key" parameter to cookie extender';

   cookieRawValue = readCookie(options.key);

   if (cookieRawValue) {
      targetObs(JSON.parse(decodeURIComponent(cookieRawValue).replace(/\+/g, ' ')));
   }

   targetObs.subscribe(function (newValue) {
      writeCookie(options.key, ko.toJSON(newValue));
   });

   return targetObs;
};