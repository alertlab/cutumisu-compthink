/**
 * Supports the ability to have site-wide toast popups in the bottom corner
 */
(function (window, undefined) {
   var DISPLAY_DURATION = 10 * 1000; // in ms.

   TenjinComms.successReporter = function (msgs) {
      if (!msgs) return;

      if (!(msgs instanceof Array))
         msgs = [msgs];

      msgs.forEach(function (msg) {
         window.toasts.info.push(msg);
      })
   }

   TenjinComms.errorReporter = function (msgs) {
      if (!msgs) return;

      if (!(msgs instanceof Array))
         msgs = [msgs];

      msgs.forEach(function (msg) {
         window.toasts.error.push(msg);
      })
   }

   console.debug(
      'Disabling KOWT storage namespacing due to rack cookie key bug (https://github.com/rack/rack/issues/1865).',
      'When it is fixed, this can be removed.')
   ko.extenders.storage.namespace = ''; // disable namespacing

   /**
    * Map of the message cookie log level to the JS equivalent
    * @constant
    */
   var LEVELS = {
      debug: 'debug',
      info: 'info',
      warn: 'warn',
      error: 'error',
      fatal: 'error',
      any: 'log'
   };

   /* Rack encodes cookies using URI.encode_www_form_component, which uses plus signs for spaces. Flash messages from
    * the server are therefore pre-encoded into base64 to obscure whitespace, sidestepping the entire issue.
    * This is not an ideal solution, but it works for now.
    */
   var decodeCookie = function (entries) {
      return entries.map(function (entry) {
         return atob(entry)
      })
   }

   var encodeCookie = function (entries) {
      return entries.map(function (entry) {
         return btoa(entry)
      })
   }

   var log = function (messages, level) {
      messages.forEach(function (messages) {
         console[level](messages);
      })
   }

   window.toasts = Object.keys(LEVELS).reduce(function (toasts, msgLevel) {
      toasts[msgLevel] = ko.observableArray().extend({
         temporaryValue: DISPLAY_DURATION,
         storage: {
            key: 'messages.' + msgLevel,
            type: 'cookie',
            duration: DISPLAY_DURATION - 1,
            serializer: encodeCookie,
            deserializer: decodeCookie
         }
      });

      // Log the message at the appropriate JS log level.
      toasts[msgLevel].subscribe(function (changes) {
         changes = changes.filter(function (change) {
            return change.status === 'added';
         });

         log(changes.map(function (change) {
            return change.value
         }), LEVELS[msgLevel])
      }, this, 'arrayChange');

      // log the initial value right away
      log(toasts[msgLevel](), LEVELS[msgLevel])

      return toasts;
   }, {})

   window.addEventListener('error', function (error) {
      // Try-catch is needed to avoid infinite loops.
      try {
         window.toasts.error.push('The system had an internal problem.');

         console.error(error.message, error.filename, error.lineno + ':' + error.colno)
      } catch (e) {
         return false;
      }
   });
}(window));
