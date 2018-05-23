ko.components.register('input-password', {
   template: '<div class="input-wrapper">\
                 <input name="password" \
                        type="password" \
                        data-bind="textInput: password, \
                                   attr: {type: inputType},\
                                   style: {fontFamily: pwFont},\
                                   event: {focusout: loseFocus}"/>\
                 <!-- ko foreach: spaces-->\
                    <span class="space-highlight" \
                          data-bind="style: {left: $data, \
                                             fontFamily: $parent.pwFont}">&nbsp;</span>\
                 <!-- /ko -->\
              </div><a href="#"\
                          class="show-pw"\
                          data-bind="click: showPassword.toggle,\
                                     attr: {title: showPassTitle}">\
                 <span class="icon" \
                       data-bind="css: showPassText"><img src="" \
                                                          data-bind="attr: {src: window.appData.imagePaths.eyeGrey}"/></span>\
                 <span data-bind="text: showPassText"></span>\
              </a>',


   viewModel: function (params) {
      var self = this;

      self.pwFont = '13px monospace';

      self.user = window.currentUser;

      self.password = params['password'] || ko.observable('');

      self.showPassword = ko.observable(false).toggleable();

      self.showPassText = ko.pureComputed(function () {
         return self.showPassword() ? 'hide' : 'see';
      });

      self.showPassTitle = ko.pureComputed(function () {
         return self.showPassword() ? 'Hide Password' : 'Show Password';
      });

      self.inputType = ko.pureComputed(function () {
         return self.showPassword() ? 'text' : 'password';
      }).extend({throttle: 50});

      self.loseFocus = function (vm, event) {
         var related = event.relatedTarget;

         if (related && related.classList.contains('.show-pw') && event.target === related.previousSibling.querySelector('input')) {
            event.target.focus();
         } else
            self.showPassword(false);
      };

      // this assumes monospace for two reasons:
      // 1. It's far easier to calculate the location of the spaces; and,
      // 2. Monospace forces large spaces, which makes them more obvious
      self.spaces = ko.pureComputed(function () {
         if (!self.showPassword())
            return [];

         var charWidth = self.getTextWidth('M', self.pwFont);//13.3;
         var spaces = [];

         (self.password() || '').split('').forEach(function (char, i) {
            if (/\s/.test(char))
               spaces.push((i + 1) * charWidth + 'px');
         });

         return spaces
      });

      /**
       * Uses canvas.measureText to compute and return the width of the given text of given font in pixels.
       *
       * @param {String} text The text to be rendered.
       * @param {String} font The css font descriptor that text is to be rendered with (e.g. "bold 14px verdana").
       *
       * @see https://stackoverflow.com/questions/118241/calculate-text-width-with-javascript/21015393#21015393
       */
      self.getTextWidth = function (text, font) {
         // re-use canvas object for better performance
         var canvas = self.getTextWidth.canvas || (self.getTextWidth.canvas = document.createElement("canvas"));
         var context = canvas.getContext("2d");
         context.font = font;
         var metrics = context.measureText(text);
         return metrics.width;
      };
   }
});