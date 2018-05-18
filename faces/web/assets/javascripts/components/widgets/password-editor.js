ko.components.register('password-editor', {
   template: '<header>Password</header>\
              <form data-bind="submit: setPassword">\
                 <ul>\
                    <li>\
                       <label>\
                          <header>New Password</header>\
                          <input name="password" type="password" data-bind="textInput: password, \
                                                                            attr: {type: inputType}, \
                                                                            fontFamily: pwFont" \
                             /><a href="#" class="show-pw" data-bind="click: showPassword.toggle,\
                                                                      attr: {title: showPassTitle}">\
                             <span class="icon" data-bind="css: showPassText"><img src="" data-bind="attr: {src: window.imagePaths.eyeGrey}"/></span>\
                             <span data-bind="text: showPassText"></span>\
                          </a>\
                          <!-- ko foreach: spaces-->\
                             <span class="space-highlight" data-bind="style: {left: $data, \
                                                                              fontFamily: $parent.pwFont}">&nbsp;</span>\
                          <!-- /ko -->\
                       </label>\
                    </li>\
                 </ul>\
                 <input type="submit" value="Save" />\
              </form>',

   viewModel: function () {
      var self = this;

      self.pwFont = '13px monospace';

      self.user = window.currentUser;

      self.email = ko.observable();
      self.password = ko.observable('');

      self.group = ko.observable(getParam('g') || getParam('group'));
      self.username = ko.observable();

      self.showPassword = ko.observable(false).toggleable();

      self.showPassText = ko.pureComputed(function () {
         return self.showPassword() ? 'hide' : 'see';
      });

      self.showPassTitle = ko.pureComputed(function () {
         return self.showPassword() ? 'Hide Password' : 'Show Password';
      });

      self.inputType = ko.pureComputed(function () {
         return self.showPassword() ? 'text' : 'password';
      });

      // this assumes monospace for two reasons:
      // 1. It's far easier to calculate the location of the spaces; and,
      // 2. Monospace forces large spaces, which makes them more obvious
      self.spaces = ko.pureComputed(function () {
         if (!self.showPassword())
            return [];

         var charWidth = self.getTextWidth('M', self.pwFont);//13.3;
         var spaces = [];

         self.password().split('').forEach(function (char, i) {
            if (/\s/.test(char))
               spaces.push((i + 1) * charWidth + 'px');
         });

         // drop the last one because we're looking for *between* items, and last one is off the end
         // spaces.pop();

         console.log(spaces)

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
      }

      self.setPassword = function () {
         // var data = {
         //    admin: {
         //       email: self.email(),
         //       password: self.password()
         //    },
         //    user: {
         //       group: self.group(),
         //       username: self.username()
         //    }
         // };
         //
         // ajax('post', '/auth/sign_in', ko.mapping.toJSON(data), function (response) {
         //    self.user(ko.mapping.fromJS(response.user));
         //
         //    document.cookie = 'compthink.flash_notices=' + encodeURIComponent(JSON.stringify([response.notice]));
         //
         //    response.redirect = window.deserializeSearch().uri || response.redirect
         // });
         //
         // self.password(null);
      };
   }
});