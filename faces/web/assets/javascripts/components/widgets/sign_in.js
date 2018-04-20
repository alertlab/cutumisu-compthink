ko.components.register('sign-in', {
   template: '<header data-bind="text: titleText"></header>\
              <form data-bind="submit: signIn">\
                 <ul data-bind="visible: isAdmin">\
                    <li>\
                       <label for="email">Email</label>\
                       <input type="email" name="email" placeholder="eg. jdoe@example.com" data-bind="value: email" />\
                    </li>\
                    <li>\
                       <label for="password">Password</label>\
                       <input name="password" type="password" data-bind="value: password" />\
                    </li>\
                 </ul>\
                 <ul data-bind="visible: !isAdmin">\
                    <li>\
                       <label>\
                          <span>Group</span>\
                          <input type="text" name="group" data-bind="value: group" />\
                       </label>\
                    </li>\
                    <li>\
                       <label>\
                          <span>Username</span>\
                          <input type="text" name="username" data-bind="value: username" />\
                       </label>\
                    </li>\
                 </ul>\
                 <input type="submit" data-bind="value: buttonText"  />\
              </form>',

   viewModel: function () {
      var self = this;

      self.user = window.currentUser;

      self.email = ko.observable();
      self.password = ko.observable();

      self.group = ko.observable(getParam('g') || getParam('group'));
      self.username = ko.observable();

      self.isAdmin = !!(window.location.pathname.match(/^\/admin/) || window.location.search.match(/\?uri=\/admin/));

      self.titleText = ko.pureComputed(function () {
         return self.isAdmin ? 'Admin Sign In' : 'Hello';
      });

      self.buttonText = ko.pureComputed(function () {
         return self.isAdmin ? 'Sign In' : 'Go!'
      });

      self.signIn = function () {
         var data = {
            admin: {
               email: self.email(),
               password: self.password()
            },
            user: {
               group: self.group(),
               username: self.username()
            }
         };

         ajax('post', '/auth/sign_in', ko.mapping.toJSON(data), function (response) {
            self.user(ko.mapping.fromJS(response.user));

            document.cookie = 'compthink.flash_notices=' + encodeURIComponent(JSON.stringify([response.notice]));

            response.redirect = window.deserializeSearch().uri || response.redirect
         });

         self.password(null);
      };
   }
});